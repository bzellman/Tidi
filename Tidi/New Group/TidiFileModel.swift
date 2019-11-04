//
//  TidiFileModel.swift
//  Tidi
//
//  Created by Brad Zellman on 8/25/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

final class TidiFile : NSObject, Codable {
    var url : URL?
    var createdDateAttribute : Date?
    var modifiedDateAttribute : Date?
    var fileSizeAttribute : Int64?
    var isSelected : Bool
    
    
    //setting for a nil init so this can return nil values in case of failure to set attributes
    init( url : URL? = nil,
          createdDateAttribute : Date? = nil,
          modifiedDateAttribute : Date? = nil,
          fileSizeAttribute: Int64? = nil) {
        self.url = url
        self.createdDateAttribute = createdDateAttribute
        self.modifiedDateAttribute = modifiedDateAttribute
        self.fileSizeAttribute = fileSizeAttribute
        self.isSelected = false
    }
    
    convenience init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        guard let data = propertyList as? Data,
            let tidiFile = try? PropertyListDecoder().decode(TidiFile.self, from: data) else { return nil }
        self.init(url: tidiFile.url, createdDateAttribute: tidiFile.createdDateAttribute, modifiedDateAttribute: tidiFile.modifiedDateAttribute, fileSizeAttribute: tidiFile.fileSizeAttribute)
    }
    
}



extension TidiFile : NSPasteboardWriting, NSPasteboardReading
{
    
    public func writingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.WritingOptions {
        return .promised
    }
    
    public func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.tidiFile]
    }
    
    public func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        if type == .tidiFile {
            return try? PropertyListEncoder().encode(self)
        }
        return nil
    }
    
    public static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.tidiFile]
    }
    
    public static func readingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.ReadingOptions {
        return .asData
    }
    
}
