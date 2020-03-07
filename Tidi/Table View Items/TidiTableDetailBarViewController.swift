//
//  TidiTableDetailBarViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 3/7/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa

class TidiTableDetailBarViewController : NSViewController, TidiDirectoryDetailLabelDelegate {
    
    var detailLabel : NSTextField?
    
    func updateDirectoryDetailLabel(newLabelString: String) {
        print(newLabelString)
        detailLabel!.stringValue = newLabelString
    }
    
}
