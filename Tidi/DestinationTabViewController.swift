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
    
    enum destinationDisplayType {
        case destinationTable
        case destinationCollection
    }
    var destinationTableViewController : TidiTableViewController?
    var destinationCollectionViewController : DestinationCollectionViewController?
    var indexOfTableView : Int?
    var tableViewItem : NSTabViewItem?
    var indexOfCollectionView : Int?
    var collectionViewItem : NSTabViewItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indexOfTableView = self.tabView.indexOfTabViewItem(withIdentifier: "destinationTableView")
        tableViewItem = self.tabViewItems[indexOfTableView!]
        indexOfCollectionView = self.tabView.indexOfTabViewItem(withIdentifier: "destinationCollectionView")
        collectionViewItem = self.tabViewItems[indexOfCollectionView!]
        destinationTableViewController = tableViewItem!.viewController as! TidiTableViewController?
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.toogleDestinationTypeButtonPushed), name: NSNotification.Name("destinationTypeDidChange"), object: nil)
    }
    

    @objc func toogleDestinationTypeButtonPushed(notification : Notification) {
           let selectedSegment = notification.userInfo!["segment"] as! Int
           if selectedSegment == 0 {
               self.tabView.selectTabViewItem(at: indexOfTableView!)
           } else if selectedSegment == 1 {
               self.tabView.selectTabViewItem(at: indexOfCollectionView!)
           }
       }
    
}
