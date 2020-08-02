//
//  InitialSetups.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 2/3/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import RealmSwift
import UserNotifications
import Firebase
import FirebaseMessaging


enum Identifiers {
    static let questionCategory = "question"
    static let eventCategory = "event"
    static let itemCategory = "item"
    static let taskCategory = "task"
    static let routineCategory = "routine"
}

class AppConfigurations: UIResponder {
    
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    //MARK: Configure firebase
    func configureFirebase(){
        
        FirebaseApp.configure()
        
        Database.database().isPersistenceEnabled = true
    }
    
    
    // MARK: Configure Realm
    func configureRealm(){
        let realmDirectory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kuanysh-anarbay.unilife.realm")!
                let realmPath = realmDirectory.appendingPathComponent("db.realm").absoluteURL
        var config = Realm.Configuration()
        config.fileURL = realmPath
        Realm.Configuration.defaultConfiguration = config
    }
    
    
    //MARK: registerForPushNotifications
    func registerForPushNotifications() {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) {  granted, error in
            
          print("Permission granted: \(granted)")
          guard granted else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    
    
    //MARK: registerPushNotificationCategories
    func registerPushNotificationCategories() {
        
      //MARK: Notification topics
      let openAction = UNNotificationAction(identifier: "OpenTimeTable", title: "Open", options: .foreground)
      //TODO: Task notifications
      let taskHiddenPreviewsPlaceholder = "%u tasks need to be done"
      let taskSummaryFormat = "%u more tasks of %@"
      
      let taskCategory = UNNotificationCategory(identifier: Identifiers.taskCategory, actions: [openAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: taskHiddenPreviewsPlaceholder, categorySummaryFormat: taskSummaryFormat, options: [])
      
      //TODO: Routine notifications
      let routineHiddenPreviewsPlaceholder = "%u routines need to be done"
      let routineSummaryFormat = "%u more routines of %@"
        let routineCategory = UNNotificationCategory(identifier: Identifiers.routineCategory, actions: [openAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: routineHiddenPreviewsPlaceholder, categorySummaryFormat: routineSummaryFormat, options: [])
        
        
        let eventCategory = UNNotificationCategory(
        identifier: Identifiers.eventCategory, actions: [],
        intentIdentifiers: [], options: [])
        
        let questionCategory = UNNotificationCategory(
        identifier: Identifiers.questionCategory, actions: [],
        intentIdentifiers: [], options: [])
        
        let itemCategory = UNNotificationCategory(
        identifier: Identifiers.itemCategory, actions: [],
        intentIdentifiers: [], options: [])
      
      //TODO: Register notification topics
      notificationCenter.setNotificationCategories([itemCategory, questionCategory, eventCategory, taskCategory, routineCategory])
    }
    
}
