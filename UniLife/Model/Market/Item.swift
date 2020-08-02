//
//  Item.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/16/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase
import YPImagePicker
import SPAlert


class Item {
    
    var id: String = ""
    var title: String = ""
    var author = Member(
        name: "Anonymous",
        uid: UserDefaults.standard.string(forKey: "anonymousId")!,
        image: ""
    )
    var authorRepresentation : [String: String] = [:]
    var contacts: [[String: String]]? = []
    var details: String? = ""
    var price: Int = -1
    var timestamp: Int = 0
    var discountedPrice: Int = -1
    var lastActive: Int = 0
    var urls: [String]? = []
    var category: String = "Food"
    var sell: Bool = true
    var female: Bool = false
    var requests: [Request] = [Request]()
    var notNull: Bool {
        get {
            if self.id.count == 0 {
                return false
            }
            if self.title.count == 0 {
                return false
            }
            return true
        }
    }
    var discount: Int {
        get {
            if self.price == 0 {
                return 100
            } else if self.discountedPrice == -1 {
                return 0
            }
            return ((self.price - self.discountedPrice)*100)/self.price
        }
    }
    var categoriesString: String {
        get {
            var category = "#" + self.category + ", "
            category += self.sell ? "#Sell" : "#Buy"
            category += self.female ? ", #Ladies" : ""
            
            return category
        }
    }
    var categoriesList: [String] {
        get {
            var categories = [
                self.category,
                self.sell ? "Sell" : "Buy"
            ]
            if self.female {
                categories.append("Ladies")
            }
            
            return categories
        }
    }
    var isValid: (Bool, String) {
        get {
            if self.title.count < 2 {
                return (false, "Title must be 2 characters minimum")
            }
            
            return (true, "Success")
        }
    }
    
    init(){
        
    }
    
    init(female: Bool, snapshot: DataSnapshot, requestsSnapshot: [Request]?) {
        let value = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.title = value["title"] as! String
        self.authorRepresentation = value["author"] as! [String: String]
        self.author = Member(
            name: authorRepresentation["name"]!,
            uid: authorRepresentation["uid"]!,
            image: authorRepresentation["image"] ?? ""
        )
        self.sell = value["sell"] as! Bool
        self.details = value["details"] as? String
        self.price = value["price"] as! Int
        self.timestamp = value["timestamp"] as! Int
        self.discountedPrice = value["discounted_price"] as! Int
        self.lastActive = value["last_active"] as! Int
        self.urls = value["urls"] as? [String]
        self.category = value["category"] as! String
        self.contacts = value["contacts"] as? [[String: String]]
        self.female = female
        if let requestSnapshots = requestsSnapshot {
            self.requests = requestSnapshots
        } else {
            self.requests = []
        }
    }
    
    
    func setAnonymous(){
        if self.author.name == "Anonymous" {
            self.author = Member(name: Auth.auth().currentUser!.displayName!, uid: Auth.auth().currentUser!.uid, image: UserDefaults.standard.string(forKey: "profile_url")!)
        } else {
            self.author = Member(name: "Anonymous", uid: UserDefaults.standard.string(forKey: "anonymousId")!, image: "")
        }
        self.authorRepresentation = self.author.authorRepresentation
    }
    
    
    static func getDefaultItem(completion: @escaping([Item]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.itemsRef) { (snapshots) in
            var items = [Item]()
            snapshots.forEach { (snapshot) in
                if snapshot.hasChildren() {
                    items.append(Item(female: false, snapshot: snapshot, requestsSnapshot: nil))
                }
            }
            completion(items)
        }
    }
    
    
    static func getFemaleItems(completion: @escaping([Item]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.femaleItemsRef) { (snapshots) in
            var items = [Item]()
            snapshots.forEach { (snapshot) in
                if snapshot.hasChildren() {
                    items.append(Item(female: true, snapshot: snapshot, requestsSnapshot: nil))
                }
            }
            completion(items)
        }
    }
    
    
    static func getOne(_ id: String, female: Bool, completion: @escaping(Item) -> Void){
        FetchManager.getOne(
            databaseRef: female ? Constants.femaleItemsRef.child(id) : Constants.itemsRef.child(id)
        ) { (snapshot) in
            FetchManager.getAll(databaseRef: Constants.requestsRef.child(id)) { (snapshots) in
                if snapshot.hasChildren() {
                    completion(Item(female: female, snapshot: snapshot, requestsSnapshot: snapshots.map({ (child) -> Request in
                        return Request(snapshot: child)
                    })))
                } else {
                    completion(Item())
                }
            }
        }
    }
    
