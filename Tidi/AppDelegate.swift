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

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

// Extension tell app to be able to get notification when in use and also for extensions
//extension AppDelegate: NSUserNotificationCenterDelegate {
////    func userNotificationCenter(_ center: NSUserNotificationCenter, willPresent notification: NSNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
////        completionHandler(.alert)
//}

