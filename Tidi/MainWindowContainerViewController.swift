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
            // Fallback on earlier versions
        }
        

        if StorageManager().getOnboardingStatus() == false {
                self.presentAsSheet(onboardingViewController!)
            }
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
