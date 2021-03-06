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
    @IBOutlet weak var scrollTableView: NSScrollView!
    @IBOutlet weak var sourceNoFolderContainerView: NSView!
    @IBOutlet weak var addNewSourceDirectoryButton: NSButton!
    
    
    @IBAction func setSourceFolderButtonPushed(_ sender: Any) {
        openFilePickerToChooseFile()
    }
    
    
    @IBOutlet weak var setSourceFolderButton: NSButton!
    

    override func viewDidLoad() {
        self.tableId = .source
        super.viewDidLoad()
        self.tidiTableView = sourceTableView
        self.addNewDirectoryButton = addNewSourceDirectoryButton
        noFolderContainerView = sourceNoFolderContainerView
        sourceTableView.identifier = NSUserInterfaceItemIdentifier(rawValue: "sourceTableView")
        self.currentTableName = "Default Launch Folder"
        self.toolbarController?.sourceTableViewController = self
        self.changeFolderButton = setSourceFolderButton
        
        if storageManager.checkForSourceFolder() == nil {
            isSourceFolderSet = false
            setSourceFolderButton.imagePosition =  .imageOnly
            setEmptyURLState()
        } else {
            selectedTableFolderURL = storageManager.checkForSourceFolder()!!
            currentDirectoryURL = storageManager.checkForSourceFolder()!!
            setSourceFolderButton.imagePosition = .imageLeft
            setSourceFolderButton.title = "- " + currentDirectoryURL.lastPathComponent
        }
            
        if storageManager.checkForDestinationFolder() != nil {
            destinationDirectoryURL = storageManager.checkForDestinationFolder()!!
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeDefaultLaunchFolder), name: NSNotification.Name("changeDefaultSourceFolderNotification"), object: nil)
    
    }
    
    override func viewWillAppear() {
        super .viewWillAppear()
        
        let contentViewController = self.parent as! MainWindowContainerViewController
         contentViewController.onboardingViewController?.sourceDelegate = self
        
        updateDetailBar()
    
    }


    override func viewDidAppear() {
        super .viewDidAppear()
        toolbarController?.delegate = self
    }
    
    
}

extension SourceTableViewController: OnboardingSourceDelegate {
    
    func setDefaultSourceFolder(buttonTag : Int, sender : OnboardingViewController) {
        switch buttonTag {
        case 2:
            sender.dismiss(sender)
            self.openFilePickerToChooseFile()
        case 3:
            sender.dismiss(sender)
            //To-Do: Check if Download Folder Exists and save is successful
            self.storageManager.saveDownloadsFolderAsSourceFolder()
            self.viewDidLoad()
            let mainWindowContainerViewController = self.parent as! MainWindowContainerViewController
            mainWindowContainerViewController.showOnboarding(setAtOnboardingStage: .setDestination)
        default:
            break
        }
    }
    
    
}
