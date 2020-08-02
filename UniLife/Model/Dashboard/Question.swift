//
//  Question.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/2/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase
import YPImagePicker
import SystemConfiguration

class Question {
    
    var courseId: String = ""
    var section: String = "0"
    var id : String = ""
    var title: String = ""
    var details: String = ""
    var timestamp: Int = Int(Date().timeIntervalSince1970)
    var answersCount: Int = 0
    var topic: String = ""
    var author = Member(
        name: "Anonymous",
        uid: UserDefaults.standard.string(forKey: "anonymousId")!,
        image: ""
    )
    var authorRepresentation : [String: String] = [:]
    var isAnonymous: Bool = false
    var resolved: Bool = false
    var urls: [String]? = [String]()
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
    var isValid: (Bool, String) {
        get {
            
            if self.title.count < 2 {
                return (false, "Title must be minimum 2 characters")
            }

            if self.details.count < 2 {
                return (false, "Body must be minimum 2 characters")
            }
            
            if self.topic.count < 2 {
                return (false, "Topic must be minimum 2 characters")
            }
            
            return (true, "Success")
        }
    }
    
    
    func hasTitle() -> Bool {
        return self.title != "" && self.title != "Question title"
    }

    func hasBody() -> Bool {
        return self.details != "" && self.details != "Question details"
    }
    
    
    //MARK:- INITIALIZERS
    init(){
        
    }
    
    
    init(from snapshot: DataSnapshot, section: String, courseId: String) {
        
        let value = snapshot.value as! NSDictionary
        
        self.id = snapshot.key
        self.courseId = courseId
        self.section = section
        self.title = value["title"] as! String
        self.details = value["details"] as! String
        self.timestamp = value["timestamp"] as! Int
        self.answersCount = value["answer_count"] as! Int
        self.topic = value["topic"] as! String
        self.authorRepresentation = value["author"] as! [String: String]
        self.author = Member(
            name: authorRepresentation["name"]!,
            uid: authorRepresentation["uid"]!,
            image: authorRepresentation["image"] ?? ""
        )
        self.resolved = value["resolved"] as! Bool
        self.urls = value["urls"] as? [String]
    }
    
    
    func setAnonymous(){
        if self.author.name == "Anonymous" {
            self.author = Member(name: Auth.auth().currentUser!.displayName!, uid: Auth.auth().currentUser!.uid, image: UserDefaults.standard.string(forKey: "profile_url")!)
        } else {
            self.author = Member(name: "Anonymous", uid: UserDefaults.standard.string(forKey: "anonymousId")!, image: "")
        }
        self.authorRepresentation = self.author.authorRepresentation
    }
    
    
    static func getOne(of courseId: String, section: String, id: String, completion: @escaping(Question) -> Void) {
        FetchManager.getOne(
            databaseRef: Constants.questionsRef.child(courseId).child(section).child(id)
        ) { (snapshot) in
            if snapshot.hasChildren() {
                completion(Question(from: snapshot, section: section, courseId: courseId))
            } else {
                completion(Question())
            }
            
        }
    }
    
    
    static func getSectionQuestions(of courseId: String, of section: String, completion: @escaping([Question]) -> Void) {
        FetchManager.getAll(
            databaseRef: Constants.questionsRef.child(courseId).child(section).queryLimited(toLast: 100)
        ) { (snapshots) in
            completion(snapshots.map({ (snapshot) -> Question in
                return Question(from: snapshot, section: section, courseId: courseId)
            }))
        }
    }
    
    
    static func getAllQuestions(of courseId: String, completion: @escaping([Question]) -> Void) {
        FetchManager.getAll(
            databaseRef: Constants.questionsRef.child(courseId).child("0").queryLimited(toLast: 100)
        ) { (snapshots) in
            completion(snapshots.map({ (snapshot) -> Question in
                return Question(from: snapshot, section: "0", courseId: courseId)
            }))
        }
    }
}


extension Question {
    
    //MARK: Representation
    var newRepresentation: [String : Any] {[
        "title": self.title,
        "details": self.details,
        "timestamp": Int(Date().timeIntervalSince1970),
        "answer_count": 0,
        "topic": self.topic,
        "resolved": false,
        "author": self.author.authorRepresentation,
        "urls": self.urls ?? []
    ]}
    
    //MARK: Representation
    var editRepresentation: [String : Any] {[
        "author": self.author.authorRepresentation,
        "title": self.title,
        "body": self.details
    ]}
    
    
    
    //MARK: Functions
    func firebaseAdd(images: [UIImage], completion: @escaping(completionType) -> Void){
        DatabaseManager.createKey(
            databaseRef: Constants.questionsRef.child(self.courseId).child(self.section)
        ) { (key) in
            self.id = key
            if images.count > 0 {
                DatabaseManager.uploadImages(
                    storageRef: Constants.questionImagesRef.child(self.id),
                    childs: Array(0..<images.count).map({ (index) -> String in
                        return "\(index)"
                    }),
                    images: images,
                    index: 0,
                    image_urls: [:]
                ) { (results) in
                    self.urls = results.map { (args) -> String in
                        return args.value
                    }
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
    }
    
    
    private func setToDatabase(completion: @escaping(completionType) -> Void){
        DatabaseManager.create(
            databaseRef: Constants.questionsRef.child(self.courseId).child(self.section).child(self.id),
            object: self.newRepresentation) { (message) in
                self.follow()
                completion(message)
        }
    }
    
    
    //MARK: Functions
    func follow(){
        Constants.currentUserRef.child("notifications").child(self.id).setValue("question")
    }
    
    func unFollow(){
        Constants.currentUserRef.child("notifications").child(self.id).removeValue()
    }
    
    //MARK: Functions
    func firebaseDelete(completion: @escaping(completionType) -> Void){
        Constants.questionsRef.child(self.courseId).child(self.section).child(self.id).removeValue { (error, _) in
            self.unFollow()
            if error != nil {
                completion(.error)
            } else {
                completion(.success)
            }
        }
        
    }
    
    //MARK: Functions
    func firebaseEdit(completion: @escaping(completionType) -> Void){
        DatabaseManager.update(
        databaseRef: Constants.questionsRef.child(self.courseId).child(self.section).child(self.id), object: self.editRepresentation) { (message) in
            completion(message)
        }
    }
    
}
