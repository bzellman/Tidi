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
        
        getCurrentNotificationsFromPendingNotifications()
        

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func getCurrentNotificationsFromPendingNotifications() {
        
//        UNUserNotificationCenter.current().getPendingNotificationRequests { (scheduledNotificationsRequests) in
//            print("Schedule: ", scheduledNotificationsRequests)
//            for notification:UNNotificationRequest in scheduledNotificationsRequests {
//                print("Notification: ", notification)
//                if notification.identifier == "tidi_Reminder_Notification" {
//                    print("Trigger", notification.trigger as Any)
//                }
//            }
//        }
        
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
            var notificationIds:[String] = []
            for notification in notifications {
                if notification.identifier == "tidi_Reminder_Notification"{
                    notificationIds.append(notification.identifier)
                }
            }
            print("Notification: ", notificationIds)
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

