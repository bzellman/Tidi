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
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
/// To bring back for Menu Bar Enhancements
//    @IBAction func changeDefaultSourceFolderClicked(_ sender: Any) {
//        NotificationCenter.default.post(name: NSNotification.Name("changeDefaultSourceFolderNotification"), object: nil)
//    }
//    
//    @IBAction func changeDefaultDestinationFolderClicked(_ sender: Any) {
//        NotificationCenter.default.post(name: NSNotification.Name("changeDefaultDestinationFolderNotification"), object: nil)
//    }
    
    @IBAction func clearWeeklyRemindersClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("clearWeeklyReminderClickedNotification"), object: nil)
    }
    
    
    
    
    

    
}
