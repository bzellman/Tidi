//
//  DestinationTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/11/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class DestinationTableViewController: TidiTableViewController {
    
    
    @IBOutlet weak var destinationTableView: NSTableView!
    
    @IBAction func setDestinationFolderButtonPushed(_ sender: Any) {
        openFilePickerToChooseFile()
    }
    
    @IBOutlet weak var setDestinationFolderButton: NSButton!
    
    
    override func viewDidLoad() {

        self.tidiTableView = destinationTableView
        self.currentTableID = "DestinationTableViewController"
        super.viewDidLoad()
        self.changeFolderButton = setDestinationFolderButton
        
        
        if storageManager.checkForSourceFolder() != nil {
            destinationDirectoryURL = storageManager.checkForSourceFolder()!!
        }

        if storageManager.checkForDestinationFolder() != nil {
            selectedTableFolderURL = storageManager.checkForDestinationFolder()!!
            currentDirectoryURL = storageManager.checkForDestinationFolder()!!
            setDestinationFolderButton.title = "- " +  currentDirectoryURL.lastPathComponent
            setDestinationFolderButton.imagePosition = .imageLeft
        } else {
            needsToSetDefaultDestinationTableFolder = true
            setDestinationFolderButton.imagePosition = .imageOnly
        }


        if storageManager.checkForSourceFolder() == nil {
            needsToSetDefaultSourceTableFolder = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeDefaultDestinationFolder), name: NSNotification.Name("changeDefaultDestinationFolderNotification"), object: nil)
        
    }
    
    override func viewWillAppear() {
        super .viewDidAppear()
        
        if needsToSetDefaultDestinationTableFolder == true {
            AlertManager().showSheetAlertWithOneAction(messageText: "Looks like you don't have a default Destination Folder to move files to... \n\nDo you want to set a default Destination Folder?", dismissButtonText: "Dismiss", actionButtonText: "Choose A Folder", presentingView: self.view.window!) {
                self.openFilePickerToChooseFile()
            }

        }
    }
}
