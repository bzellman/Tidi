//
//  StorageManager.swift
//  Tidi
//
//  Created by Brad Zellman on 8/16/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

struct TidiNotificationSettings : Codable {
    var hour : Int
    var minute : Int
    var isPM : Bool
    var daysSetArray : [Int]
    var isSet : Bool
}

class StorageManager: NSObject {

    // MARK: SAVE USER DEFAULTS
    let userDefaults = UserDefaults.standard
    let notificationPath = Bundle.main.path(forResource: "notification", ofType: "plist")
    //Not able to get user's home directory using homeDirectory - not sure why: hacking with this instead
    let userHomeDirectory : URL = URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.deletingLastPathComponent().relativePath)
    
    let defaultLaunchFolderKey : String = "defaultLaunchFolder"
    let defaultDestinationFolderKey : String = "destinationDestinationFolder"
    let defaultQuickDropFolderArrayKey : String = "quickDropFolderArray"
    
    func saveDefaultSourceFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: defaultLaunchFolderKey)
    }
    
    func saveNewDefaultLaunchFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: defaultLaunchFolderKey)
    }
    
    func clearDefaultDetinationFolder() {
        userDefaults.removeObject(forKey: defaultDestinationFolderKey)
    }
    
    func checkForSourceFolder() -> (URL?)? {
        
        if userDefaults.url(forKey: defaultLaunchFolderKey) != nil {
            return userDefaults.url(forKey: defaultLaunchFolderKey)
        } else {
            return nil
        }
    }
    
    func addDirectoryToQuickDropArray(directoryToAdd : String) {
        var quickDropDefaultURLArray : [String] = []
        if userDefaults.array(forKey: defaultQuickDropFolderArrayKey) != nil {
            quickDropDefaultURLArray = userDefaults.array(forKey: defaultQuickDropFolderArrayKey) as! [String]
            quickDropDefaultURLArray.append(directoryToAdd)
        } else {
            quickDropDefaultURLArray = [directoryToAdd]
        }
        print(quickDropDefaultURLArray)
        userDefaults.set(quickDropDefaultURLArray, forKey: defaultQuickDropFolderArrayKey)
    }
    
    func getQuickDropArray() -> [String] {
        if userDefaults.array(forKey: defaultQuickDropFolderArrayKey) != nil {
            var quickDropDefaultURLArray : [String] = userDefaults.array(forKey: defaultQuickDropFolderArrayKey) as! [String]
            return quickDropDefaultURLArray
        } else {
            return []
        }
    }
    
    func saveDefaultDestinationFolder(_ destinationFolder : URL?) {
        userDefaults.set(destinationFolder, forKey: defaultDestinationFolderKey)
    }
    
    func setNewDestinationLaunchFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: defaultDestinationFolderKey)
    }
    
    func checkForDestinationFolder() -> (URL?)? {

        if userDefaults.url(forKey: defaultDestinationFolderKey) != nil {
            return userDefaults.url(forKey: defaultDestinationFolderKey)
        } else {
            return nil
        }
        
    }
    
    func getNotificationPlist() -> (hour : Int, minute : Int, isPM : Bool, daysSetArray : [Int], isSet : Bool)? {

        if  let path = notificationPath,
            let xml = FileManager.default.contents(atPath: path),
            let currentNotification = try? PropertyListDecoder().decode(TidiNotificationSettings.self, from: xml)
        {
//            print(currentNotification)
            return (currentNotification.hour, currentNotification.minute, currentNotification.isPM, currentNotification.daysSetArray, currentNotification.isSet)
        } else {
            return nil
        }
    }
    
    func setNotificationPlist(hour : Int, minute : Int, isPM : Bool, daysSetArray : [Int], isSet : Bool) -> Bool {
        let currentNotification = TidiNotificationSettings(hour: hour, minute: minute, isPM: isPM, daysSetArray: daysSetArray, isSet: isSet)
        print(currentNotification)
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let path = Bundle.main.path(forResource: "notification", ofType: "plist")!
    
        do {
            let data = try encoder.encode(currentNotification)
            let pathURL = URL(fileURLWithPath: path)
            try data.write(to: pathURL)
            print("success")
            return true
        } catch {
            print(error)
            //ToDo gracefully handle
            return false
        }
        
        
    }
    
    //NEED TO ADD WAY TO MODIFY + RESET DEFAULT DESTINATION STATE
    
    // MARK: MOVE FILES
    //Not using row
    func moveItem(atURL: URL, toURL: URL, row: Int, completion: @escaping (Bool, Error?) -> ()) {
        
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
