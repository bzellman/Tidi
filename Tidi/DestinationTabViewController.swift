//
//  DestinationTabViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 1/23/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class DestinationTabViewController: NSTabViewController  {
    
    var destinationTableViewController : TidiTableViewController?
    var destinationCollectionViewController : DestinationCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let indexOfTableView = self.tabView.indexOfTabViewItem(withIdentifier: "destinationTableView")
        let tabViewItemIndex = self.tabViewItems[indexOfTableView]
        destinationTableViewController = tabViewItemIndex.viewController as! TidiTableViewController?
    }
}
