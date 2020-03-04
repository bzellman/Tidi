//
//  DestinationTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/11/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa


protocol DestinationDirectoryDetailLabelDelegate : AnyObject {
    func updateDestinationDirectoryDetailLabel(newLabelString : String)
}

class DestinationTableViewController: TidiTableViewController {
    
    var detailBarDelegate : DestinationDirectoryDetailLabelDelegate?
    var destinationDetailBarViewController : DestinationTableDetailBarViewController?
    var directoryItemCount : Int?
    var directorySize : String?
    
    
    
    @IBOutlet weak var destinationTableView: NSTableView!
    
    @IBAction func setDestinationFolderButtonPushed(_ sender: Any) {
        openFilePickerToChooseFile()
    }
    
    @IBOutlet weak var setDestinationFolderButton: NSButton!
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
            if segue.identifier == "destinationTableDetailSegue" {
                destinationDetailBarViewController = segue.destinationController as? DestinationTableDetailBarViewController
                 detailBarDelegate = destinationDetailBarViewController
            }
    }
    
    
    override func viewDidLoad() {
        self.tableId = .destination
        super.viewDidLoad()
        self.tidiTableView = destinationTableView
        self.currentTableName = "Default Destination Folder"
        self.toolbarController?.destinationTableViewController = self
        self.changeFolderButton = setDestinationFolderButton
        destinationTableView.identifier = NSUserInterfaceItemIdentifier(rawValue: "destinationTableView")

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
        
        let contentViewController = self.parent?.parent as! MainWindowContainerViewController
        contentViewController.onboardingViewController?.destinationDelegate = self
        detailBarDelegate?.updateDestinationDirectoryDetailLabel(newLabelString: "1,000 items, 500 GB in folder")
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

        self.selectedTableFolderURL = urlOfSelectedFoler
        
    }

    
}
