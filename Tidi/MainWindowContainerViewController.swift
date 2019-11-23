//
//  MainWindowContainerViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 9/4/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class MainWindowContainerViewController: NSViewController {
    
    var toolbarViewController : ToolbarViewController?
    var sourceViewController : TidiTableViewController?
    var destinationViewController : TidiTableViewController?
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "sourceSegue" {
            sourceViewController = segue.destinationController as? TidiTableViewController
        } else if segue.identifier == "destinationSegue" {
            destinationViewController = segue.destinationController as? TidiTableViewController
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        destinationViewController?.toolbarController = toolbarViewController
        sourceViewController?.toolbarController = toolbarViewController
        
        showNotification()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    func showNotification() -> Void {
//        var notification = NSUserNotification()
//        notification.title = "Test from Swift"
//        notification.informativeText = "The body of this Swift notification"
//        notification.soundName = NSUserNotificationDefaultSoundName
////        NSUserNotificationCenter.default.delegate = self as! NSUserNotificationCenterDelegate
//        NSUserNotificationCenter.default.deliver(notification)
        
        print(NSUserNotificationCenter.default.scheduledNotifications)

    }
    
}
