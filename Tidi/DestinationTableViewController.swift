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
        self.currentTableName = "Default Destination Folder"
        super.viewDidLoad()
        self.changeFolderButton = setDestinationFolderButton
        
        
        if storageManager.checkForSourceFolder() != nil {
            destinationDirectoryURL = storageManager.checkForSourceFolder()!!
            isSourceFolderSet = true
        } else {
            isSourceFolderSet = false
        }

        if storageManager.checkForDestinationFolder() != nil {
            selectedTableFolderURL = storageManager.checkForDestinationFolder()!!
            currentDirectoryURL = storageManager.checkForDestinationFolder()!!
            setDestinationFolderButton.imagePosition = .imageLeft
            setDestinationFolderButton.title = "- " +  currentDirectoryURL.lastPathComponent
        } else {
            isDestinationTableFolderSet = false
            setDestinationFolderButton.imagePosition = .imageOnly
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeDefaultDestinationFolder), name: NSNotification.Name("changeDefaultDestinationFolderNotification"), object: nil)
        
        for viewController in self.parent!.children {
            if viewController.className == "Tidi.QuickDropTableViewController" {
                let quickDropVCReference : QuickDropTableViewController = viewController as! QuickDropTableViewController
                quickDropVCReference.delegate = self
            }
        }
        
    }
    
    override func viewWillAppear() {
        super .viewDidAppear()
        
        let contentViewController = self.parent as! MainWindowContainerViewController
        contentViewController.onboardingViewController?.destinationDelegate = self
        
    }
}

extension DestinationTableViewController: OnboardingDestinationDelegate {
   
    func setDefaultDestinationFolder(sender: OnboardingViewController) {
        sender.dismiss(sender)
        self.openFilePickerToChooseFile()
    }
}

extension DestinationTableViewController : QuickDropTableViewControllerDelegate {
    
    func quickDropItemDoubleClicked(urlOfSelectedFoler : URL) {
        print("selected")
        self.selectedTableFolderURL = urlOfSelectedFoler
        
    }

    
}
