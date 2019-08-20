//
//  PasteboardUtility.swift
//  Tidi
//
//  Created by Brad Zellman on 8/19/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class PasteboardWriter: NSObject, NSPasteboardWriting {
    var fileURL : URL
    var fileNameString : String
    var index: Int
    
    init(fileURL : URL, fileNameString : String, at index: Int) {
        self.fileURL = fileURL
        self.fileNameString = fileNameString
        self.index = index
    }
    
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.URL, .string, .tableViewIndex]
    }
    
    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        switch type {
        case .string:
            return fileNameString
        case .URL:
            return fileURL
        case .tableViewIndex:
            return index
        default:
            return nil
        }
    }
}




extension NSPasteboard.PasteboardType {
    static let tableViewIndex = NSPasteboard.PasteboardType("com.bradzellman.tableViewIndex")
}


extension NSPasteboardItem {
    open func integer(forType type: NSPasteboard.PasteboardType) -> Int? {
        guard let data = data(forType: type) else { return nil }
        let plist = try? PropertyListSerialization.propertyList(
            from: data,
            options: .mutableContainers,
            format: nil)
        return plist as? Int
    }
}
