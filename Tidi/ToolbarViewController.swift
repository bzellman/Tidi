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
    func openInFinderButtonPushed(sender: ToolbarViewController)
    func filterPerformed(sender: ToolbarViewController)
}

//protocol TidiToolBarToggleDestinationDelegate : AnyObject {
//    func toogleDestinationTypeButtonPushed(destinationStyle: DestinationTabViewController.destinationDisplayType?)
//}

class ToolbarViewController: NSWindowController {
    
    var activeTable : tidiFileTableTypes?
    
    var sourceTableBackArrayCount : Int = 0
    var destinationTableBackArrayCount : Int = 0
    
    var sourceTableForwardArrayCount : Int = 0
    var destinationTableForwardArrayCount : Int = 0
    
    var sourceTableViewController : TidiTableViewController?
    var destinationTableViewController : TidiTableViewController?
    var destinationDisplayType : DestinationTabViewController.destinationDisplayType?
    
//    var destinationDelegate : TidiToolBarToggleDestinationDelegate?
    var delegate: TidiToolBarDelegate? {
        didSet {
            let activeTidi = delegate as! TidiTableViewController
            activeTable = activeTidi.tableId
        }
    }
    
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.tabbingMode = .disallowed
        
        let contentViewController = self.contentViewController as! MainWindowContainerViewController
        contentViewController.toolbarViewController = self
        contentViewController.destinationViewController?.tidiTableDelegate = self
        contentViewController.sourceViewController?.tidiTableDelegate = self
        
        disableBackButton()
        disableForwardButton()
        
        ///To-Do: Add a user setting and check against
        destinationDisplayType = .destinationTable
        
    }
    
    @IBOutlet weak var filterTextField: NSSearchField!
    
    @IBOutlet weak var navigationSegmentControl: NSSegmentedControl!
    
    @IBAction func navigationSegmentControlClicked(_ sender: NSSegmentedControl) {
        NotificationCenter.default.post(name: NSNotification.Name("destinationTypeDidChange"), object: nil, userInfo: ["segment" : sender.selectedSegment])
    }
    
    @IBOutlet weak var setReminderButton: NSButton!
        
    
    @IBAction func trashButtonClicked(_ sender: Any) {
        delegate?.trashButtonPushed(sender: self)
    }
    
    
    @IBAction func openInFinderButtonClicked(_ sender: Any) {
        delegate?.openInFinderButtonPushed(sender: self)
    }
    
    @IBAction func filterTextFieldUpdated(_ sender: Any) {
        delegate?.filterPerformed(sender: self)
    }
    
    @IBAction func toggleDestinationVCTypeClicked(_ sender: NSSegmentedControl) {
        NotificationCenter.default.post(name: NSNotification.Name("destinationTypeDidChange"), object: nil, userInfo: ["segment" : sender.selectedSegment])
    }
    
    
    func checkForNavigationButtonSegmentsEnabled() {

        if activeTable == .source {
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
        } else if activeTable == .destination {
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
    
    func clearFilter() {
        
    }
    
    func navigationArraysEvaluation(backURLArrayCount: Int, forwarURLArrayCount: Int, activeTable: tidiFileTableTypes) {

        if activeTable == .source {
            self.sourceTableBackArrayCount = backURLArrayCount
            self.sourceTableForwardArrayCount = forwarURLArrayCount
        }
        
        if activeTable == .destination {
            self.destinationTableBackArrayCount = backURLArrayCount
            self.destinationTableForwardArrayCount = forwarURLArrayCount
        }
        
        checkForNavigationButtonSegmentsEnabled()
    }
    
    func updateFilter(filterString: String) {
        filterTextField.stringValue = filterString
    }
    
}


