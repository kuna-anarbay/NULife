//
//  Event.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/21/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase

class ClubEvent {
    
    var id: String = ""
    var title: String = ""
    var club: [String: String] = [:]
    var details: String = ""
    var timestamp: Int = 0
    var start: Int = 0
    var end: Int = 0
    var location: String = ""
    var registration: [String: Any]? = [:]
    var urls: [String] = []
    var reminder: Int = -1
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
    
    func add(){
        Task(value: [
            "identifier": self.id,
            "name": self.title,
            "start": self.start,
            "end": self.end,
            "location": self.location,
            "topic": self.club["title"]!,
            "color": staticList.randomColor,
            "note": self.details,
            "reminder": self.reminder
        ]).add()
    }

    
    
    init(){
           
    }
       
       
    init(snapshot: DataSnapshot) {
       
        let value = snapshot.value as! NSDictionary
       
        self.id = snapshot.key
        self.club = value["club"] as! [String: String]
        self.title = value["title"] as! String
        self.details = value["details"] as! String
        self.timestamp = value["timestamp"] as! Int
        self.start = value["start"] as! Int
        self.end = value["end"] as? Int ?? 0
        self.location = value["location"] as? String ?? "Not specified"
        self.registration = value["registration"] as? [String: Any]
        self.urls = value["urls"] as! [String]
    }
    
    
    static func getAll(_ clubId: String?, completion: @escaping([ClubEvent]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.eventsRef) { (snapshots) in
            var events = [ClubEvent]()
            snapshots.forEach { (snapshot) in
                let event = ClubEvent(snapshot: snapshot)
                if clubId == nil || event.club["id"] == clubId {
                    events.append(event)
                }
            }
            completion(events)
        }
    }
    
    static func getAll(_ clubIds: [String], completion: @escaping([ClubEvent]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.eventsRef) { (snapshots) in
            var events = [ClubEvent]()
            snapshots.forEach { (snapshot) in
                let event = ClubEvent(snapshot: snapshot)
                if event.start > Int(Date().timeIntervalSince1970) && clubIds.contains(event.club["id"]!) {
                    events.append(event)
                }
            }
            completion(events)
        }
    }
    
    
    static func getOne(_ id: String,completion: @escaping(ClubEvent) -> Void){
        FetchManager.getOne(databaseRef: Constants.eventsRef.child(id)) { (snapshot) in
            if snapshot.hasChildren() {
                completion(ClubEvent(snapshot: snapshot))
            } else {
                completion(ClubEvent())
            }
            
        }
    }
}
