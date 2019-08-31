//
//  ToolbarViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/29/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class ToobarViewController: NSWindowController {
    
    
    
    var viewController: ViewController {
        get {
            return self.window!.contentViewController as! ViewController
        }
    }
    
    
    @IBOutlet weak var navigationSegmentControl: NSSegmentedControl!
    
    @IBAction func navigationSegmentControlClicked(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            print("Tap it back")
        } else if sender.selectedSegment == 1 {
            print("BRING IT FORWARD")
        }
    }
    

}


extension ToobarViewController {
    func disableBackButton() {
        navigationSegmentControl.setEnabled(false, forSegment: 0)
    }
    
    func enableBackButton() {
        navigationSegmentControl.setEnabled(true, forSegment: 0)
    }
    
    func disableForwardButton() {
        navigationSegmentControl.setEnabled(false, forSegment: 1)
    }
    
    func enableForwardButton() {
        navigationSegmentControl.setEnabled(true, forSegment: 1)
    }
}
