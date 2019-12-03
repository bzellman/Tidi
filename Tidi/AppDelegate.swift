//
//  AppDelegate.swift
//  Tidi
//
//  Created by Brad Zellman on 8/11/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Cocoa
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //Set Notification.plist from existing Notifcations when application launched
        
        getCurrentNotificationsFromNotificationCenter()
        

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func getCurrentNotificationsFromNotificationCenter() {
        print("ADWORKING")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { scheduledNotifications in
            var notifications:[UNNotificationRequest] = []
            for notification in scheduledNotifications {
                if notification.identifier.contains("tidi_Reminder_Notification"){
                    notifications.append(notification)
                }
            }
            
            for notification in notifications {
                print("ADNotification: ", notification.trigger?.description)
            }
            
        })
    }
    
    
    @IBAction func changeDefaultSourceFolderClicked(_ sender: Any) {
//        NotificationCenter.default.post(Notification.Name(rawValue: "changeDefaultSourceFolderNotification"), object: nil, userInfo: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name("changeDefaultSourceFolderNotification"), object: nil)
    }
    
    @IBAction func changeDefaultDestinationFolderClicked(_ sender: Any) {
               NotificationCenter.default.post(name: NSNotification.Name("changeDefaultDestinationFolderNotification"), object: nil)
    }
    
    @IBAction func clearWeeklyRemindersClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("clearWeeklyReminderClickedNotification"), object: nil)
    }
    
    
    
    
    

    
}



// Extension tell app to be able to get notification when in use and also for extensions
//extension AppDelegate: NSUserNotificationCenterDelegate {
////    func userNotificationCenter(_ center: NSUserNotificationCenter, willPresent notification: NSNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
////        completionHandler(.alert)
//}

