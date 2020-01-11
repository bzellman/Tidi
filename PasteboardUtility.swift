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

    var tidiFile : TidiFile
    var index: Int


    init(tidiFile : TidiFile, at index: Int) {
        self.tidiFile = tidiFile
        self.index = index
    }

    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.tidiFile, .tableViewIndex]
    }


    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        switch type {
        case .tidiFile:
            return try? PropertyListEncoder().encode(self.tidiFile)
        case .tableViewIndex:
            return index
        default:
            return nil
        }
    }


    static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.tidiFile, .tableViewIndex]
    }


}

extension NSPasteboard.PasteboardType {
    static let tableViewIndex = NSPasteboard.PasteboardType("com.bradzellman.tableViewIndex")
    static let tidiFile = NSPasteboard.PasteboardType("com.bradzellman.tidiFile")
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
    
    func tidiFile(forType type: NSPasteboard.PasteboardType) -> TidiFile? {
        guard let data = data(forType: type) else { print("ERROR"); return nil }
        let tidiFile : TidiFile = TidiFile.init(pasteboardPropertyList: data, ofType: NSPasteboard.PasteboardType.tidiFile)!
        return tidiFile
    }
}

