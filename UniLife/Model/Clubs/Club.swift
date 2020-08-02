//
//  Club.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/21/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase

class Club {

    var id: String = ""
    var title: String = ""
    var details: String = ""
    var membership: String = ""
    var contacts: [[String: String]]? = []
    var heads: [String: [String: String]]? = [:]
    var followers: [String: [String: String]]? = [:]
    var urls: [String: String] = [:]
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
    
    
    init(){
            
    }
    
    init(shortSnapshot: DataSnapshot){
        self.id = shortSnapshot.key
        let value = shortSnapshot.value as! [String: String]
        self.urls["logo"] = value["logo"] ?? ""
        self.title = value["title"] ?? ""
    }
        
        
    init(snapshot: DataSnapshot) {
        
        let value = snapshot.value as! NSDictionary
        
        self.id = snapshot.key
        self.title = value["title"] as! String
        self.details = value["details"] as? String ?? ""
        self.membership = value["membership"] as? String ?? ""
        self.urls = value["urls"] as? [String: String] ?? [:]
        self.contacts = value["contacts"] as? [[String: String]]
        self.heads = value["heads"] as? [String: [String: String]]
        self.followers = value["followers"] as? [String: [String: String]]
    }
    
    
    func follow(completion: @escaping(completionType) -> Void){
        Constants.userClubsRef.child(self.id).setValue([
            "title": self.title,
            "logo": self.urls["logo"] ?? ""
        ]) { (error, _) in
            if error != nil {
                completion(.error)
            } else {
                Constants.currentUserRef.child("notifications").child(self.id).setValue("club") { (error, _) in
                    if error != nil {
                        completion(.error)
                    } else {
                        completion(.success)
                    }
                }
            }
        }
    }
    
    func unFollow(completion: @escaping(completionType) -> Void){
        Constants.userClubsRef.child(self.id).removeValue { (error, _) in
            if error != nil {
                completion(.error)
            } else {
                Constants.currentUserRef.child("notifications").child(self.id).removeValue { (err, _) in
                    if err != nil {
                        completion(.error)
                    } else {
                        completion(.success)
                    }
                }
            }
        }
    }
    
    
    static func getAll(completion: @escaping([Club]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.clubsShortRef) { (snapshots) in
            completion(snapshots.map({ (snapshot) -> Club in
                return Club(shortSnapshot: snapshot)
            }))
        }
    }
    
    
    static func getUserClubs(completion: @escaping([Club]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.userClubsRef) { (snapshots) in
            completion(snapshots.map({ (snapshot) -> Club in
                return Club(shortSnapshot: snapshot)
            }))
        }
    }
    
    
    static func getOne(_ id: String, completion: @escaping(Club) -> Void){
        FetchManager.getOne(databaseRef: Constants.clubsRef.child(id)) { (snapshot) in
            if snapshot.hasChildren() {
                completion(Club(snapshot: snapshot))
            } else {
                completion(Club())
            }
        }
    }
}
