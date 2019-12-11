//
//  SourceTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/11/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class SourceTableViewController: TidiTableViewController {

    
    @IBOutlet weak var sourceTableView: NSTableView!
    
    @IBAction func setSourceFolderButtonPushed(_ sender: Any) {
        openFilePickerToChooseFile()
    }
    
    
    @IBOutlet weak var setSourceFolderButton: NSButton!
    
    

    override func viewDidLoad() {
        
        self.tidiTableView = sourceTableView
        self.currentTableID = "SourceTableViewController"
        super.viewDidLoad()
        self.changeFolderButton = setSourceFolderButton

        toolbarController?.sourceTableViewController = self

        if storageManager.checkForSourceFolder() == nil {
            needsToSetDefaultSourceTableFolder = true
        } else {
            if storageManager.checkForSourceFolder() != nil {
                selectedTableFolderURL = storageManager.checkForSourceFolder()!!
                currentDirectoryURL = storageManager.checkForSourceFolder()!!
                setSourceFolderButton.title = "- " + currentDirectoryURL.lastPathComponent
                setSourceFolderButton.imagePosition = .imageLeft
            } else {
                setSourceFolderButton.imagePosition =  .imageOnly
            }
            
            if storageManager.checkForDestinationFolder() != nil {
                destinationDirectoryURL = storageManager.checkForDestinationFolder()!!
                
            }

        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeDefaultLaunchFolder), name: NSNotification.Name("changeDefaultSourceFolderNotification"), object: nil)
    
    }
    
    override func viewWillAppear() {
        super .viewWillAppear()
        if needsToSetDefaultSourceTableFolder == true {
            let alert = NSAlert()
            alert.messageText = "You don't have a default folder to Tidi up... \n\nDo you want to set your Downloads Folder or select a custom default folder?"
            alert.addButton(withTitle: "Downloads Folder")
            alert.addButton(withTitle: "Custom Folder")
            alert.addButton(withTitle: "Dismiss")
            alert.beginSheetModal(for: self.view.window!) { (response) in
                if response == .alertFirstButtonReturn {
                    self.storageManager.saveDownloadsFolderAsSourceFolder()
                } else if response == .alertSecondButtonReturn {
                    self.openFilePickerToChooseFile()
                }
            }
        }

    }

    override func viewDidAppear() {
        super .viewDidAppear()
        toolbarController?.delegate = self
    }
    
    
}
