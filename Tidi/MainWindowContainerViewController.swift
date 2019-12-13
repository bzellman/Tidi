//
//  MainWindowContainerViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 9/4/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class MainWindowContainerViewController: NSViewController, OnboardingReminderDelegate {
    
    var toolbarViewController : ToolbarViewController?
    var sourceViewController : TidiTableViewController?
    var destinationViewController : TidiTableViewController?
    var onboardingViewController : OnboardingViewController?
    var tidiSchedlueViewController : TidiScheduleViewController?
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "sourceSegue" {
            sourceViewController = segue.destinationController as? TidiTableViewController
        } else if segue.identifier == "destinationSegue" {
            destinationViewController = segue.destinationController as? TidiTableViewController
        }
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        destinationViewController?.toolbarController = toolbarViewController
        sourceViewController?.toolbarController = toolbarViewController
        if #available(OSX 10.15, *) {
            onboardingViewController = storyboard?.instantiateController(identifier: "onboardingViewController")
            //To-Do: Move to Delegate function
            tidiSchedlueViewController = storyboard?.instantiateController(identifier: "setReminderView")
        } else {
            //To-do: Fallback on earlier versions
        }
        

        if StorageManager().getOnboardingStatus() == false {
            onboardingViewController?.sourceViewController = sourceViewController
            onboardingViewController?.destinationViewController = destinationViewController
            showOnboarding(setAtOnboardingStage: .intro)
            onboardingViewController!.reminderDelegate = self
        }
      
    }
    
    func showOnboarding(setAtOnboardingStage : OnboardingViewController.onboardingStage) {
        if onboardingViewController == nil {
            onboardingViewController = OnboardingViewController()
        }
        onboardingViewController!.currentOnboardingState = setAtOnboardingStage
        self.presentAsSheet(onboardingViewController!)
    }
    
    func setReminderNotification(sender: OnboardingViewController) {
        sender.dismiss(sender)
        tidiSchedlueViewController!.isOnboarding = true
        self.presentAsSheet(tidiSchedlueViewController!)
    }
    
    func completedReminder() {
        tidiSchedlueViewController?.dismiss(tidiSchedlueViewController)
        showOnboarding(setAtOnboardingStage: .setQuickdrop)
    }
}
