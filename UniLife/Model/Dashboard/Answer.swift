//
//  Answer.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/2/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase
import YPImagePicker


class Answer {

    var courseId = String()
    var sectionId = String()
    var questionId = String()
    var id = String()
    var author = Member(
        name: "Anonymous",
        uid: UserDefaults.standard.string(forKey: "anonymousId")!,
        image: ""
    )
    var authorRepresentation : [String: String] = [:]
    var timestamp = 0
    var body = String()
    var urls: [String]? = [String]()
    var votes: [String: Bool]? = [:]
    var comments: [Comment]? = [Comment]()
    var isValid: (Bool, String) {
        get {
            
            if self.body.count < 2 {
                return (false, "Body must be minimum 2 characters")
            }
            
            return (true, "Success")
        }
    }
    var notNull: Bool {
        get {
            if self.id.count == 0 {
                return false
            }
            if self.body.count == 0 {
                return false
            }
            return true
        }
    }
    
    
    init() {
        
    }
    
    init(_ snapshot: DataSnapshot, courseId: String, sectionId: String, questionId: String) {
        
        let value = snapshot.value as! NSDictionary
        
        self.courseId = courseId
        self.sectionId = sectionId
        self.questionId = questionId
        self.id = snapshot.key
        self.authorRepresentation = value["author"] as! [String: String]
        self.author = Member(
            name: authorRepresentation["name"]!,
            uid: authorRepresentation["uid"]!,
            image: authorRepresentation["image"]!
        )
        self.timestamp = value["timestamp"] as! Int
        self.body = value["body"] as! String
        self.urls = value["urls"] as? [String]
        (value["votes"] as? [String: [String: Bool]])?.forEach({ (args) in
            self.votes?[args.key] = args.value.first!.value
        })
        self.comments = (value["comments"] as? NSDictionary)?.map({ (args) -> Comment in
            return Comment(from: args)
        })
    }
    
    
    func setAnonymous(){
        if self.author.name == "Anonymous" {
            self.author = Member(name: Auth.auth().currentUser!.displayName!, uid: Auth.auth().currentUser!.uid, image: UserDefaults.standard.string(forKey: "profile_url")!)
        } else {
            self.author = Member(name: "Anonymous", uid: UserDefaults.standard.string(forKey: "anonymousId")!, image: "")
        }
        self.authorRepresentation = self.author.authorRepresentation
    }
    
    
    static func getAllAnswers(of courseId: String, sectionId: String, questionId: String, completion: @escaping([Answer]) -> Void) {
        FetchManager.getAll(
            databaseRef: Constants.answersRef.child(courseId).child(sectionId).child(questionId)
        ) { (snapshots) in
            completion(snapshots.map({ (snapshot) -> Answer in
                return Answer(snapshot, courseId: courseId, sectionId: sectionId, questionId: questionId)
            }))
        }
    }
    
    
    static func getOne(of courseId: String, sectionId: String, questionId: String, id: String, completion: @escaping(Answer) -> Void) {
        FetchManager.getOne(
            databaseRef: Constants.answersRef.child(courseId).child(sectionId).child(questionId).child(id)
        ) { (snapshot) in
            if snapshot.hasChildren() {
                completion(Answer(snapshot, courseId: courseId, sectionId: sectionId, questionId: questionId))
            } else {
                completion(Answer())
            }
            
        }
    }
    
}


extension Answer {
    
    //MARK: Representation
    var newRepresentation: [String : Any] {[
        "author": self.author.authorRepresentation,
        "timestamp": Int(Date().timeIntervalSince1970),
        "body": self.body,
        "urls": self.urls ?? [],
    ]}
    
    var editRepresentation: [String : Any] {[
        "author": self.authorRepresentation,
        "body": self.body
    ]}
    
    
    var setAuthorRepresentation: [String : Any] {[
        "author": self.authorRepresentation
    ]}
    
    
    
    //MARK: Functions
    func firebaseAdd(images: [UIImage], completion: @escaping(completionType) -> Void){
        
        DatabaseManager.createKey(
            databaseRef: Constants.answersRef.child(self.courseId).child(self.sectionId).child(self.questionId)
        ) { (key) in
            self.id = key
            if images.count > 0 {
                DatabaseManager.uploadImages(
                    storageRef: Constants.answersImagesRef.child(self.id),
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
    }
    
    
    private func setToDatabase(completion: @escaping(completionType) -> Void){
        DatabaseManager.create(
            databaseRef: Constants.answersRef.child(self.courseId).child(self.sectionId)
                .child(self.questionId).child(self.id),
            object: self.newRepresentation) { (message) in
                completion(message)
        }
    }
    
    //MARK: Functions
    func firebaseDelete(completion: @escaping(completionType) -> Void){
        Constants.answersRef.child(self.courseId).child(self.sectionId)
            .child(self.questionId).child(self.id).removeValue { (error, _) in
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
            databaseRef: Constants.answersRef.child(self.courseId).child(self.sectionId)
                .child(self.questionId).child(self.id),
            object: self.editRepresentation) { (message) in
                completion(message)
        }
    }
    
    func setFirebaseAnonymous(completion: @escaping(completionType) -> Void){
        DatabaseManager.update(
            databaseRef: Constants.answersRef.child(self.courseId).child(self.sectionId)
                .child(self.questionId).child(self.id),
            object: self.setAuthorRepresentation) { (message) in
                completion(message)
        }
    }
}

