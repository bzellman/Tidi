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

class ToobarViewController: NSWindowController, TidiTableViewDelegate {
    
    
    override func windowDidLoad() {
        let ttvc = storyboard?.instantiateController(withIdentifier: "sourceTableViewController") as! TidiTableViewController
        ttvc.delegate = self
        print(ttvc.sourceFileURLArray)

    }
    
    
    
    func didUpdateFocus(sender: TidiTableViewController, tableID: String) {
        print("UPDATED")
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
    
    func observeCurrentActiveTable() {
        
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

//extension ToobarViewController: TidiTableViewDelegate {
//
//}
