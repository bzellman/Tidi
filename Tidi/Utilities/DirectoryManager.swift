  //
//  DirectoryManager.swift
//  Tidi
//
//  Created by Brad Zellman on 12/19/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa


  
  class DirectoryManager: NSObject {
    //MARK: Paramaters
    var bookmarks = [URL : Data]()
    
    //MARK: URL Security Scoped Bookmark Methods
    
    func bookmarkURL() -> URL {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count-1]
        let url = appSupportURL.appendingPathComponent("Bookmarks.dict")
        return url
    }
    
    func loadBookmarks() {
        let url = bookmarkURL()
        if fileExists(url: url) {
            let group = DispatchGroup()
            group.enter()
            do {
                let fileData = try Data(contentsOf: url)
                if let fileBookmarks = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! [URL : Data]? {
                    bookmarks = fileBookmarks
                    for bookmark in bookmarks {
                        restoreBookmark(bookmark: bookmark)
                    }
                }
            group.leave()
            }
            catch {
                AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "There was an error loading your saved folders" , informativeText: "Please re-add them and try again", buttonText: "Ok")
                print("There was an error loading bookmarks")
                group.leave()
            }
            group.wait()
        }
    }
    
    func saveBookmarks() {
        let url = bookmarkURL()
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: bookmarks as Any, requiringSecureCoding: false)
            try data.write(to: url)
        }
        catch {
            AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "There was an error saving Tidi's permissions for this folder \(url.absoluteString).", informativeText: "Please try again", buttonText: "Ok")
            print("There was an error save bookmarks")
        }
        
    }
    
    func storeBookmark(url: URL){
        loadBookmarks()
        print("URL: \(url)")
        do {
            let data = try url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            bookmarks[url] = data
        }
        catch {
            AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "There was an error storing Tidi's permissions for this folder \(url.absoluteString)." , informativeText: "Please try again", buttonText: "Ok")
        }
    }
    
    
    func restoreBookmark(bookmark: (key: URL, value: Data)) {
        print(bookmark.key)
        let restoredURL : URL?
        var isStale = false
        
        if fileExists(url: bookmark.key) {
            do {
                restoredURL = try URL(resolvingBookmarkData: bookmark.value, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            }
            catch {
                print("ERROR restoring BOOKMARK")
                restoredURL = nil
            }
//            isStale = true
            if let url = restoredURL {
                if isStale {
                    print("\(url)is Stale")
                    if fileExists(url: url){
                        removeURL(url: url)
                        allowFolder(urlToAllow: url)
                    } else {
                        AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "Uh Oh! There might be a problem", informativeText: "Tidi previously had access to \(url), but it seems that that file has moved or no longer exists. \n\nIf you still need access to that folder, please select it in it's new location", buttonText: "Okay")
                        removeURL(url: url)
                    }
                }
                else {
                    if !url.startAccessingSecurityScopedResource() {
                        print("Could not access \(url.path)")
                    }
                    print("no errors")
                }
            }
        } else {
            removeURL(url: bookmark.key)
        }
        
    }
    
    func allowFolder(urlToAllow: URL) {
        print("URL TO ALLOW: \(urlToAllow)")
       storeBookmark(url: urlToAllow)
       saveBookmarks()
    }
    
    func clearBookmarks(){
        bookmarks.removeAll()
    }
    
    func removeURL(url: URL){
        bookmarks.removeValue(forKey: url)
        saveBookmarks()
    }

    //MARK: General Directory and File Convenience Methods
    func createDirectory(url: URL) -> Bool {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
    
    func fileExists(url: URL) -> Bool
    {
        var isDir = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)

        return exists
    }
    
    func contentsOf(folder: URL) -> [URL] {
        let fileManager = FileManager.default
        
        do {
            let folderContents = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return folderContents
        } catch {
            return []
        }
    }
    
    func isFolder(filePath: String) -> Bool {
        let fileNSURL = NSURL(fileURLWithPath: filePath)
        
        do {
            let itemTypeIdentifier = try fileNSURL.resourceValues(forKeys: [.typeIdentifierKey]).first?.value
            
            if itemTypeIdentifier as! String == String(kUTTypeFolder.self) {
                return true
            } else {
                return false
            }
            
        } catch {
            return false
        }
    }
    
    func getDirectorySizeWithSubfolders(urlOfDirectory : URL) -> String? {
        
        if isFolder(filePath: urlOfDirectory.path) {
            var folderSize = 0
            (FileManager.default.enumerator(at: urlOfDirectory, includingPropertiesForKeys: nil)?.allObjects as? [URL])?.lazy.forEach {
                folderSize += (try? $0.resourceValues(forKeys: [.totalFileAllocatedSizeKey]))?.totalFileAllocatedSize ?? 0
            }
            let  byteCountFormatter =  ByteCountFormatter()
            byteCountFormatter.allowedUnits = .useAll
            byteCountFormatter.countStyle = .file
            let sizeToDisplay = byteCountFormatter.string(for: folderSize) ?? ""
            return sizeToDisplay
        } else {
            return nil
        }
        
    }
    
    func getNumberOfItemsInDirectory(urlOfDirectory : URL) -> Int? {
    
        do {
            return try FileManager.default.contentsOfDirectory(atPath: urlOfDirectory.path).count
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
    }
}
