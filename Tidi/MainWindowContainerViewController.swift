//
//  MainWindowContainerViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 9/4/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class MainWindowContainerViewController: NSViewController, OnboardingReminderDelegate, OnboardingQuickDropDelegate {
    
    var toolbarViewController : ToolbarViewController?
    var sourceViewController : TidiTableViewController?
    var destinationViewController : TidiTableViewController?
    var onboardingViewController : OnboardingViewController?
    var quickDropViewController : QuickDropTableViewController?
    var quickDropOnboardingViewController : QuickDropOnboardingViewController?
    var tidiSchedlueViewController : TidiScheduleViewController?
    let storageManager : StorageManager = StorageManager()
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "sourceSegue" {
            sourceViewController = segue.destinationController as? TidiTableViewController
        } else if segue.identifier == "destinationSegue" {
            destinationViewController = segue.destinationController as? TidiTableViewController
        } else if segue.identifier == "quickDropSegue" {
            quickDropViewController = segue.destinationController as? QuickDropTableViewController
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        destinationViewController?.toolbarController = toolbarViewController
        sourceViewController?.toolbarController = toolbarViewController

        if StorageManager().getOnboardingStatus() == false {
            if #available(OSX 10.15, *) {
                onboardingViewController = storyboard?.instantiateController(identifier: "onboardingViewController")
                //To-Do: Move to Delegate function
                tidiSchedlueViewController = storyboard?.instantiateController(identifier: "setReminderView")
                quickDropOnboardingViewController = storyboard?.instantiateController(identifier: "quickDropOnboardingViewController")
            } else {
                //To-do: Fallback on earlier versions
            }
            onboardingViewController?.sourceViewController = sourceViewController
            onboardingViewController?.destinationViewController = destinationViewController
            showOnboarding(setAtOnboardingStage: .intro)
            quickDropOnboardingViewController!.mainWindowViewController = self
            onboardingViewController!.reminderDelegate = self
            onboardingViewController!.quickDropDelegegate = self
        }
      
    }
    
    func showOnboarding(setAtOnboardingStage : OnboardingViewController.onboardingStage) {
        //To-do: this does
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
    
    func setQuickDropFolders(sender : OnboardingViewController?) {
        if sender != nil{
            sender!.dismiss(sender!)
        }
        self.quickDropViewController?.setTableViewDataSource()
        self.presentAsSheet(quickDropOnboardingViewController!)
        quickDropOnboardingViewController!.setTableViewDataSource()
    }
    
    func setNewFolderForQuickDrop() {
        quickDropOnboardingViewController?.dismiss(quickDropOnboardingViewController)
        openFilePickerToChooseFile()
    }
    
    func completedQuickDrop() {
        quickDropOnboardingViewController?.dismiss(quickDropOnboardingViewController)
        showOnboarding(setAtOnboardingStage: .complete)
    }
    
    func openFilePickerToChooseFile() {
        guard let window = NSApplication.shared.mainWindow else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                if self.storageManager.addDirectoryToQuickDropArray(directoryToAdd: panel.urls[0].absoluteString) == false {
                    AlertManager().showSheetAlertWithOneAction(messageText: "That folder is already added to Quick Drop", dismissButtonText: "Cancel", actionButtonText: "Choose a different folder", presentingView: self.view.window!) {
                        self.openFilePickerToChooseFile()
                    }
                }
                self.setQuickDropFolders(sender: nil)
            }
        }
    }
    
}
