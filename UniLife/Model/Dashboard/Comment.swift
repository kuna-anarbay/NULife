//
//  Comment.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/2/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase


class Comment {
    
    var id = String()
    var author = Member(
        name: "Anonymous",
        uid: UserDefaults.standard.string(forKey: "anonymousId")!,
        image: ""
    )
    var authorRepresentation : [String: String] = [:]
    var body = String()
    var timestamp = 0
    var isValid: (Bool, String) {
        get {
            
            if self.body.count < 2 {
                return (false, "Message must be minimum 2 characters")
            }
            
            return (true, "Success")
        }
    }
    
    init() {
        
    }
    
    init(from dictionary: NSDictionary.Element) {
        let value = dictionary.value as! NSDictionary
        self.id = dictionary.key as! String
        self.authorRepresentation = value["author"] as! [String: String]
        self.author = Member(
            name: authorRepresentation["name"]!,
            uid: authorRepresentation["uid"]!,
            image: authorRepresentation["image"] ?? ""
        )
        self.body = value["body"] as! String
        self.timestamp = value["timestamp"] as! Int
    }
    
    
    func setAnonymous(){
        if self.author.name == "Anonymous" {
            self.author = Member(name: Auth.auth().currentUser!.displayName!, uid: Auth.auth().currentUser!.uid, image: UserDefaults.standard.string(forKey: "profile_url")!)
        } else {
            self.author = Member(name: "Anonymous", uid: UserDefaults.standard.string(forKey: "anonymousId")!, image: "")
        }
        self.authorRepresentation = self.author.authorRepresentation
    }
}

extension Comment {
    
    //MARK: Representation
    var newRepresentation: [String : Any] {[
        "author": self.author.authorRepresentation,
        "timestamp": Int(Date().timeIntervalSince1970),
        "body": self.body
    ]}
    
    //MARK: Representation
    var editRepresentation: [String : Any] {[
        "author": authorRepresentation,
        "body": self.body
    ]}
    
    
    
    //MARK: Functions
    func firebaseAdd(answer: Answer, completion: @escaping(completionType) -> Void){
        let reference = Constants.answersRef.child(answer.courseId).child(answer.sectionId)
        .child(answer.questionId).child(answer.id).child("comments")
        DatabaseManager.createKey(databaseRef: reference) { (key) in
            self.id = key
            DatabaseManager.create(
                databaseRef: reference.child(self.id),
                object: self.newRepresentation) { (message) in
                    completion(message)
            }
        }
    }
    
    //MARK: Functions
    func firebaseEdit(answer: Answer, completion: @escaping(completionType) -> Void){
        let reference = Constants.answersRef.child(answer.courseId).child(answer.sectionId)
            .child(answer.questionId).child(answer.id).child("comments").child(self.id)
        DatabaseManager.update(
            databaseRef: reference,
            object: self.editRepresentation) { (message) in
                completion(message)
        }
    }
    
    //MARK: Functions
    func firebaseDelete(answer: Answer, completion: @escaping(completionType) -> Void){
        Constants.answersRef.child(answer.courseId).child(answer.sectionId)
            .child(answer.questionId).child(answer.id).child("comments").child(self.id).removeValue { (error, _) in
                if error != nil {
                    completion(.error)
                } else {
                    completion(.success)
                }
        }
    }
    
}
