//
//  Event.swift
//  gostudy
//
//  Created by Kuanysh Anarbay on 11/15/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import RealmSwift

class Event : Object {

    
    static let realm = try! Realm()
    
    //MARK: IDENTTIFIER
    @objc dynamic var identifier : String = UUID().uuidString
    
    
    //MARK: REQUIRED DATA
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = staticList.randomColor
    @objc dynamic var icon : String = staticList.randomIcon
    @objc dynamic var start : Int = 0
    @objc dynamic var end : Int = 0
    var days : [Bool] = [false,false,false,false,false,false,false]
    var days_list = List<Bool>()
    
    
    //MARK: OPTIONAL DATA
    @objc dynamic var section : String = ""
    @objc dynamic var location : String = "Not specified"
    @objc dynamic var professor : String = "Not specified"
    @objc dynamic var reminder : Int = -1
    var notificationIds : List<String> = List<String>()
    var isValid: (Bool, String) {
        get {
            if self.name.count < 2 {
                return (false, "Please enter minimum 2 characters")
            }
            if self.end < self.start {
                return (false, "Starting time must be more than ending time")
            }
            if days.count != 7 && !days.contains(true) {
                return (false, "Please select minimum one day")
            }
            
            return (true, "Success")
        }
    }
    
    //MARK: PRIMARY KEY
    override class func primaryKey() -> String? {
        return "identifier"
    }
    
    
    
    func copyFrom(_ event: Event){
        identifier = event.identifier
        name = event.name
        color = event.color
        icon = event.icon
        start = event.start
        end = event.end
        days = event.days
        section = event.section
        location = event.location
        professor = event.professor
        reminder = event.reminder
        days_list = event.days_list
        notificationIds = event.notificationIds
    }
    
    
    //MARK: Add a local event
    func add(){
        if self.isValid.0 {
            do {
                try Event.realm.write {
                    self.days_list.removeAll()
                    for day in self.days {
                        self.days_list.append(day)
                    }
                }
            } catch {
                print("Error saving context: \(error)")
            }
            
            delete_notifications()
            add_notifications()
            let defaults = UserDefaults.standard
            var topics = defaults.stringArray(forKey: "topics")  ?? []
            var locations = defaults.stringArray(forKey: "locations")  ?? []
            var professors = defaults.stringArray(forKey: "professors")  ?? []
            
            if !topics.contains(self.name){
                topics.append(self.name)
            }
            if !locations.contains(self.location) && self.location.count > 0 {
                locations.append(self.location)
            }
            if !professors.contains(self.professor) && self.professor.count > 0 {
                professors.append(self.professor)
            }
            defaults.set(locations, forKey: "locations")
            defaults.set(topics, forKey: "topics")
            defaults.set(professors, forKey: "professors")
            
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
    
    
    private func delete_realm(){
        do {
            try realm?.write {
                realm?.delete(self)
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    //MARK: Add notifications
    private func add_notifications(){
        if reminder >= 0 {
            for i in 0 ..< self.days.count {
                if self.days[i] {
                    do {
                        try Event.realm.write {
                            self.notificationIds.append(UUID().uuidString)
                        }
                    } catch {
                        print("Error saving context: \(error)")
                    }
                    
                    let date = Date(timeIntervalSince1970: TimeInterval(start - reminder * 60))
                    
                    var dateComponents = DateComponents()
                    let calendar = Calendar.current
                    
                    dateComponents.calendar = Calendar.current
                    dateComponents.weekday = (i == 6) ? 1 : (i + 2)  //DAY
                    dateComponents.hour = calendar.component(.hour, from: date) // HOUR
                    dateComponents.minute = calendar.component(.minute, from: date) //MINUTE
                    dateComponents.second = 0
                    
                    let content = UNMutableNotificationContent()
                    
                    content.title =  self.name + ": " + (staticList.reminderList.first(where: {$0.1 == reminder})?.0 ?? "0 seconds") + " left"
                    content.body =  Helper.display12HourTime(timestamp: self.start) + " - " + Helper.display12HourTime(timestamp: self.end)
                                    + "\nLocation: " + self.location
                    content.sound = .default
                    content.categoryIdentifier = "routine"
                    content.badge = 1
                    
                    
                    Helper().scheduleNotification(
                        identifier: self.notificationIds.last!,
                        content: content,
                        dateComponents: dateComponents,
                        repeats: true
                    )
                }
            }
        }
    }
    
    
    //MARK: Delete all notifications
    private func delete_notifications(){
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: Array(self.notificationIds))
        center.removePendingNotificationRequests(withIdentifiers: Array(self.notificationIds))
        do {
            try Event.realm.write {
                self.notificationIds.removeAll()
            }
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
