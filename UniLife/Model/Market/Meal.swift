//
//  Meal.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/16/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import Firebase



class Meal {
    
    var id: String = ""
    var cafeId: String = ""
    var title: String = ""
    var price: Int = 0
    var details: String? = ""
    var type: String = ""
    var urls: [String: String] = [:]
    var days: [String: [String: Int]] = [:]
    var lastAvailable: Int = 0
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
    var lastAvailableText: String {
        get {
            let weekDay = Calendar.current.component(.weekday, from: Date()) > 1 ? Calendar.current.component(.weekday, from: Date()) - 2 : 6
            let today = staticList.weekDays[weekDay]
            let nextDay = staticList.weekDays[weekDay == 6 ? 0 : weekDay + 1]
            let currentTime = Helper.displayHourMinuteTimestamp(timestamp: Int(Date().timeIntervalSince1970))
            
            if self.days[today] != nil {
                if currentTime < self.days[today]!["start"]! {
                    return "Will be available at " + Helper.display24HourTimeGMT0(timestamp: self.days[today]!["start"]!)
                } else if currentTime < self.days[today]!["end"]! {
                    if self.days[today]!["end"]! - currentTime > 3600 {
                        return "Available in one hour"
                    } else {
                        return "Will be not available at " + Helper.display24HourTimeGMT0(timestamp: self.days[today]!["end"]!)
                    }
                } else if self.days[nextDay]!["start"]! != self.days[nextDay]!["end"]! {
                    return "Available tomorrow at " + Helper.display24HourTimeGMT0(timestamp: self.days[nextDay]!["start"]!)
                } else {
                    return "Not available"
                }
            } else {
                if Int(Date().timeIntervalSince1970) - self.lastAvailable < 6*60*60 {
                    return "Last available " + Helper.getReverse(timestamp: self.lastAvailable)
                } else {
                    return "Last available at " + Helper.display24HourTime(timestamp: self.lastAvailable)
                }
            }
        }
    }
    var isAvailable: Bool {
        get{
            let weekDay = Calendar.current.component(.weekday, from: Date()) > 1 ? Calendar.current.component(.weekday, from: Date()) - 2 : 6
            let today = staticList.weekDays[weekDay]
            let currentTime = Helper.displayHourMinuteTimestamp(timestamp: Int(Date().timeIntervalSince1970))
            
            if self.days[today] != nil {
                return self.days[today]!["start"]! < currentTime && self.days[today]!["end"]! > currentTime
            } else {
                return Int(Date().timeIntervalSince1970) - self.lastAvailable < 6*60*60
            }
        }
    }
    var discountedPrice: Int = 0
    var discount: Int {
        get {
            if discountedPrice == 0 {
                return 100
            } else {
                return ((self.price - self.discountedPrice)*100)/self.discountedPrice
            }
        }
    }
    
    
    init(){
        
    }
    init(snapshot: DataSnapshot, cafeId: String) {
        
        let value = snapshot.value as! NSDictionary
        
        self.id = snapshot.key
        self.cafeId = cafeId
        self.title = value["title"] as! String
        self.price = value["price"] as! Int
        self.details = value["details"] as? String
        self.type = value["type"] as? String ?? ""
        self.days = value["days"] as? [String: [String: Int]] ?? [:]
        self.lastAvailable = value["last_available"] as? Int ?? 0
        self.urls = value["urls"] as? [String: String] ?? [:]
        self.discountedPrice = value["discounted_price"] as! Int
    }
    
    
    static func getActive(cafeId: String, completion: @escaping([Meal]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.mealsRef.child(cafeId)) { (snapshots) in
            var meals = [Meal]()
            snapshots.forEach { (snapshot) in
                let meal = Meal(snapshot: snapshot, cafeId: cafeId)
                if meal.isAvailable {
                    meals.append(meal)
                }
            }
            completion(meals)
        }
    }
    
    
    static func getOther(cafeId: String, completion: @escaping([Meal]) -> Void) {
        FetchManager.getAll(databaseRef: Constants.mealsRef.child(cafeId)) { (snapshots) in
            var meals = [Meal]()
            snapshots.forEach { (snapshot) in
                if snapshot.hasChildren() {
                    let meal = Meal(snapshot: snapshot, cafeId: cafeId)
                    if !meal.isAvailable {
                        meals.append(meal)
                    }
                }
            }
            completion(meals)
        }
    }
}
