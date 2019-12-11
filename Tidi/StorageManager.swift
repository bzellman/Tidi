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
    var userHomeDirectory : URL = URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.deletingLastPathComponent().relativePath)
    
    let defaultLaunchFolderKey : String = "defaultLaunchFolder"
    let defaultDestinationFolderKey : String = "destinationDestinationFolder"
    let defaultQuickDropFolderArrayKey : String = "quickDropFolderArray"
    let reminderNotificationKey : String = "currentReminderNotifications"
    let notificaionAlertAuthorizationKey : String = "notificationAlertAuthorization"
    let onboardingViewControllerKey : String = "onboardingViewController"
    
    func getOnboardingStatus() -> Bool {
        if userDefaults.value(forKey: onboardingViewControllerKey) == nil || false {
            return false
        } else {
            return true
        }
    }
    func saveDefaultSourceFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: defaultLaunchFolderKey)
    }
    
    func saveDownloadsFolderAsSourceFolder(){
        let userDownloadsDirectory : URL = userHomeDirectory.appendingPathComponent("Downloads")
        userDefaults.set(userDownloadsDirectory ,forKey: defaultLaunchFolderKey)
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
    
    func addDirectoryToQuickDropArray(directoryToAdd : String) -> Bool {
        var quickDropDefaultStringArray : [String] = getQuickDropArray()
        var isNoDuplicates = true
        
        if quickDropDefaultStringArray.count > 0 {
            
            for item in quickDropDefaultStringArray {
                if item == directoryToAdd {
                    isNoDuplicates = false
                    break
                }
            }
            
            quickDropDefaultStringArray.append(directoryToAdd)
            
        } else {
            quickDropDefaultStringArray = [directoryToAdd]
        }
        if isNoDuplicates == true {
            userDefaults.set(quickDropDefaultStringArray, forKey: defaultQuickDropFolderArrayKey)
            return true
        } else {
            return false
        }
        
    }
    
    func getQuickDropArray() -> [String] {
       
        if userDefaults.array(forKey: defaultQuickDropFolderArrayKey) != nil {
            let quickDropDefaultURLArray : [String] = userDefaults.array(forKey: defaultQuickDropFolderArrayKey) as! [String]
            return quickDropDefaultURLArray
        } else {
            return []
        }
        
    }
    
    func removeQuickDropItem(row : Int) {
        var quickDropStringArray : [String] = getQuickDropArray()
        quickDropStringArray.remove(at: row)
        
        userDefaults.set(quickDropStringArray, forKey: defaultQuickDropFolderArrayKey)
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
    
    func setReminderNotificationToUserDefaults(hour : Int, minute : Int, isPM : Bool, daysSetArray : [Int], isSet : Bool) -> Bool {
        let currentNotification = TidiNotificationSettings(hour: hour, minute: minute, isPM: isPM, daysSetArray: daysSetArray, isSet: isSet)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(currentNotification) {
            userDefaults.set(encoded, forKey: reminderNotificationKey)
            //ToDo: Error handling
            return true
        } else {
            return false
        }
    }
    
    func getReminderNotificationFromUserDefaults() -> (hour : Int, minute : Int, isPM : Bool, daysSetArray : [Int], isSet : Bool)? {
        if let currentNotification = userDefaults.object(forKey: reminderNotificationKey) as? Data {
            let decoder = JSONDecoder()
            if let reminderNotification = try? decoder.decode(TidiNotificationSettings.self, from: currentNotification) {
                return (reminderNotification.hour, reminderNotification.minute, reminderNotification.isPM, reminderNotification.daysSetArray, reminderNotification.isSet)
            }
        }
        return nil
    }
    
    func setNotificationAuthorizationState(isAuthorizationGranted : String) {
        userDefaults.set(isAuthorizationGranted, forKey: notificaionAlertAuthorizationKey)
    }
    
    func getNotificationAuthorizationState() -> String {
        return userDefaults.string(forKey: notificaionAlertAuthorizationKey) ?? "notSet"
    }
    //TODO: NEED TO ADD WAY TO MODIFY + RESET DEFAULT DESTINATION STATE
    
    // MARK: MOVE FILES
    //To-do: Clean-up
    //To-do: Make Async Again
    func moveItem(atURL: URL, toURL: URL, completion: @escaping (Bool, Error?) -> ()) {
        
        //Get the last part of the file name to be moved and append to the destination file URL for move
        let toURLwithFileName : URL = URL(fileURLWithPath: toURL.path + "/" + atURL.lastPathComponent)
//        DispatchQueue.global(qos: .utility).sync {
                do {
                    try FileManager.default.moveItem(at: atURL, to: toURLwithFileName)
                    completion(true, nil)
                } catch {
                    completion(false, error)
                }
                
        }

}
