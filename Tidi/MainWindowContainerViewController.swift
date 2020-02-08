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
    var destinationTabViewController : DestinationTabViewController?
    var onboardingViewController : OnboardingViewController?
    var quickDropViewController : QuickDropTableViewController?
    var quickDropOnboardingViewController : QuickDropOnboardingViewController?
    var tidiSchedlueViewController : TidiScheduleViewController?
    let storageManager : StorageManager = StorageManager()
    var isOnboarding : Bool = false
    var quickDropSetWidth : CGFloat?
    
    @IBOutlet weak var containerViewWidthContraint: NSLayoutConstraint!
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "sourceSegue" {
            sourceViewController = segue.destinationController as? TidiTableViewController
        } else if segue.identifier == "destinationTabSegue" {
            destinationTabViewController = segue.destinationController as? DestinationTabViewController
        } else if segue.identifier == "quickDropSegue" {
            quickDropViewController = segue.destinationController as? QuickDropTableViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.toogleDestinationTypeButtonPushed), name: NSNotification.Name("destinationTypeDidChange"), object: nil)
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        sourceViewController!.toolbarController = toolbarViewController
        destinationViewController = destinationTabViewController!.destinationTableViewController
        destinationViewController!.toolbarController = toolbarViewController
                    
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
            quickDropSetWidth = 85
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

    @objc func toogleDestinationTypeButtonPushed(notification : Notification) {
        let selectedSegment = notification.userInfo!["segment"] as! Int
        if selectedSegment == 0 {
            showQuickDrop()
        } else if selectedSegment == 1 {
            closeQuickDrop()
        }
    }
    
    func closeQuickDrop() {
        
        NSAnimationContext.runAnimationGroup {_ in
            NSAnimationContext.current.duration = 0.175
            self.containerViewWidthContraint.animator().constant = 0
            quickDropViewController?.quickDropTableView.animator().isHidden = true
        }
    }
    
    func showQuickDrop() {
      NSAnimationContext.runAnimationGroup {_ in
              NSAnimationContext.current.duration = 0.175
              self.containerViewWidthContraint.animator().constant = 85
              quickDropViewController?.quickDropTableView.animator().isHidden = false
          }
    }
    
    
}
