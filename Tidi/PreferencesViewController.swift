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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultDestinationFolderChanged), name: NSNotification.Name("defaultDestinationFolderDidChangeNotification"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultSourceFolderChanged), name: NSNotification.Name("defaultSourceFolderDidChangeNotification"), object: nil)
    }
    
    
    
    @objc func defaultDestinationFolderChanged() {
        setFolderLabels()
    }
    
    @objc func defaultSourceFolderChanged() {
        setFolderLabels()
    }
    
    @IBAction func setDefaultCleanUpFolderClicked(_ sender: Any) {
        openFilePickerToChooseFile(defaultFolderToSet : "defaultSourceFolder")
    }
    
    @IBAction func setDefaultDestinationFolderClicked(_ sender: Any) {
        openFilePickerToChooseFile(defaultFolderToSet : "defaultDestinationFolder")
    }
    
    
    @IBAction func clearAllSettingsClicked(_ sender: Any) {
        AlertManager().showSheetAlertWithOneAction(messageText: "Do you really want to your settings and reminders", dismissButtonText: "No", actionButtonText: "Yes", presentingView: self.view.window!) {
            
            if self.removeAllSettings() {
                    AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "All your settings are clear. \n\nPlease restart Tidi for the changes to fully take effect", buttonText: "Ok", presentingView: self.view.window!)
                } else {
                    AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "There was an issue clearing your settings. \n\nPlease try again", buttonText: "Ok", presentingView: self.view.window!)
                }
        }
    }
    
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.view.window?.close()
    }
    
    
    
    func setFolderLabels() {

        if storageManager.checkForSourceFolder() != nil {
            let sourceFolderURL : URL = storageManager.checkForSourceFolder()!!
            defaultCleanUpAddressLabel.stringValue = sourceFolderURL.relativePath
        } else {
            defaultCleanUpAddressLabel.stringValue = "No Folder Set"
        }
        
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
                DirectoryManager().allowFolder(urlToAllow: panel.urls[0])
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
    
    func removeAllSettings() -> Bool {
        let notificationManager : TidiNotificationManager = TidiNotificationManager()
        
        if notificationManager.removeAllScheduledNotifications() {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            if UserDefaults.standard.synchronize() {
                setFolderLabels()
                return true
            } else {
                return false
            }
        } else {
            return false
        }
            
    }
        
}
