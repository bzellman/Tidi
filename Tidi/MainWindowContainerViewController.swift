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
    var onboardingViewController : OnboardingViewController?
    
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
        if #available(OSX 10.15, *) {
            onboardingViewController = storyboard?.instantiateController(identifier: "onboardingViewController")
        } else {
            //To-do: Fallback on earlier versions
        }
        

        if StorageManager().getOnboardingStatus() == false {
            onboardingViewController?.sourceViewController = sourceViewController
            onboardingViewController?.destinationViewController = destinationViewController
            showOnboarding(setAtOnboardingStage: .intro)
            }
      
    }
    
    func showOnboarding(setAtOnboardingStage : OnboardingViewController.onboardingStage) {
        if onboardingViewController == nil {
            onboardingViewController = OnboardingViewController()
        }
        onboardingViewController!.currentOnboardingState = setAtOnboardingStage
        self.presentAsSheet(onboardingViewController!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
