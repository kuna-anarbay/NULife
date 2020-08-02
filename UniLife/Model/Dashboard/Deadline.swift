//
//  Deadline.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/2/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class Deadline {
    
    //MARK: Main info
    //ID
    var id : String = ""
    var courseId: String = ""
    
    var author = Member()
    var authorRepresentation : [String: String] = [:]
    var title: String = ""
    var timestamp:Int = Int(Date().timeIntervalSince1970)
    var day: String {
        get {
            return Helper.displayDayMonth(timestamp: self.timestamp)
        }
    }
    
    var section: String = "0"
    var color: String = "#00A89D"
    
    var details: String? = ""
    var location: String? = ""
    var reminder: Int = -1
    
    var isValid: (Bool, String) {
        get {
            
            if title.count < 2 {
                return (false, "Title must be minimum 2 characters")
            }
            
            if timestamp < Int(Date().timeIntervalSince1970) + 15*60 {
                return (false, "Starting time must be minimum 15 from now")
            }
            
            return (true, "Success")
        }
    }
    
    init(){
        
    }
    
    
    init(snapshot: DataSnapshot, courseId: String) {

        let value = snapshot.value as! NSDictionary
        
        self.id = snapshot.key
        self.courseId = courseId
        
        self.authorRepresentation = value["author"] as! [String: String]
        self.author = Member(
            name: authorRepresentation["name"]!,
            uid: authorRepresentation["uid"]!,
            image: authorRepresentation["image"]!
        )
        self.title = value["title"] as! String
        self.timestamp = value["timestamp"] as? Int ?? Int(Date().timeIntervalSince1970)
        self.section = "\(value["section"] as! Int)"
        self.color = value["priority"] as! Int == 0 ? "#00A89D" : "#DA143A"
        
        self.details = value["details"] as? String
        self.location = value["location"] as? String
    }
    
    
    static func getDeadlines(of courseId: String, completion: @escaping([Deadline]) -> Void) {
        FetchManager.getAll(
            databaseRef: Constants.deadlinesRef.child(courseId)
        ) { (snapshots) in
            completion(snapshots.map({ (snapshot) -> Deadline in
                return Deadline(snapshot: snapshot, courseId: courseId)
            }))
        }
    }
}


extension Deadline {
    
    //MARK: Representation
    var newRepresentation: [String : Any] {[
        "author": self.author.authorRepresentation,
        "title": self.title,
        "timestamp": self.timestamp,
        "section": Int(self.section) ?? 0,
        "priority": self.color=="#00A89D" ? 0 : 1,
        "location": self.location ?? "",
        "details": self.details ?? "",
    ]}
    
    
    
    //MARK: Functions
    func firebaseAdd(completion: @escaping(completionType) -> Void){
        DatabaseManager.createKey(
            databaseRef: Constants.deadlinesRef.child(self.courseId)
        ) { (key) in
            User.getCurrentUser { (user) in
                self.author = Member(
                    name: user.name,
                    uid: user.id,
                    image: user.image
                )
                DatabaseManager.create(
                    databaseRef: Constants.deadlinesRef.child(self.courseId).child(key),
                    object: self.newRepresentation
                ) { (message) in
                    self.id = key
                    self.addToTimetable()
                    completion(message)
                }
            }
        }
    }
    
    
    
    func addToTimetable(){
        self.asTask.add()
    }
    
    var asTask: Task {
        get {
            return Task(value: [
                "identifier": id,
                "name": self.title,
                "start": self.timestamp,
                "location": self.location ?? "",
                "topic": self.courseId,
                "color": self.color,
                "note": self.details ?? "",
                "reminder": self.reminder
            ])
        }
    }
    
    
    
    func firebaseDelete(completion: @escaping(completionType) -> Void){
        Constants.deadlinesRef.child(self.courseId).child(self.id).removeValue { (error, _) in
            if error != nil {
                completion(.error)
            } else {
                completion(.success)
            }
        }
    }
}
