//
//  MainWindowContainerViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 9/4/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class MainWindowContainerViewController: NSViewController, OnboardingReminderDelegate, OnboardingQuickDropDelegate, OnboardingDismissDelegate {
    
    
    var toolbarViewController : ToolbarViewController?
    var sourceViewController : TidiTableViewController?
    var destinationViewController : TidiTableViewController?
    var onboardingViewController : OnboardingViewController?
    var quickDropViewController : QuickDropTableViewController?
    var quickDropOnboardingViewController : QuickDropOnboardingViewController?
    var tidiSchedlueViewController : TidiScheduleViewController?
    let storageManager : StorageManager = StorageManager()
    var isOnboarding : Bool = false
    
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
            isOnboarding = true
            if #available(OSX 10.15, *) {
                onboardingViewController = storyboard?.instantiateController(identifier: "onboardingViewController")
                tidiSchedlueViewController = storyboard?.instantiateController(identifier: "setReminderView")
                quickDropOnboardingViewController = storyboard?.instantiateController(identifier: "quickDropOnboardingViewController")
            } else {
                onboardingViewController = storyboard?.instantiateController(withIdentifier: "onboardingViewController") as? OnboardingViewController
                tidiSchedlueViewController = storyboard?.instantiateController(withIdentifier: "setReminderView") as? TidiScheduleViewController
                quickDropOnboardingViewController = storyboard?.instantiateController(withIdentifier: "quickDropOnboardingViewController") as? QuickDropOnboardingViewController
            }
            onboardingViewController?.sourceViewController = sourceViewController
            onboardingViewController?.destinationViewController = destinationViewController
            showOnboarding(setAtOnboardingStage: .intro)
            quickDropOnboardingViewController!.mainWindowViewController = self
            onboardingViewController!.reminderDelegate = self
            onboardingViewController!.quickDropDelegegate = self
            onboardingViewController!.mainWindowContainerDelegate = self
        }
      
    }
    
    func showOnboarding(setAtOnboardingStage : OnboardingViewController.onboardingStage) {
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
    
    func setOnboardingCompleted(sender : OnboardingViewController?) {
        isOnboarding = false
    }
    
    func openFilePickerToChooseFile() {
        guard let window = NSApplication.shared.mainWindow else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                DirectoryManager().allowFolder(urlToAllow: panel.urls[0])
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
