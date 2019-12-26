//
//  OnboardingViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 12/11/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

protocol OnboardingSourceDelegate : AnyObject {
    func setDefaultSourceFolder(buttonTag : Int, sender : OnboardingViewController)
}

protocol OnboardingDestinationDelegate : AnyObject{
    func setDefaultDestinationFolder(sender : OnboardingViewController)
}

protocol OnboardingReminderDelegate : AnyObject {
    func setReminderNotification(sender : OnboardingViewController)
}

protocol OnboardingQuickDropDelegate : AnyObject {
    func setQuickDropFolders(sender : OnboardingViewController?)
}

protocol OnboardingDismissDelegate : AnyObject {
    func setOnboardingCompleted(sender : OnboardingViewController?)
}

class OnboardingViewController: NSViewController {
    
    enum onboardingStage {
        case intro
        case setSource
        case setDestination
        case setReminder
        case setQuickdrop
        case complete
    }
    
    
    var currentOnboardingState :onboardingStage?
    var sourceViewController : TidiTableViewController?
    var destinationViewController : TidiTableViewController?
    var reminderViewController : TidiScheduleViewController?
    
    weak var sourceDelegate: OnboardingSourceDelegate?
    weak var destinationDelegate: OnboardingDestinationDelegate?
    weak var reminderDelegate: OnboardingReminderDelegate?
    weak var quickDropDelegegate: OnboardingQuickDropDelegate?
    weak var mainWindowContainerDelegate: OnboardingDismissDelegate?
    
    @IBOutlet weak var messageTextField: NSTextField!
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var leftButton: NSButton!
    @IBOutlet weak var centerButton: NSButton!
    @IBOutlet weak var rightButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        closeButton.tag = 0
        leftButton.tag = 1
        centerButton.tag = 2
        rightButton.tag = 3
        
        
    }
    
    override func viewWillAppear() {
        if currentOnboardingState == nil {
                   currentOnboardingState = .intro
               }
        setViewForOnboardingStage(onboardingStage: currentOnboardingState!)
    }
    
    
    func setViewForOnboardingStage(onboardingStage: onboardingStage){
        
        switch onboardingStage {
        case .intro:
            messageTextField.stringValue = "To get started, let's setup some default folders and settings. \n\nIt'll be super fast and ensure you get the most out of using Tidi!"
            progressIndicator.doubleValue = 1
            leftButton.isHidden = true
            centerButton.isHidden = true
            rightButton.title = "Next"
        case .setSource:
            messageTextField.stringValue = "First... Let's set a default folder to Tidi up. \n\nThis will be the folder that Tidi launches with on the left panel. \n\nThe Downloads folder is recommended, but you can pick any Folder on your Mac"
            progressIndicator.doubleValue = 2
            leftButton.isHidden = false
            leftButton.title = "Skip"
            centerButton.isHidden = false
            centerButton.title = "Custom Folder"
            rightButton.title = "Download Folder"
        case .setDestination:
            messageTextField.stringValue = "Next... Let's set a default Move To Folder. \n\nThis will be the folder that Tidi launches with on the right panel."
            progressIndicator.doubleValue = 3
            leftButton.isHidden = true
            centerButton.isHidden = false
            centerButton.title = "Skip"
            rightButton.title = "Set Folder"
        case .setReminder:
            messageTextField.stringValue = "Do you want to set a reminder when to Tidi Up? \n\nYou can pick a time and set of days to be reminded to Tidi Up."
            progressIndicator.doubleValue = 4
            leftButton.isHidden = true
            centerButton.isHidden = false
            centerButton.title = "Skip"
            rightButton.title = "Set Reminder"
        case .setQuickdrop:
            messageTextField.stringValue = "Do you want to set up QuickDrop Folders? \n\nQuickDrop allows you to quickly move selected items from either panel into a folder."
            progressIndicator.doubleValue = 5
            leftButton.isHidden = true
            centerButton.isHidden = false
            centerButton.title = "Skip"
            rightButton.title = "Set Quick Drop"
        case .complete:
            messageTextField.stringValue = "Great! We're all set \n\nHappy Tiding"
            progressIndicator.doubleValue = 6
            closeButton.isHidden = true
            leftButton.isHidden = true
            centerButton.isHidden = true
            closeButton.isHidden = true
            rightButton.title = "Let's Go!"
        }
        
        rightButton.highlight(true)
    }
    
    @IBAction func dismissButtonClicked(_ sender: Any) {
        closeWithAlert()
        
    }
    
    @IBAction func leftButtonClicked(_ sender: Any) {
        if self.currentOnboardingState == onboardingStage.setSource {
            currentOnboardingState = .setDestination
            setViewForOnboardingStage(onboardingStage: currentOnboardingState!)
        }
    }
    
    @IBAction func centerButtonClicked(_ sender: Any) {
        switch self.currentOnboardingState {
        case .setSource:
            sourceDelegate!.setDefaultSourceFolder(buttonTag : 2, sender: self)
        case .setDestination:
            currentOnboardingState = .setReminder
            setViewForOnboardingStage(onboardingStage: currentOnboardingState!)
        case .setReminder:
            currentOnboardingState = .setQuickdrop
            setViewForOnboardingStage(onboardingStage: currentOnboardingState!)
        case .setQuickdrop:
            currentOnboardingState = .complete
            setViewForOnboardingStage(onboardingStage: currentOnboardingState!)
        case .intro:
            break
        case .complete:
            break
        case .none:
            break
        }
        
    }
    
    @IBAction func rightButtonClicked(_ sender: Any) {
        switch self.currentOnboardingState {
        case .intro:
            currentOnboardingState = .setSource
            setViewForOnboardingStage(onboardingStage: currentOnboardingState!)
        case .setSource:
            sourceDelegate!.setDefaultSourceFolder(buttonTag : 3, sender: self)
        case .setDestination:
            destinationDelegate?.setDefaultDestinationFolder(sender: self)
        case .setReminder:
            reminderDelegate?.setReminderNotification(sender: self)
        case .setQuickdrop:
            quickDropDelegegate?.setQuickDropFolders(sender : self)
        case .complete:
            mainWindowContainerDelegate?.setOnboardingCompleted(sender: self)
            StorageManager().setOnboardingStatus(onboardingComplete: true)
            self.dismiss(self)
        case .none:
            break
        }
        rightButton.state = .on
    }
    
    func closeWithAlert() {
        mainWindowContainerDelegate?.setOnboardingCompleted(sender: self)
        AlertManager().showPopUpAlertWithOneAction(messageText: "Do you want to see this next time you open Tidi?", dismissButtonText: "Yes", actionButtonText: "No", presentingView: self.view.window!) {
            StorageManager().setOnboardingStatus(onboardingComplete: true)
        }
        
        self.dismiss(self)
        
    }
}