    var newRepresentation: [String : Any] {[
        "title": self.title,
        "author": self.author.authorRepresentation,
        "contacts": self.contacts ?? [],
        "details": details ?? "",
        "price": self.price,
        "timestamp": Int(Date().timeIntervalSince1970),
        "discounted_price": self.price,
        "last_active": Int(Date().timeIntervalSince1970),
        "urls": urls ?? [],
        "category": self.category,
        "sell": sell
    ]}
    
    
    var updateRepresentation: [String : Any] {[
        "title": self.title,
        "author": self.author.authorRepresentation,
        "contacts": self.contacts ?? [],
        "details": details ?? "",
        "timestamp": Int(Date().timeIntervalSince1970),
        "discounted_price": self.discountedPrice,
        "last_active": Int(Date().timeIntervalSince1970),
        "category": self.category,
        "sell": sell
    ]}
    
    
    func firebaseAdd(_ images: [UIImage], completion: @escaping(completionType) -> Void){
        if isValid.0 {
            let newItemRef = self.female ? Constants.femaleItemsRef : Constants.itemsRef
            DatabaseManager.createKey(
                databaseRef: newItemRef
            ) { (key) in
                self.id = key
                if images.count > 0 {
                    DatabaseManager.uploadImages(
                        storageRef: self.female ? Constants.femaleItemImageRef.child(self.id) : Constants.itemImageRef.child(self.id),
                        childs: Array(0..<images.count).map({ (index) -> String in
                            return "\(index)"
                        }),
                        images: images,
                        index: 0,
                        image_urls: [:]
                    ) { (results) in
                        self.urls = results.map({ (args) -> String in
                            return args.value
                        })
                        self.setToDatabase { (message) in
                            completion(message)
                        }
                    }
                } else {
                    self.setToDatabase { (message) in
                        completion(message)
                    }
                }
            }
        } else {
            completion(.error)
        }
    }
    
    private func setToDatabase(completion: @escaping(completionType) -> Void){
        DatabaseManager.create(
            databaseRef: self.female ? Constants.femaleItemsRef.child(self.id) : Constants.itemsRef.child(self.id),
            object: self.newRepresentation) { (message) in
                completion(message)
        }
    }
    
    
    func reActivate(completion: @escaping(completionType) -> Void) {
        let newItemRef = !self.female ? Constants.itemsRef.child(self.id) : Constants.femaleItemsRef.child(self.id)
        DatabaseManager.update(
            databaseRef: newItemRef,
            object: ["last_active": Int(Date().timeIntervalSince1970)]
        ) { (message) in
            completion(message)
        }
    }
    
    func firebaseEdit(completion: @escaping(completionType) -> Void){
        let newItemRef = !self.female ? Constants.itemsRef.child(self.id) : Constants.femaleItemsRef.child(self.id)
        DatabaseManager.update(
            databaseRef: newItemRef,
            object: self.updateRepresentation
        ) { (message) in
            completion(message)
        }
    }
    
    
    func firebaseDelete(completion: @escaping(completionType) -> Void){
        var liked = UserDefaults.standard.stringArray(forKey: "likedItems")
        liked?.removeAll(where: {$0 == self.id})
        UserDefaults.standard.set(liked, forKey: "likedItems")
        
        let newItemRef = !self.female ? Constants.itemsRef : Constants.femaleItemsRef
        newItemRef.child(self.id).removeValue { (error, _) in
            if error != nil {
                completion(.error)
            } else {
                completion(.success)
            }
        }
    }
}





class Request {
    
    var id:String = ""
    var name: String = ""
    var details: String? = ""
    var contacts: [[String: String]]? = []
    
    init(){
        
    }
    
    
    init(snapshot: DataSnapshot) {
        
        self.id = snapshot.key
        
        let value = snapshot.value as! NSDictionary
        
        self.name = value["name"] as! String
        self.details = value["details"] as? String
        self.contacts = value["contacts"] as? [[String: String]]
    }
    
    init(text: String?, contact: [[String: String]]) {
        self.details = text
        self.contacts = contact
    }
    
    
    var newRepresentation: [String : Any] {[
        "name": Auth.auth().currentUser!.displayName!,
        "details": self.details ?? "",
        "contacts": self.contacts ?? []
    ]}
    
    func firebaseAdd(itemId: String, completion: @escaping(completionType) -> Void) {
        let newRequest = Constants.requestsRef.child(itemId).child(Auth.auth().currentUser!.uid)
        newRequest.setValue(self.newRepresentation) { (error, _) in
            if error != nil {
                completion(.error)
            } else {
                completion(.success)
            }
        }
    }
}
