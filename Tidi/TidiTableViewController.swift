//
//  TidiTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/21/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

struct TidiFile {
    var url : URL?
    var createdDateAttribute : Date?
    var modifiedDateAttribute : Date?
    var fileSizeAttribute: Int?
    
    //setting for a nil init so this can return nil values in case of failure to set attributes
    init( url : URL? = nil,
        createdDateAttribute : Date? = nil,
        modifiedDateAttribute : Date? = nil,
        fileSizeAttribute: Int? = nil) {
        self.url = url
        self.createdDateAttribute = createdDateAttribute
        self.modifiedDateAttribute = modifiedDateAttribute
        self.fileSizeAttribute = fileSizeAttribute
    }
}

//class TidiTableViewController: NSTableViewController {
//    
//
//}

