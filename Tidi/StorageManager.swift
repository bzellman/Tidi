//
//  StorageManager.swift
//  Tidi
//
//  Created by Brad Zellman on 8/16/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class StorageManager: NSViewController {

    // MARK: SAVE USER DEFAULTS
    let userDefaults = UserDefaults.standard
    
    //Not able to get user's home directory using homeDirectory - not sure why: hacking with this instead
    let userHomeDirectory : URL = URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.deletingLastPathComponent().relativePath)
//    let userHomeDirectory : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let defaultLaunchFolderKey : String = "defaultLaunchFolder"
    let destinationDestinationFolderKey : String = "destinationDestinationFolder"
    
    func saveDefaultLaunchFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: defaultLaunchFolderKey)
    }
    
    func saveNewDefaultLaunchFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: defaultLaunchFolderKey)
    }
    
    func checkForDefaultLaunchFolder() -> (URL?)? {
        
        if userDefaults.url(forKey: defaultLaunchFolderKey) != nil {
            return userDefaults.url(forKey: defaultLaunchFolderKey)
        }
            return nil
    }
    
    func saveDefaultDestinationFolder() {
        userDefaults.set(userHomeDirectory, forKey: destinationDestinationFolderKey)
    }
    
    func setNewDestinationLaunchFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: destinationDestinationFolderKey)
    }
    
    func checkForDestinationFolder() -> (URL?)? {
        saveDefaultDestinationFolder()
        if userDefaults.url(forKey: destinationDestinationFolderKey) != nil {
            // Happening too many times - debug with fresh eyes after drop working
//            print (userDefaults.url(forKey: destinationDestinationFolderKey)!)
            return userDefaults.url(forKey: destinationDestinationFolderKey)
        }
        return nil
    }
    
    //NEED TO ADD WAY TO MODIFY + RESET DEFAULT DESTINATION STATE
    
    // MARK: MOVE FILES
    func moveItem(atURL: URL, toURL: URL, completion: @escaping (Bool, Error?) -> ()) {
        
        //Get the last part of the file name to be moved and append to the destination file URL for move
        let toURLwithFileName : URL = URL(fileURLWithPath: toURL.path + "/" + atURL.lastPathComponent)
        
        DispatchQueue.global(qos: .utility).async {
                do {
                    try FileManager.default.moveItem(at: atURL, to: toURLwithFileName)
                } catch {
                    // Pass false and error to completion when fails
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
                // Pass true to completion when succeeds
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            }
        
        }

}

//class TidiPasteboardWriter: NSObject, NSPasteboardWriting {
//    var itemURL: URL
//    var itemIndex: Int
//    
//    init(itemURL: URL, at itemIndex: Int) {
//        self.itemURL = itemURL
//        self.itemIndex = itemIndex
//    }
//    
//    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
//        return [.URL]
//    }
//    
//    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
//        switch type {
//        case .URL:
//            return itemURL
//        case .tableViewIndex:
//            return itemIndex
//        default:
//            return nil
//        }
//    }
//}


