//
//  SceneDelegate.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 11/30/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import SPAlert


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL,
          let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        
        if let query = components.queryItems?.first(where: { (item) -> Bool in
            return item.name == "mode"
        })?.value {
            if query == "resetPassword" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let signUpViewController = storyboard.instantiateViewController(withIdentifier: "signUpVC") as! SignUpViewController
                if let code = components.queryItems?.first(where: { (item) -> Bool in
                    return item.name == "oobCode"
                })?.value {
                    signUpViewController.oobCode = code
                }
                signUpViewController.resetState = true
                self.window?.rootViewController?.presentedViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
                self.window?.rootViewController?.presentedViewController?.present(signUpViewController, animated: true, completion: nil)
            
            } else {
                if let code = components.queryItems?.first(where: { (item) -> Bool in
                    return item.name == "oobCode"
                })?.value {
                    Auth.auth().applyActionCode(code) { (error) in
                        if let error = error {
                            SPAlert.present(title: error.localizedDescription, preset: .error)
                        } else {
                            Auth.auth().currentUser?.reload(completion: { (error) in
                                if let error = error {
                                    SPAlert.present(title: error.localizedDescription, preset: .error)
                                } else {
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainVC") as! LoginViewController
                                   self.window?.rootViewController?.presentedViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
                                    self.window?.rootViewController?.presentedViewController?.present(mainViewController, animated: true, completion: nil)
                                    
                                }
                            })
                        }
                    }
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        User.checkUser { (exists) in
            if exists {
                Constants.currentUserRef.child("notifications").observe(.value) { (snapshot) in
                    var notifications : [String: String] = [:]
                    var liked = UserDefaults.standard.stringArray(forKey: "likedItems")
                    
                    for child in snapshot.children {
                        let value = child as! DataSnapshot
                        notifications[value.key] = value.value as? String
                        if let type = value.value as? String, !(liked?.contains(type) ?? false){
                            liked?.append(value.key)
                        }
                    }
                    UserDefaults.standard.set(liked, forKey: "likedItems")
                    UserDefaults.standard.set(notifications, forKey: "notifications")
                    
                }
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        User.checkUser { (exists) in
            if exists {
                switch shortcutItem.type {
                case "com.kuna-anarbay.newtask":
                    let storyboard = UIStoryboard(name: "Timetable", bundle: nil)
                    let newTask = storyboard.instantiateViewController(withIdentifier: "newTaskVC") as! AddEventViewController
                    self.window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
                    if let tabBarController = self.window!.rootViewController as? UITabBarController {
                        tabBarController.selectedIndex = 1
                    }
                    
                    self.window?.rootViewController?.present(newTask, animated: true, completion: nil)
                    break
                case "com.kuna-anarbay.newevent":
                    let storyboard = UIStoryboard(name: "Timetable", bundle: nil)
                    let newRoutine = storyboard.instantiateViewController(withIdentifier: "newRoutineVC") as! AddLessonViewController
                    self.window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
                    if let tabBarController = self.window!.rootViewController as? UITabBarController {
                        tabBarController.selectedIndex = 1
                    }
                    
                    self.window?.rootViewController?.present(newRoutine, animated: true, completion: nil)
                    break
                case "com.kuna-anarbay.saveditems":
                    let storyboard = UIStoryboard(name: "Market", bundle: nil)
                    let navController = storyboard.instantiateViewController(identifier: "showFav") as! UINavigationController
                    let likedViewController = navController.viewControllers[0]
                    self.window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
                    if let tabBarController = self.window!.rootViewController as? UITabBarController {
                        tabBarController.selectedIndex = 4
                    }
                    
                    let tabController = self.window?.rootViewController as! UITabBarController
                    let profileController = (tabController.viewControllers?[4] as! UINavigationController).viewControllers[0]
                    profileController.show(likedViewController, sender: nil)
                    break
                case "routine":
                    self.window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
                    if let tabBarController = self.window!.rootViewController as? UITabBarController {
                        tabBarController.selectedIndex = 1
                    }
                    break
                case "task":
                    self.window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
                    if let tabBarController = self.window!.rootViewController as? UITabBarController {
                        tabBarController.selectedIndex = 1
                    }
                    break
                default:
                    break
                }
            }
        }
    }

}

