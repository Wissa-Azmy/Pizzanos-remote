//
//  AppDelegate.swift
//  Pizzanos remote
//
//  Created by Wissa Azmy on 4/8/19.
//  Copyright © 2019 Wissa Azmy. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        requestNotificationsAuthorization(to: application)
        setCategories()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // MARK: - Notifications methods
    func requestNotificationsAuthorization(to application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                // Show alert to the user
                print("User notification permission denied: \(error!.localizedDescription)")
            }
        }
    }
    
    func setCategories() {
        let snooze = UNNotificationAction(identifier: "snooze.action", title: "Snooze", options: [])
        let category = UNNotificationCategory(identifier: "pizza.category", actions: [snooze], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // TODO: Add code here to deal with tokens
        print("Notification registration Successful: ")
        print(stringifyToken(deviceToken))
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func stringifyToken (_ deviceToken: Data) -> String {
        let bytes = [UInt8](deviceToken)
        let token = bytes.map({String(format: "%02x", $0)}).joined()
        
        return token
    }

}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let action = response.actionIdentifier
        let request = response.notification.request
        
        if action == "snooze.action" {
            let snoozeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
            let newRequest = UNNotificationRequest(identifier: "pizza.snooze", content: request.content, trigger: snoozeTrigger)
            UNUserNotificationCenter.current().add(newRequest) { (error) in
                if error != nil {
                    print("Error snoozing your notification: \(error!.localizedDescription)")
                }
            }
        }
        
        completionHandler()
    }
}

