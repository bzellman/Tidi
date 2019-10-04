//
//  DestinationTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/11/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class DestinationTableViewController: TidiTableViewController {
    
    //Properties inherited from TidiTableViewController
    
    
    
    
    
    @IBOutlet weak var destinationTableView: NSTableView!
    
    @IBAction func setDestinationFolderButtonPushed(_ sender: Any) {
        openFilePickerToChooseFile()
    }
    
    override func viewDidLoad() {

        self.tidiTableView = destinationTableView
        self.currentTableID = "DestinationTableViewController"
        super.viewDidLoad()

        
    }
}
