//
//  PasteboardUtility.swift
//  Tidi
//
//  Created by Brad Zellman on 8/19/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

//import Foundation
import Cocoa

class PasteboardWriter: NSObject, NSPasteboardWriting, Codable {

    var tidiFile : TidiFile?
    var fileURL : URL?

    init(tidiFile : TidiFile) {
        self.tidiFile = tidiFile
    }
    
    init(fileURL : URL) {
        self.fileURL = fileURL
    }

    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.fileURL, .tidiFile]
    }


    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        switch type {
        case .fileURL:
            return try? PropertyListEncoder().encode(self.fileURL)

        case .tidiFile:
            return try? PropertyListEncoder().encode(self.tidiFile)
        default:
            return nil
        }
    }


    static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [ .fileURL, .tidiFile]
    }


}

extension NSPasteboard.PasteboardType {
    static let tidiFile = NSPasteboard.PasteboardType("com.bradzellman.tidiFile")
    static let fileURL = NSPasteboard.PasteboardType.fileURL
}


extension NSPasteboardItem {
    func tidiFile(forType type: NSPasteboard.PasteboardType) -> TidiFile? {
        guard let data = data(forType: type) else { print("ERROR"); return nil }
        let tidiFile : TidiFile = TidiFile.init(pasteboardPropertyList: data, ofType: NSPasteboard.PasteboardType.tidiFile)!
        return tidiFile
    }
    
    func fileURL(forType type: NSPasteboard.PasteboardType) -> URL? {
        guard let data = data(forType: type) else { print("ERROR"); return nil }
        var url : URL?
        do {
            url = try PropertyListDecoder().decode(URL.self, from: data) as! URL
        } catch {
//            url =  try? PropertyListDecoder().decode(NSPasteboard.PasteboardType.fileURL.rawValue, from: data)
//            print(url)
        }
        
        return url!
    }
}

