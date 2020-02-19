//
//  DestinationTableBottomLabelViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 2/14/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class DestinationTableBottomLabelViewController: NSViewController {
    @IBOutlet weak var filePathLabel : NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filePathLabel.stringValue = "TO SET"
    }
    
}
