//
//  DestinationTableDetailBarViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 3/3/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa

class DestinationTableDetailBarViewController: NSViewController, DestinationDirectoryDetailLabelDelegate {
    
    @IBOutlet weak var directoryDetailLabel: NSTextField!
    
    func updateDestinationDirectoryDetailLabel(newLabelString: String) {
        directoryDetailLabel.stringValue = newLabelString
    }
    
}
