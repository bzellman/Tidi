//
//  PreferencesViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 12/7/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesViewController: NSViewController {
    var storageManager = StorageManager()
    
    @IBOutlet weak var defaultCleanUpButtonClicked: NSButton!
    @IBOutlet weak var defaultDestinationButtonClicked: NSButton!
    
    @IBOutlet weak var defaultCleanUpAddressLabel: NSTextField!
    @IBOutlet weak var defaultDestinationAddressLabel: NSTextField!
    
    override func viewWillAppear() {
        super .viewWillAppear()
        view.window?.title = "Tidi - Preferences"
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        defaultCleanUpAddressLabel.isEditable = false
        defaultDestinationAddressLabel.isEditable = false
        setFolderLabels()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultDestinationFolderChanged), name: NSNotification.Name("changeDefaultDestinationFolderNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultSourceFolderChanged), name: NSNotification.Name("changeDefaultSourceFolderNotification"), object: nil)
    }
    
    
    
    @objc func defaultDestinationFolderChanged() {
        
    }
    
    @objc func defaultSourceFolderChanged() {
        
    }
    
    @IBAction func setDefaultCleanUpFolderClicked(_ sender: Any) {
        openFilePickerToChooseFile(defaultFolderToSet : "defaultSourceFolder")
    }
    
    @IBAction func setDefaultDestinationFolderClicked(_ sender: Any) {
        openFilePickerToChooseFile(defaultFolderToSet : "defaultDestinationFolder")
    }
    
    
    
    func setFolderLabels() {
        let sourceFolderURL : URL  = storageManager.checkForSourceFolder()!!
        defaultCleanUpAddressLabel.stringValue = sourceFolderURL.relativePath

        if storageManager.checkForDestinationFolder() != nil {
            let destinationFolderURL : URL = storageManager.checkForDestinationFolder()!!
            defaultDestinationAddressLabel.stringValue = destinationFolderURL.relativePath
        } else {
            defaultDestinationAddressLabel.stringValue = "No Folder Set"
        }
    }
    
    func openFilePickerToChooseFile(defaultFolderToSet : String) {
        guard let window = NSApplication.shared.mainWindow else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                let selectedTableFolderURL = panel.urls[0]
                if defaultFolderToSet == "defaultSourceFolder" {
                        self.storageManager.saveDefaultSourceFolder(selectedTableFolderURL)
                }else if defaultFolderToSet == "defaultDestinationFolder" {
                        self.storageManager.saveDefaultDestinationFolder(selectedTableFolderURL)
                }
            self.setFolderLabels()
            
            }
        }
    }
        
}
