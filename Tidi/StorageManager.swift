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

    let userDefaults = UserDefaults.standard
    let defaultLaunchFolerKey : String = "defaultLaunchFolder"
    
    func saveDefaultLaunchFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: defaultLaunchFolerKey)
        print(userDefaults.url(forKey: defaultLaunchFolerKey) as Any)
    }
    
    func checkForDefaultLaunchFolder() -> (URL?)? {
        
        if userDefaults.url(forKey: defaultLaunchFolerKey) != nil {
            return userDefaults.url(forKey: defaultLaunchFolerKey)
        }
            return nil
    }
    
}
