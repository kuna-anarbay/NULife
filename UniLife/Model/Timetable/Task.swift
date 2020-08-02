//
//  Task.swift
//  gostudy
//
//  Created by Kuanysh Anarbay on 11/15/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import RealmSwift

class Task : Object {
    
    //MARK: IDENTTIFIER
    @objc dynamic var identifier : String = UUID().uuidString
    @objc dynamic let icon : String = "bell.circle.fill"
    
    //MARK: REQUIRED DATA
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = "#00A89D"
    @objc dynamic var start : Int = 0
    
    
    //MARK: OPTIONAL DATA
    @objc dynamic var end : Int = -1
    @objc dynamic var location : String = "Not specified"
    @objc dynamic var topic : String = "Personal"
    @objc dynamic var reminder : Int = -1
    @objc dynamic var note : String = ""
    var notificationIds : List<String> = List<String>()
    var isValid: (Bool, String) {
        get {
            if self.name.count < 2 {
                return (false, "Please enter minimum 2 characters")
            }
            
            if self.end != -1 && self.end < self.start {
                return (false, "Starting time must be more than ending time")
            }
            
            if self.start < Int(Date().timeIntervalSince1970) + 15*60 {
                return (false, "Starting time must be minimum 15 from now")
            }
            return (true, "Success")
        }
    }
    
    //MARK: PRIMARY KEY
    override class func primaryKey() -> String? {
        return "identifier"
    }
    
    
    func copyFrom(_ task: Task){
        identifier = task.identifier
        name = task.name
        color = task.color
        start = task.start
        end = task.end
        topic = task.topic
        location = task.location
        note = task.note
        reminder = task.reminder
        notificationIds = task.notificationIds
    }
    
    
    //MARK: Add a local event
    func add(){
        if isValid.0 {
            delete_notifications()
            add_notifications()
            let defaults = UserDefaults.standard
            var topics = defaults.stringArray(forKey: "topics")  ?? []
            var locations = defaults.stringArray(forKey: "locations")  ?? []
            
            if !topics.contains(self.topic){
                topics.append(self.topic)
            }
            if !locations.contains(self.location) && self.location.count > 0 {
                locations.append(self.location)
            }
            defaults.set(locations, forKey: "locations")
            defaults.set(topics, forKey: "topics")
            
            add_realm()
        }
    }
    
    
    //MARK: Add a local event
    func delete(){
        delete_notifications()
        delete_realm()
    }
    
    //MARK: Add to realm
    private func add_realm(){
        do {
            try Event.realm.write {
                Event.realm.add(self, update: .all)
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    
    
    //MARK: Delete from realm
    private func delete_realm(){
        do {
            try Event.realm.write {
                Event.realm.delete(self)
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    
    //MARK: Add notifications
    private func add_notifications(){
        if reminder >= 0 {
            do {
                try Event.realm.write {
                    self.notificationIds.append(UUID().uuidString)
                }
            } catch {
                print("Error saving context: \(error)")
            }
            
            let date = Date(timeIntervalSince1970: TimeInterval(start - reminder * 60))
            
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
            let content = UNMutableNotificationContent() 
            
            content.title = self.name + ": " + staticList.reminderList.first(where: {$0.1 == self.reminder})!.0 + " left"
            content.body =  Helper.display12HourTime(timestamp: self.start) + " - " + Helper.display12HourTime(timestamp: self.end)
                            + "\nLocation: " + self.location
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "task"
            content.badge = 1
            
            
            Helper().scheduleNotification(
                identifier: self.notificationIds.last!,
                content: content,
                dateComponents: triggerDate,
                repeats: false
            )
        }
    }
    
    
    //MARK: Delete all notifications
    private func delete_notifications(){
        do {
            try Event.realm.write {
                self.notificationIds.removeAll()
            }
        } catch {
            print("Error saving context: \(error)")
        }
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: Array(self.notificationIds))
        center.removePendingNotificationRequests(withIdentifiers: Array(self.notificationIds))
    }
}
