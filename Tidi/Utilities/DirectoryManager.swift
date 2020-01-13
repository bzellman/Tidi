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
    
    
    var bookmarks = [URL : Data]()
    
    func fileExists(url: URL) -> Bool
    {
        var isDir = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)

        return exists
    }
    
    func bookmarkURL() -> URL {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count-1]
        let url = appSupportURL.appendingPathComponent("Bookmarks.dict")
        return url
    }
    
    func loadBookmarks() {
        print("LoadCalled")
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
        print("saveCalled")
        let url = bookmarkURL()
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: bookmarks as Any, requiringSecureCoding: false)
            try data.write(to: url)
        }
        catch {
            AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "There was an error saving Tidi's permissions for this folder." , informativeText: "Please try again", buttonText: "Ok")
            print("There was an error save bookmarks")
        }
        
    }
    
    func storeBookmark(url: URL){
        print("storeCalled")
        loadBookmarks()
        do {
            let data = try url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            bookmarks[url] = data
        }
        catch {
            AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "There was an error saving this folder." , informativeText: "Please try again", buttonText: "Ok")
            print("There was an error storing bookmarks")
        }
    }
    
    
    func restoreBookmark(bookmark: (key : URL, value: Data)) {
        print("RestoreCalled")
        let restoredURL : URL?
        var isStale = false
        print("restoring \(bookmark.key)")
        
        if fileExists(url: bookmark.key) {
            do {
                restoredURL = try URL(resolvingBookmarkData: bookmark.value, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            }
            catch {
                print("ERROR restoring BOOKMARK")
                restoredURL = nil
            }
            
            if let url = restoredURL {
                if isStale {
                    print("\(url)is Stale")
                    if fileExists(url: url){
                        allowFolder(urlToAllow: url)
                    } else {
                        AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "Uh Oh! There might be a problem", informativeText: "Tidi previously had access to \(url), but it seems that that file has moved or no longer exists. \n\nIf you still need access to that folder, please select it in it's new location", buttonText: "Okay")
                        removeURL(url: url)
                    }
                } else {
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
       storeBookmark(url: urlToAllow)
       saveBookmarks()
    }
    
    func clearBookmarks(){
        bookmarks.removeAll()
    }
    
    func removeURL(url: URL){
        bookmarks.removeValue(forKey: url)
        
    }
}
