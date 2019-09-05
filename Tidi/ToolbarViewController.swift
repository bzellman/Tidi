//
//  ToolbarViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/29/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa


enum activeTables {
    case source
    case destination
}

class ToobarViewController: NSWindowController {
    
    // Do better later
    var activeTable : String = " "
    
    override func windowDidLoad() {
        let contentViewController = self.contentViewController as! MainWindowContainerViewController
        contentViewController.destinationViewController.delegate = self
        contentViewController.sourceViewController.delegate = self
        
        navigationSegmentControl.setEnabled(false, forSegment: 0)
        navigationSegmentControl.setEnabled(false, forSegment: 1)
    }
    
    
    
//    func setBackNavigationEnabled(sender: TidiTableViewController, isEnabled: Bool) {
//        <#code#>
//    }
//
//    func setForwardNavigationEnabled(sender: TidiTableViewController, isEnabled: Bool) {
//        <#code#>
//    }
//
    


    @IBOutlet weak var navigationSegmentControl: NSSegmentedControl!
    
    @IBAction func navigationSegmentControlClicked(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            print("Tap it back")
        } else if sender.selectedSegment == 1 {
            print("BRING IT FORWARD")
        }
    }
    
    func setActiveTable(tableID: String) {
        activeTable = tableID
    }
    
    func observeNavigationArray() {
        
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

extension ToobarViewController: TidiTableViewDelegate {
    
    func didUpdateFocus(sender: TidiTableViewController, tableID: String) {
        setActiveTable(tableID: tableID)
    }
}
