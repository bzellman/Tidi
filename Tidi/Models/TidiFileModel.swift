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
    var fileType : String?
    var createdDateAttribute : Date?
    var modifiedDateAttribute : Date?
    var fileSizeAttribute : Int64?
    var isSelected : Bool?
    
    init( url : URL ,
          createdDateAttribute : Date,
          modifiedDateAttribute : Date,
          fileSizeAttribute : Int64,
          fileType : String ) {
        self.url = url
        self.createdDateAttribute = createdDateAttribute
        self.modifiedDateAttribute = modifiedDateAttribute
        self.fileSizeAttribute = fileSizeAttribute
        self.fileType = fileType
        self.isSelected = false
    }
    
    convenience init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        guard let data = propertyList as? Data,
            let tidiFile = try? PropertyListDecoder().decode(TidiFile.self, from: data) else { return nil }
        self.init(url: tidiFile.url!, createdDateAttribute: tidiFile.createdDateAttribute!, modifiedDateAttribute: tidiFile.modifiedDateAttribute!, fileSizeAttribute: tidiFile.fileSizeAttribute!, fileType: tidiFile.fileType!)
    }
    
    init?(url: URL) {
        
        var createdDateAttribute : Date?
        var modifiedDateAttribute : Date?
        var fileSizeAttribute : Int64?
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            for (key, value) in attributes {
                if key.rawValue == "NSFileModificationDate" {
                    modifiedDateAttribute = value as? Date
                }
                if key == FileAttributeKey.creationDate {
                    createdDateAttribute = value as? Date
                }

                if  key == FileAttributeKey.size {
                    fileSizeAttribute = value as? Int64
                }
            }
            
            let fileNSURL = url as NSURL
            let itemTypeIdentifier = try fileNSURL.resourceValues(forKeys: [.typeIdentifierKey]).first?.value
            
            if url != nil && createdDateAttribute != nil && modifiedDateAttribute != nil && modifiedDateAttribute != nil && fileSizeAttribute != nil && itemTypeIdentifier != nil {
                self.url = url
                self.createdDateAttribute = createdDateAttribute
                self.modifiedDateAttribute = modifiedDateAttribute
                self.fileSizeAttribute = fileSizeAttribute
                self.fileType = itemTypeIdentifier as? String
                self.isSelected = false
            } else {
                return nil
            }
         
        } catch {
            print("ERROR CREATING TIDIFILE WITH URL: \(url)")
            print(error)
            return nil
        }
    }
}



extension TidiFile : NSPasteboardWriting, NSPasteboardReading
{
    
    public func writingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.WritingOptions {
        return .promised
    }
    
    public func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.fileURL]
    }
    
    public func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        if type == .fileURL {
            return try? PropertyListEncoder().encode(self)
        }
        return nil
    }
    
    public static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.fileURL]
    }
    
    public static func readingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.ReadingOptions {
        return .asData
    }
    
}
