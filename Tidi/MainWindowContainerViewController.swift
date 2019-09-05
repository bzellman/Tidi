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
    
    var testVar = "TEST STRING"
    var sourceViewController : TidiTableViewController = TidiTableViewController.init()
    var destinationViewController : TidiTableViewController = TidiTableViewController.init()
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "sourceSegue" {
            print("SEGUE")
            
            sourceViewController = segue.destinationController as! TidiTableViewController
        } else if segue.identifier == "destinationSegue" {
            destinationViewController = segue.destinationController as! TidiTableViewController
        }
    }
}
