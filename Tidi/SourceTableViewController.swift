//
//  SourceTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/11/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class SourceTableViewController: TidiTableViewController {

    
    @IBOutlet weak var sourceTableView: NSTableView!
    
    
    
    
    //Mark: - Properties
    
    
    override func viewDidLoad() {
        
        self.tidiTableView = sourceTableView
        self.currentTableID = "SourceTableViewController"
        super.viewDidLoad()
        
        print(self.identifier)
    }
    
    
}
