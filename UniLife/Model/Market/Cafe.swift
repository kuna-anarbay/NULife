//
//  Cafe.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/16/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase
import YPImagePicker


class Cafe {
    
    var id: String = ""
    var approved: Bool = false
    var title: String = ""
    var details: String = ""
    var featured: String = ""
    var contacts: [[String: String]] = []
    var days: [String: [String: Int]] = [:]
    var urls: [String: String] = [:]
    var reviews: [Review]? = []
    var notNull: Bool {
        get {
            if self.id.count == 0 {
                return false
            }
            if self.title.count == 0 {
                return false
            }
            if self.details.count == 0 {
                return false
            }
            return true
        }
    }
    var reviewsCount: Int {
        get {
            return reviews?.count ?? 0
        }
    }
    var reviewsSum: Int {
        get {
            var sum = 0
            reviews?.forEach({ (review) in
                sum += review.rating
            })
            return sum
        }
    }
    var rating: Float {
        get {
            if self.reviewsCount == 0 {
                return 0
            }
            return Float(self.reviewsSum) / Float(self.reviewsCount)
        }
    }
    var workingHours: String {
        var hours = String()
        for day in staticList.weekDays {
            if self.days[day]!["start"]! != self.days[day]!["end"]! {
                hours += Helper.display24HourTimeGMT0(timestamp: self.days[day]!["start"]!)
                        + "-" + Helper.display24HourTimeGMT0(timestamp: self.days[day]!["end"]!)
            } else {
                hours += "Closed"
            }
            if day != "sun" {
               hours += "\n"
            }
        }
        return hours
    }
    
    var opensAt: String {
        get {
            let weekDay = Calendar.current.component(.weekday, from: Date()) > 1 ? Calendar.current.component(.weekday, from: Date()) - 2 : 6
            let today = staticList.weekDays[weekDay]
            let nextDay = staticList.weekDays[weekDay == 6 ? 0 : weekDay + 1]
            let currentTime = Helper.displayHourMinuteTimestamp(timestamp: Int(Date().timeIntervalSince1970))
            if currentTime < self.days[today]!["start"]! {
                return "Opens at " + Helper.display24HourTimeGMT0(timestamp: self.days[today]!["start"]!)
            } else if currentTime < self.days[today]!["end"]! {
                if self.days[today]!["end"]! - currentTime > 3600 {
                    return "Open"
                } else {
                    return "Closes at " + Helper.display24HourTimeGMT0(timestamp: self.days[today]!["end"]!)
                }
            } else if self.days[nextDay]!["start"]! != self.days[nextDay]!["end"]! {
                return "Opens tomorrow at " + Helper.display24HourTimeGMT0(timestamp: self.days[nextDay]!["start"]!)
            } else {
                return "Closed"
            }
        }
    }
    var opensColor: UIColor {
        get {
            let weekDay = Calendar.current.component(.weekday, from: Date()) > 1 ? Calendar.current.component(.weekday, from: Date()) - 2 : 6
            let today = staticList.weekDays[weekDay]
            let currentTime = Helper.displayHourMinuteTimestamp(timestamp: Int(Date().timeIntervalSince1970))
            if currentTime < self.days[today]!["start"]! {
                return UIColor(named: "Danger color")!
            } else if currentTime < self.days[today]!["end"]! {
                if self.days[today]!["end"]! - currentTime > 3600 {
                    return UIColor(named: "Success color")!
                } else {
                    return UIColor(named: "Secondary color")!
                }
            } else {
                return UIColor(named: "Danger color")!
            }
        }
    }
    
    init(){
        
    }
    
    init(snapshot: DataSnapshot) {
        
        let value = snapshot.value as! NSDictionary
        
        self.id = snapshot.key
        self.approved = value["approved"] as? Bool ?? false
        self.title = value["title"] as! String
        self.details = value["details"] as! String
        self.featured = value["featured"] as? String ?? ""
        self.contacts = value["contacts"] as? [[String: String]] ?? []
        self.days = value["days"] as? [String: [String: Int]] ?? [:]
        self.urls = value["urls"] as! [String: String]
        (value["reviews"] as? NSDictionary)?.forEach { (args) in
            self.reviews?.append(Review(args))
        }
        self.reviews = self.reviews?.sorted(by: { (one, two) -> Bool in
            return one.timestamp > two.timestamp
        })
    }
    
    
    
    static func getAll(completion: @escaping([Cafe]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.cafesRef.queryOrdered(byChild: "approved").queryEqual(toValue: true)) { (snapshots) in
            var cafes = [Cafe]()
            snapshots.forEach { (snapshot) in
                if snapshot.hasChildren() {
                    let cafe = Cafe(snapshot: snapshot)
                    if cafe.approved {
                        cafes.append(cafe)
                    }
                }
            }
            completion(cafes)
        }
    }
    
    
    static func getOne(_ id: String, completion: @escaping(Cafe) -> Void){
        FetchManager.getOne(databaseRef: Constants.cafesRef.child(id)) { (snapshot) in
            if snapshot.hasChildren() {
                completion(Cafe(snapshot: snapshot))
            } else {
                completion(Cafe())
            }
        }
    }
    
}


class Review {
    
    var id: String = ""
    var author: Member = Member()
    var rating: Int = 0
    var body: String? = ""
    var timestamp: Int = 0
    var image: String? = ""
    
    
    var newRepresentation: [String : Any] {[
        "name": Auth.auth().currentUser!.displayName!,
        "rating": self.rating,
        "body": self.body ?? "",
        "timestamp": Int(Date().timeIntervalSince1970),
        "image": self.image ?? ""
    ]}
    
    
    init(){
        
    }
    
    init(_ snapshot: NSDictionary.Element){
        
        let value = snapshot.value as! NSDictionary
        
        self.id = snapshot.key as! String
        self.body = value["body"] as? String
        self.rating = value["rating"] as! Int
        self.timestamp = value["timestamp"] as! Int
        self.image = value["image"] as? String
        self.author = Member(name: value["name"] as! String, uid: snapshot.key as! String)
    }
    
    
    
    
    func firebaseAdd(cafeId: String, images : [UIImage], completion: @escaping(completionType) -> Void) {
        if images.count > 0 {
            DatabaseManager.uploadImages(
                storageRef: Constants.reviewImagesRef.child(cafeId)
                    .child(Auth.auth().currentUser!.uid),
                childs: ["0"],
                images: images,
                index: 0,
                image_urls: [:]
            ) { (results) in
                self.image = results.first?.value
                self.setToDatabase(cafeId: cafeId) { (message) in
                    completion(message)
                }
            }
        } else {
            self.setToDatabase(cafeId: cafeId) { (message) in
                completion(message)
            }
        }
    }
    
    
    private func setToDatabase(cafeId: String, completion: @escaping(completionType) -> Void){
        DatabaseManager.update(
            databaseRef: Constants.cafesRef.child(cafeId).child("reviews")
                .child(Auth.auth().currentUser!.uid),
            object: self.newRepresentation) { (message) in
                completion(message)
        }
    }
    
    
}
