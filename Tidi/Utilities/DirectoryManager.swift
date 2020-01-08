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
        let url = bookmarkURL()
        
        if fileExists(url: url) {
            let group = DispatchGroup()
            group.enter()
            do {
                let fileData = try Data(contentsOf: url)
                if let fileBookmarks = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! [URL : Data]? {
                    bookmarks = fileBookmarks
                    print(bookmarks.count)
                    for bookmark in bookmarks {
                        print(bookmark)
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
            AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "There was an error saving Tidi's permissions for this folder." , informativeText: "Please try again", buttonText: "Ok")
            print("There was an error save bookmarks")
        }
        
    }
    
    func storeBookmark(url: URL){
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
        let restoredURL : URL?
        var isStale = false
        
        do {
            restoredURL = try URL(resolvingBookmarkData: bookmark.value, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        }
        catch {
            print("ERROR restoring BOOKMARK")
            restoredURL = nil
        }
        
        if let url = restoredURL {
            if isStale {
                storeBookmark(url: restoredURL!)
                saveBookmarks()
                loadBookmarks()
            } else {
                if !url.startAccessingSecurityScopedResource() {
                    print("Could not access \(url.path)")
                }
            }
        }
    }
    
    func allowFolder(urlToAllow: URL) {
       storeBookmark(url: urlToAllow)
       saveBookmarks()
    }
    
//    func clearBookmarks(){
//        let url = bookmarkURL()
//
//        do {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: bookmarks as Any, requiringSecureCoding: false)
//            try data.w
//        }
//        catch {
//            AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "There was an error saving Tidi's permissions for this folder." , informativeText: "Please try again", buttonText: "Ok")
//            print("There was an error save bookmarks")
//        }
//    }
}