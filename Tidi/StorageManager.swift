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
    let userHomeDirectory = FileManager.default.homeDirectoryForCurrentUser
    let defaultLaunchFolderKey : String = "defaultLaunchFolder"
    let destinationDestinationFolderKey : String = "destinationDestinationFolder"
    
    func saveDefaultLaunchFolder(_ launchFolder : URL?) {
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
        
        if userDefaults.url(forKey: destinationDestinationFolderKey) != nil {
            return userDefaults.url(forKey: destinationDestinationFolderKey)
        }
        return nil
    }
    
    //NEED TO ADD WAY TO MODIFY + RESET DEFAULT DESTINATION STATE
    
    // MARK: MOVE FILES
    func moveItem(at url: URL, toUrl: URL, completion: @escaping (Bool, Error?) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            do {
                try FileManager.default.moveItem(at: url, to: toUrl)
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

// Method to be used when/during drag NEED to
//    moveItem(at: fileFromURL, toUrl: fileToURLPath) { (succeded, error) in
//    if succeded {
//    print("FileMoved")
//    } else {
//    print("Something went wrong")
//    print(error as Any)
//    }
//    }

    
    
}


