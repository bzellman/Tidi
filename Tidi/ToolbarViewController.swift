//
//  ToolbarViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/29/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa


protocol TidiToolBarDelegate: AnyObject  {
    
    func backButtonPushed(sender: ToolbarViewController)
    func forwardButtonPushed(sender: ToolbarViewController)
    func trashButtonPushed(sender: ToolbarViewController)
    
}

class ToolbarViewController: NSWindowController {
    
    var activeTable : String?
    
    var sourceTableBackArrayCount : Int = 0
    var destinationTableBackArrayCount : Int = 0
    
    var sourceTableForwardArrayCount : Int = 0
    var destinationTableForwardArrayCount : Int = 0
    
    var sourceTableViewController : TidiTableViewController?
    var destinationTableViewController : TidiTableViewController?
    
    weak var delegate: TidiToolBarDelegate?
    
    override func windowDidLoad() {
        super .windowDidLoad()
        let contentViewController = self.contentViewController as! MainWindowContainerViewController
        contentViewController.toolbarViewController = self
        contentViewController.destinationViewController?.delegate = self
        contentViewController.sourceViewController?.delegate = self
        
        disableBackButton()
        disableForwardButton()
    }
    

    @IBOutlet weak var navigationSegmentControl: NSSegmentedControl!
    
    @IBAction func navigationSegmentControlClicked(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            delegate?.backButtonPushed(sender: self)
        } else if sender.selectedSegment == 1 {
            delegate?.forwardButtonPushed(sender: self)
        }
    }
    
    @IBOutlet weak var setReminderButton: NSButton!
        
    
    @IBAction func trashButtonClicked(_ sender: Any) {
        delegate?.trashButtonPushed(sender: self)
    }
    
    
    func setActiveTable(tableID: String) {
        activeTable = tableID
    }
    
    
    func checkForNavigationButtonSegmentsEnabled() {
        
        if activeTable == "SourceTableViewController" {
            
            if sourceTableBackArrayCount > 0 {
                enableBackButton()
            } else {
                disableBackButton()
            }
            
            if sourceTableForwardArrayCount > 0 {
                enableForwardButton()
            } else {
                disableForwardButton()
            }
    
        }
        
        if activeTable == "DestinationTableViewController" {
            if destinationTableBackArrayCount > 0 {
                enableBackButton()
            } else {
                disableBackButton()
            }
            
            if destinationTableForwardArrayCount > 0 {
                enableForwardButton()
            } else {
                disableForwardButton()
            }
        }
        
    }

}


extension ToolbarViewController {
    
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

extension ToolbarViewController: TidiTableViewDelegate {
    
    func navigationArraysEvaluation(backURLArrayCount: Int, forwarURLArrayCount: Int, activeTable: String) {

        self.activeTable = activeTable
        
        if activeTable == "SourceTableViewController" {
            self.sourceTableBackArrayCount = backURLArrayCount
            self.sourceTableForwardArrayCount = forwarURLArrayCount
        }
        
        if activeTable == "DestinationTableViewController" {
            self.destinationTableBackArrayCount = backURLArrayCount
            self.destinationTableForwardArrayCount = forwarURLArrayCount
        }
        
        checkForNavigationButtonSegmentsEnabled()
    }
    
}


