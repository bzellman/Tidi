//
//  TidiTableDetailBarViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 3/3/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa

class DestinationDetailBarViewController: TidiTableDetailBarViewController {
    
    @IBOutlet weak var destinationDetailLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailLabel = destinationDetailLabel
    }
    

    
}
