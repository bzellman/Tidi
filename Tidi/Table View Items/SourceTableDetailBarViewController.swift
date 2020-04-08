//
//  SourceTableDetailBarViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 3/5/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa

class SourceTableDetailBarViewController: TidiTableDetailBarViewController {
    
    
    @IBOutlet weak var sourceDetailLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailLabel = sourceDetailLabel
    }
    
}
