//
//  QuickDropOnboardingViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 12/13/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class QuickDropOnboardingViewController: NSViewController {
    
    let storageManager = StorageManager()
    var mainWindowViewController : MainWindowContainerViewController?
    var quickDropTableSourceURLArray : [URL] = []
    var quickDropSourceArrayAsStrings : [String] = []
    
    @IBOutlet weak var quickDropOnboardingTableView: NSTableView!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var addFolderButton: NSButton!
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        quickDropOnboardingTableView.delegate = self
        quickDropOnboardingTableView.dataSource = self
    }
    
    func setTableViewDataSource() {
        quickDropSourceArrayAsStrings = storageManager.getQuickDropArray()
        quickDropTableSourceURLArray = []
        
        for item in quickDropSourceArrayAsStrings {
            let URLString = item
            let url = URL.init(string: URLString)
            
            if DirectoryManager().fileExists(url: url!) {
                quickDropTableSourceURLArray.append(url!)
            } else {
                AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "UhOh! Looks like a folder moved", informativeText: "It looks like the QuickDrop folder \(url!.lastPathComponent) has moved or no longer exists. \n\nPlease re-add that folder if you would still like to use it with QuickDrop", buttonText: "Okay")
                
                storageManager.removeQuickDropItemWithURL(directoryURLString : URLString)
                
            }
            
        }
        
        quickDropOnboardingTableView.reloadData()
        
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        mainWindowViewController?.completedQuickDrop()
    }
    
    @IBAction func addFolderButtonClicked(_ sender: Any) {
        mainWindowViewController?.setNewFolderForQuickDrop()
    }
        
    
}

extension QuickDropOnboardingViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return quickDropTableSourceURLArray.count
    }
}

extension QuickDropOnboardingViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn == tableView.tableColumns[0] {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("onboardingQuickDropHotKeyID"), owner: self) as! NSTableCellView
            if row < 9 {
                cell.textField?.stringValue = "⌘ " + String(row+1)
            } else {
                cell.textField?.stringValue = "No Hotkey"
            }
            return cell
        } else if tableColumn == tableView.tableColumns[1] {
            let item = quickDropTableSourceURLArray[row]
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("onboardingQuickDropFolderNameID"), owner: self) as! NSTableCellView
            cell.textField?.stringValue = item.lastPathComponent
            return cell
        }

        return nil
    }
}
