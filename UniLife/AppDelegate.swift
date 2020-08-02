//
//  AppDelegate.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 11/30/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import UserNotifications
import FirebaseMessaging




@UIApplicationMain
class AppDelegate: AppConfigurations, UIApplicationDelegate, UNUserNotificationCenterDelegate {


    var window: UIWindow?
    let center = UNUserNotificationCenter.current()
    var realm = try! Realm()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureFirebase()
        configureRealm()
        center.delegate = self
        
        if UserDefaults.standard.value(forKey: "options") == nil {
            UserDefaults.standard.set(launchOptions, forKey: "options")
        }
        
        if let options = launchOptions, let remoteNot = options[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any], let aps = remoteNot["aps"] as? [String: Any], let id = remoteNot["id"] as? String {
            
            let category = aps["category"] as! String
            handleRemoteNofication(category, id)
        } else {
            self.checkUser()
        }
    
    
        return true
    }
    
    
    func handleRemoteNofication(_ category: String, _ id: String){
        
        switch category {
        case "item":
            (self.window?.rootViewController as! UITabBarController).selectedIndex = 2
            let marketStoryboard = UIStoryboard(name: "Market", bundle: nil)
            let itemViewController = marketStoryboard.instantiateViewController(withIdentifier: "itemVC") as! ItemViewController
            itemViewController.item.id = id
            self.window?.rootViewController?.present(itemViewController, animated: true, completion: nil)
            
            break
        case "question":
            (self.window?.rootViewController as! UITabBarController).selectedIndex = 0
            let dashboardStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            
            let answerViewController = dashboardStoryboard.instantiateViewController(withIdentifier: "answerVC") as! AnswerViewController
            answerViewController.question.id = id
            (self.window?.rootViewController?.presentingViewController as! UINavigationController).popToViewController(answerViewController, animated: true)
            
            break
        case "event":
            (self.window?.rootViewController as! UITabBarController).selectedIndex = 3
            let clubStoryboard = UIStoryboard(name: "Club", bundle: nil)
            
            let eventViewController = clubStoryboard.instantiateViewController(withIdentifier: "eventVC") as! ClubEventViewController
            eventViewController.event.id = id
            self.window?.rootViewController?.present(eventViewController, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    
    
    func checkUser(){
        // MARK: Check current user
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        User.checkUser { (exists) in
           if exists {
               let initialViewController = storyboard.instantiateViewController(withIdentifier: "mainVC")
               self.window?.rootViewController = initialViewController
           } else {
               let initialViewController = storyboard.instantiateViewController(withIdentifier: "loginVC")
               self.window?.rootViewController = initialViewController
           }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.checkUser()
    }
    
    // MARK: UISceneSession Lifecycl
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            User.checkUser { (exists) in
                if exists {
                    User.registerToken(token: "\(result.token)")
                }
            }
          }
        }
      Messaging.messaging().apnsToken = deviceToken
        
    }
    
    func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void) {

        
        completionHandler(.newData)
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.sound, .alert])
    }
    
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse,
      withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
    
    
    

}


