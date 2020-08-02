//
//  User.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/2/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase


class User {
    
    //MARK: Personal info: Uid, AnonymousId Email, Name, Gender
    //ID
    var id : String = Auth.auth().currentUser?.uid ?? ""
    func setId(id: String){
        self.id = id
    }
    func getId() -> String{
        return self.id
    }

    
    //ANONYMOUS_ID
    var anonymousId : String = ""
    func setAnonymousId(at anonymousId: String) {
        self.anonymousId = anonymousId
    }
    func getAnonymousId() -> String {
        return anonymousId
    }
    
    
    //EMAIL
    var email : String = Auth.auth().currentUser?.email ?? ""
    func getEmail() -> String {
        return email
    }
    
    
    //NAME
    var name : String = Auth.auth().currentUser?.displayName ?? ""
    func getName() -> String {
        return name
    }
    
    
    //GENDER
    var isFemale : Bool = false
    func setFemale(at isFemale: Bool) {
        self.isFemale = isFemale
    }
    func getIsFemale() -> Bool {
        return isFemale
    }
    
    
    //MARK: Academic info: School, Faculty and Year
    //SCHOOL
    var school : String = "Not specified"
    func setSchool(at school: String) {
        self.school = school
    }
    func getSchool() -> String {
        return school
    }
    func checkSchool() -> Bool {
        return staticList.schools.contains(self.school)
    }
    
    
    //FACULTY
    var faculty : String = "Not specified"
    func setFaculty(at faculty: String) {
        self.faculty = faculty
    }
    func getFaculty() -> String {
        return faculty
    }
    func checkFaculty() -> Bool {
        return staticList.faculties.contains(where: {$0.contains(self.faculty)})
    }
    
    
    //YEAR
    var year : Int = 0
    func setYear(at year: Int) {
        self.year = year
    }
    func getYear() -> Int {
        return year
    }
    func checkYear() -> Bool {
        return self.year > 0 && self.year < 5
    }
    
    
    //MARK: Dormitory info: Room,
    var room : String = ""
    public func setRoom(at room: String) {
        self.room = room
    }
    public func getRoom() -> String {
        return room
    }
    
    
    //MARK: Dormitory info: Room,
    var image : String = ""
}

extension User {
    var representation: [String : Any] {[
        "school": self.school,
        "major": self.faculty,
        "year": self.year,
        "image": self.image
    ]}
}


extension User {
    
    static func setupCurrentUser(completion: @escaping(User) -> Void){
        Constants.currentUserRef.child("info").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as! NSDictionary
            if snapshot.hasChild("school") {
                let user = User()
                
                user.id = snapshot.key
                
                if snapshot.hasChild("female") {
                    user.setFemale(at: value["female"] as! Bool)
                }
                if snapshot.hasChild("name") {
                    user.name = value["name"] as! String
                }
                
                if snapshot.hasChild("anonymous_id") {
                    user.setAnonymousId(at: value["anonymous_id"] as! String)
                    UserDefaults.standard.set(value["anonymous_id"] as! String, forKey: "anonymousId")
                }
                
                
                if snapshot.hasChild("school") {
                    user.setSchool(at: value["school"] as! String)
                }
                
                if snapshot.hasChild("image") {
                    user.image = value["image"] as! String
                }
                
                if snapshot.hasChild("major") {
                    user.setFaculty(at: value["major"] as! String)
                }
                if snapshot.hasChild("email") {
                    user.email = value["email"] as! String
                }
                
                if snapshot.hasChild("year") {
                    user.year = value["year"] as! Int
                }
                
                
                
                completion(user)
            }
        }
    }
    
    
    static func getCurrentUser(completion: @escaping(User) -> Void){
        Constants.currentUserRef.child("info").observe(.value) { (snapshot) in
            if Auth.auth().currentUser != nil && snapshot.hasChildren() {
                let value = snapshot.value as! NSDictionary
                let user = User()
                
                user.id = Auth.auth().currentUser!.uid
                if snapshot.hasChild("female") {
                    user.setFemale(at: value["female"] as! Bool)
                }
                if snapshot.hasChild("name") {
                    user.name = value["name"] as! String
                }
                
                if snapshot.hasChild("anonymous_id") {
                    user.setAnonymousId(at: value["anonymous_id"] as! String)
                    UserDefaults.standard.set(value["anonymous_id"] as! String, forKey: "anonymousId")
                }
                
                if snapshot.hasChild("school") {
                    user.setSchool(at: value["school"] as! String)
                }
                
                if snapshot.hasChild("image") {
                    user.image = value["image"] as! String
                }
                
                if snapshot.hasChild("major") {
                    user.setFaculty(at: value["major"] as! String)
                }
                if snapshot.hasChild("email") {
                    user.email = value["email"] as! String
                }
                
                if snapshot.hasChild("year") {
                    user.year = value["year"] as! Int
                }
                
                completion(user)
            } else {
                completion(User())
            }
        }
    }
    
    static func checkUser(completion: @escaping(Bool) -> Void) {
        completion(Auth.auth().currentUser != nil)
    }
    
    func saveAcademicToDB(image: UIImage?, completion: @escaping() -> Void){
        if let image = image {
            DatabaseManager.uploadImages(
                storageRef: Constants.userImageRef,
                childs: [self.id],
                images: [image],
                index: 0,
                image_urls: [:]
            ) { (results) in
                self.image = results[self.id]!
                self.updateInfo { (message) in
                    completion()
                }
            }
        } else {
           self.updateInfo { (message) in
                completion()
            }
        }
    }
    
    
    static func uploadImage(completion: @escaping(completionType) -> Void){
        DatabaseManager.uploadImages(
            storageRef: Constants.userImageRef,
            childs: [Auth.auth().currentUser!.uid],
            images: [UIImage(named: "user")!],
            index: 0,
            image_urls: [:]
        ) { (results) in
            let image = results[Auth.auth().currentUser!.uid]!
            DatabaseManager.update(databaseRef: Constants.currentUserRef.child("info"), object: ["image" : image]) { (message) in
                completion(message)
            }
        }
    }
    
    
    private func updateInfo(completion: @escaping(completionType) -> Void) {
        DatabaseManager.update(databaseRef: Constants.currentUserRef.child("info"), object: self.representation) { (message) in
            completion(message)
        }
    }
    
    
    static func registerToken(token: String){
        Constants.currentUserRef.child("info/token_id").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(), let oldToken = snapshot.value, (oldToken as! String) != token {
                Constants.currentUserRef.child("info/token_id").setValue(token)
            } else if !snapshot.exists() {
                Constants.currentUserRef.child("info/token_id").setValue(token)
            }
        }
    }
    
    static func unRegisterToken(){
        Constants.currentUserRef.child("info/token_id").setValue("token")
    }
    
}

