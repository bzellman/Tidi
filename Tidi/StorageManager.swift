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
    ///Not able to get user's home directory using homeDirectory
    
    let defaultLaunchFolderKey : String = "defaultLaunchFolder"
    let defaultDestinationFolderKey : String = "destinationDestinationFolder"
    let defaultQuickDropFolderArrayKey : String = "quickDropFolderArray"
    let reminderNotificationKey : String = "currentReminderNotifications"
    let notificaionAlertAuthorizationKey : String = "notificationAlertAuthorization"
    let onboardingViewControllerKey : String = "onboardingViewController"
    let destinationCollectionItemsKey : String = "destinationCollectionItems"
    let destinationCollectionCategoryItemsKey : String = "destinationCollectionCategoryItems"
    
    //MARK: Onboarding and Table Folder Defaults
    
    func getOnboardingStatus() -> Bool {
        if userDefaults.value(forKey: onboardingViewControllerKey) == nil || false {
            return false
        } else {
            return true
        }
    }
    
    func setOnboardingStatus(onboardingComplete : Bool) {
            userDefaults.set(onboardingComplete, forKey: onboardingViewControllerKey)
    }
    
    func saveDefaultSourceFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: defaultLaunchFolderKey)
        DirectoryManager().allowFolder(urlToAllow: launchFolder!)
    }
    
    
    
    func saveDownloadsFolderAsSourceFolder() -> Bool {

        let downloadURL : URL = FileManager.default.urls(for: .downloadsDirectory , in: .userDomainMask).first!
        if downloadURL.isAlias()! {
            do {
                let downloadOriginalURL : URL = try URL(resolvingAliasFileAt: downloadURL)
                DirectoryManager().allowFolder(urlToAllow: downloadOriginalURL)
                userDefaults.set(downloadOriginalURL, forKey: defaultLaunchFolderKey)
                return true
            } catch {
                print("ERROR")
                return false
            }
        }
        return false
    }

    
    func saveNewDefaultLaunchFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: defaultLaunchFolderKey)
        DirectoryManager().allowFolder(urlToAllow: launchFolder!)
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
    
    //MARK: Quick Drop
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
    
    func removeQuickDropItemWithURL(directoryURLString : String) {
        var quickDropStringArray : [String] = getQuickDropArray()
        quickDropStringArray.removeAll { $0 == directoryURLString }
        
        userDefaults.set(quickDropStringArray, forKey: defaultQuickDropFolderArrayKey)
        
    }
    
    //MARK: Destination Collection Items
    
    func addDirectoryToDestinationCollection(newDestinationCollectionItem : (categoryName : String, urlString : String)) -> Bool {
        
        var destinationCollectionTupleArray : [(categoryName : String, urlString : String)] = getDestinationCollection() as? [(categoryName: String, urlString: String)] ?? []
        var isNoDuplicates = true
        
        if destinationCollectionTupleArray.count > 0 {
            
            for item in destinationCollectionTupleArray {
                if item == (newDestinationCollectionItem.categoryName, newDestinationCollectionItem.urlString) {
                    isNoDuplicates = false
                    break
                }
            }
            
            if isNoDuplicates == false {
                return false
            } else {
               
                destinationCollectionTupleArray.append((newDestinationCollectionItem.categoryName, newDestinationCollectionItem.urlString))
            }
            
        } else {
            destinationCollectionTupleArray = [(newDestinationCollectionItem.categoryName, newDestinationCollectionItem.urlString)]
        }
        
        var destinationCollectionItemArrayAsData : [Data] = []
        for item in destinationCollectionTupleArray {
            
            let collectionItemAsDataToAdd : Data = try! JSONEncoder().encode(CollectionItem(categoryName: item.categoryName, urlString: item.urlString))
            destinationCollectionItemArrayAsData.append(collectionItemAsDataToAdd)
        }
        userDefaults.set(destinationCollectionItemArrayAsData, forKey: destinationCollectionItemsKey)
        
        return true
        
    }
    
    func getDestinationCollection() -> [(categoryName : String, urlString : String)] {
        if userDefaults.array(forKey: destinationCollectionItemsKey) != nil {
            let destinationCollectionItemArrayAsData : [Data] = userDefaults.array(forKey: destinationCollectionItemsKey) as! [Data]
            var destinationCollectionItemArray : [(categoryName : String, urlString : String)] = []
            
            for collectionDataItem in destinationCollectionItemArrayAsData {
                let itemToAdd = try! JSONDecoder().decode(CollectionItem.self, from: collectionDataItem)
                destinationCollectionItemArray.append((itemToAdd.categoryName, itemToAdd.urlString))
                
            }
            return destinationCollectionItemArray ?? []
        } else {
            return []
        }
        
    }
    
    func removeDestinationCollectionItem(row : Int) {
//        var destinationCollectionStringArray : [(categoryName : String, urlString : String)] = getDestinationCollection()
//        destinationCollectionStringArray.remove(at: row)
//
//        userDefaults.set(destinationCollectionStringArray, forKey: destinationCollectionItemsKey)
    }
    

    func removeDestinationCollectionWithURL(categoryName : String, urlString : String) {
//        var destinationCollectionStringArray : [(categoryName : String, urlString : String)] = getDestinationCollection()
//        //To-Do
//        destinationCollectionStringArray.removeAll { $0.urlString == urlString && $0.categoryName == categoryName }
//
//        userDefaults.set(destinationCollectionStringArray, forKey: destinationCollectionItemsKey)
    }

    func clearAllDestinationCollection() {
        userDefaults.set([], forKey: destinationCollectionItemsKey)
    }
    
    
    //MARK: Destination Collection Categories
    
    func addCategoryToDestinationCollection(categoryName : String) -> Bool {
        
        var destinationCategoryCollectionArray : [String] = getDestinationCollectionCategory()
        var isNoDuplicates = true
        
        if destinationCategoryCollectionArray.count > 0 {
            
            for item in destinationCategoryCollectionArray {
                if item == categoryName {
                    isNoDuplicates = false
                    break
                }
            }
            
            if isNoDuplicates == false {
                return false
            } else {
              destinationCategoryCollectionArray.append(categoryName)
            }
            
        } else {
            destinationCategoryCollectionArray = [categoryName]
        }
        
        userDefaults.set(destinationCategoryCollectionArray, forKey: destinationCollectionCategoryItemsKey)
        return true
        
    }
    
    func getDestinationCollectionCategory() -> [String] {
       
        if userDefaults.array(forKey: destinationCollectionCategoryItemsKey) != nil {
            print(userDefaults.array(forKey: destinationCollectionCategoryItemsKey))
            let destinationCollectionCategoryDefaultURLArray : [String] = userDefaults.array(forKey: destinationCollectionCategoryItemsKey) as! [String]
            return destinationCollectionCategoryDefaultURLArray
        } else {
            return []
        }
        
    }
    
    func removeDestinationCollectionCategory(row : Int) {
        var destinationCollectionStringArray : [String] = getDestinationCollectionCategory()
        destinationCollectionStringArray.remove(at: row)
        
        userDefaults.set(destinationCollectionStringArray, forKey: destinationCollectionCategoryItemsKey)
    }
    

    func removeDestinationCollectionCategoryWithName(category : String) {
        var destinationCollectionStringArray : [String] = getDestinationCollectionCategory()
        //To-Do: Need to also remove items stored in categories
        destinationCollectionStringArray.removeAll { $0 == category }
        
        userDefaults.set(destinationCollectionStringArray, forKey: destinationCollectionCategoryItemsKey)
    }
    
    func clearAllDestinationCollectionCategories() {
        userDefaults.set([], forKey: destinationCollectionCategoryItemsKey)
    }
    
    //MARK: To Organize
    func saveDefaultDestinationFolder(_ destinationFolder : URL?) {
        userDefaults.set(destinationFolder, forKey: defaultDestinationFolderKey)
    }
    
    
    func setNewDestinationLaunchFolder(_ launchFolder : URL?) {
        userDefaults.set(launchFolder, forKey: defaultDestinationFolderKey)
        DirectoryManager().allowFolder(urlToAllow: launchFolder!)
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
    
    // MARK: MOVE FILES
    //To-do: Clean-up
    //To-do: Make Async Again
    func moveItem(atURL: URL, toURL: URL, completion: @escaping (Bool, Error?) -> ()) {
        
        ///Get the last part of the file name to be moved and append to the destination file URL for move
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

extension URL {
    func isAlias() -> Bool? {
        let values = try? self.resourceValues(forKeys: [.isSymbolicLinkKey, .isAliasFileKey])
        
        let alias : Bool = (values?.isAliasFile)!
        let symbolic : Bool = (values?.isSymbolicLink)!
        if alias && symbolic {
            return true
        }
        return false
    }
}
