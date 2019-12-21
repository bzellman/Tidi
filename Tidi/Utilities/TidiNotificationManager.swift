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
    let notificationCategoryIdentifer : String = "openCategory"
    
    func promptForPermisson() -> Void {
        currentNotificationCenter.requestAuthorization(options: [.alert, .sound]) { (isGranted, Error) in
            if isGranted {
                StorageManager().setNotificationAuthorizationState(isAuthorizationGranted: "allowed")
            } else {
                StorageManager().setNotificationAuthorizationState(isAuthorizationGranted: "notAllowed")
            }
        }
    }
    
    func setReminderNotification(identifier: String, notificationTrigger : UNCalendarNotificationTrigger, presentingView: NSWindow) {
        
//        currentNotificationCenter.delegate = self
        
        let trigger = notificationTrigger
        let closeNotification = UNNotificationAction(identifier: "dismiss", title: "Dismiss", options: [])
        let openNotnotificationAction = UNNotificationAction(identifier: "open", title: "Tidi Up", options: [.foreground])
        let categories = UNNotificationCategory(identifier: notificationCategoryIdentifer, actions: [ openNotnotificationAction, closeNotification], intentIdentifiers: [])
        currentNotificationCenter.setNotificationCategories([categories])
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Tidi"
        notificationContent.subtitle = "It's time to Tidi Up"
        notificationContent.sound = UNNotificationSound.default
        notificationContent.categoryIdentifier = notificationCategoryIdentifer
        
        
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
        if StorageManager().setReminderNotificationToUserDefaults(hour : 0, minute : 0, isPM : false, daysSetArray : [], isSet : false) == true {
            
            
            print("BEFORE:")
            getCurrentNotificationsFromNotificationCenter()
            
            currentNotificationCenter.getPendingNotificationRequests(completionHandler: { scheduledNotifications in
                var notificationIdentifiersToDelete:[String] = []
                for notificationIdentifier in scheduledNotifications {
                    if notificationIdentifier.identifier.contains(self.standardNotificationIdentiferString){
                        print("Should Delete: \(notificationIdentifier.identifier)")
                        notificationIdentifiersToDelete.append(notificationIdentifier.identifier)
                    }
                }
                
                self.currentNotificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIdentifiersToDelete)
                print("After:")
                self.getCurrentNotificationsFromNotificationCenter()
            })
            
            return true
        } else {
            alertManager.showPopUpAlertWithOnlyDismissButton(messageText: "There was an issue removing/resetting your notifications", informativeText: "Please try again", buttonText: "Okay")
            return false
        }
        
        
    }
    
    func checkForNotificationPermission() {
        currentNotificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized && settings.alertSetting == .enabled {
                    StorageManager().setNotificationAuthorizationState(isAuthorizationGranted: "allowed")
                }
                
                if settings.authorizationStatus == .denied {
                    StorageManager().setNotificationAuthorizationState(isAuthorizationGranted: "notAllowed")
                }
                
                if settings.authorizationStatus == .notDetermined {
                    StorageManager().setNotificationAuthorizationState(isAuthorizationGranted: "notSet")
                }
                
                return }
        }
    
    
    func getCurrentNotificationsFromNotificationCenter() {
       currentNotificationCenter.getPendingNotificationRequests(completionHandler: { scheduledNotifications in
           var notifications:[UNNotificationRequest] = []
           for notification in scheduledNotifications {
           if notification.identifier.contains(self.standardNotificationIdentiferString){
                   notifications.append(notification)
               }
           }

           for notification in notifications {
               print("Current Notification FROM Scheduler:" + (notification.trigger?.description ?? "nil"))
           }

       })
   }
}

    
      


