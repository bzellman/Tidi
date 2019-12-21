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
        
        TidiNotificationManager().checkForNotificationPermission()
        getCurrentNotificationsFromNotificationCenter()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }


    
    func getCurrentNotificationsFromNotificationCenter() {
        print("started check for notifications in AppDelegate")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { scheduledNotifications in
            var notifications:[UNNotificationRequest] = []
            for notification in scheduledNotifications {
                if notification.identifier.contains("tidi_Reminder_Notification"){
                    notifications.append(notification)
                }
            }

            for notification in notifications {
                print("ADCheckNotification: ", notification.trigger?.description)
            }

        })
    }
    
    
    @IBAction func changeDefaultSourceFolderClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("changeDefaultSourceFolderNotification"), object: nil)
    }
    
    @IBAction func changeDefaultDestinationFolderClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("changeDefaultDestinationFolderNotification"), object: nil)
    }
    
    @IBAction func clearWeeklyRemindersClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("clearWeeklyReminderClickedNotification"), object: nil)
    }
    
    
    
    
    

    
}
