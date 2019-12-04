//
//  TidiNotificationManager.swift
//  Tidi
//
//  Created by Brad Zellman on 12/3/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa
import UserNotifications

class TidiNotificationManager: NSObject {
    
    let currentNotificationCenter = UNUserNotificationCenter.current()
    let standardNotificationIdentiferString : String = "tidi_Reminder_Notification"
    let alertManager = AlertManager()
    
    func setReminderNotification(identifier: String, notificationTrigger : UNCalendarNotificationTrigger, presentingView: NSWindow) {
        
        let trigger = notificationTrigger
        let notificationContent = UNMutableNotificationContent()
        var reminderWasSuccessful : Bool = false
        notificationContent.title = "Tidi"
        notificationContent.subtitle = "It's time to Tidi Up"
        notificationContent.sound = UNNotificationSound.default
        
//        let closeNotificationAction = UNNotificationAction(identifier: "close", title: "Close", options: UNNotificationActionOptions(rawValue: 0))
        //To-do: Build in Remind Me Later functionality
//        let openNotnotificationAction = UNNotificationAction(identifier: "open", title: "Tidi Up!", options: UNNotificationActionOptions(rawValue: 1))
        
        
        
        let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        
        
        currentNotificationCenter.add(request) {(error) in
            if let error = error {
                print(error as Any)
                self.alertManager.showSheetAlertWithOnlyDismissButton(messageText: "Looks like something went wrong setting your reminder. \n\nPlease try again", buttonText: "Okay", presentingView: presentingView)
                self.removeAllScheduledNotifications()
            }
        }
        
    }
    
    
    func removeAllScheduledNotifications() -> Bool {
        StorageManager().setReminderNotificationToUserDefaults(hour : 0, minute : 0, isPM : false, daysSetArray : [], isSet : false)
        
        var notificationIdentifiersToDelete:[String] = []
        
        currentNotificationCenter.getPendingNotificationRequests(completionHandler: { scheduledNotifications in
            for notificationIdentifier in scheduledNotifications {
                if notificationIdentifier.identifier.contains(self.standardNotificationIdentiferString){
                    notificationIdentifiersToDelete.append(notificationIdentifier.identifier)
                }
            }
            
        })
        
        currentNotificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIdentifiersToDelete)
        
        
        return true
        //ToDo: build in error handling for false
    }

    
//       func getCurrentNotificationsFromNotificationCenter() {
//            currentNotificationCenter.getPendingNotificationRequests(completionHandler: { scheduledNotifications in
//                var notifications:[UNNotificationRequest] = []
//                for notification in scheduledNotifications {
//                    if notification.identifier.contains(self.standardNotificationIdentiferString){
//                        notifications.append(notification)
//                    }
//                }
//
//    //            for notification in notifications {
//    //                print("TSVCNotification: ", notification.trigger?.description)
//    //            }
//
//            })
//}
}
