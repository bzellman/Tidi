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
    

    override func viewDidLoad() {
        
        self.tidiTableView = sourceTableView
        self.currentTableID = "SourceTableViewController"
        super.viewDidLoad()
        

        toolbarController?.sourceTableViewController = self

        if storageManager.checkForSourceFolder() == nil {
            needsToSetDefaultSourceTableFolder = true
        } else {
            if storageManager.checkForSourceFolder() != nil {
                selectedTableFolderURL = storageManager.checkForSourceFolder()!!
                currentDirectoryURL = storageManager.checkForSourceFolder()!!
            }
            if storageManager.checkForDestinationFolder() != nil {
                destinationDirectoryURL = storageManager.checkForDestinationFolder()!!
            }

        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeDefaultLaunchFolder), name: NSNotification.Name("changeDefaultSourceFolderNotification"), object: nil)
        
    }
    
    override func viewWillAppear() {

        if needsToSetDefaultSourceTableFolder == true {
            self.openFilePickerToChooseFile()
        }

    }
    
    
}
