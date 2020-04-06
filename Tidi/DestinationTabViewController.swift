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
    
    enum destinationDisplayType : Int {
        case destinationTable = 0
        case destinationCollection = 1
    }
    
    var destinationTableViewController : TidiTableViewController?
    var destinationCollectionViewController : DestinationCollectionViewController?
    var indexOfTableView : Int?
    var tableViewItem : NSTabViewItem?
    var indexOfCollectionView : Int?
    var collectionViewItem : NSTabViewItem?
    var detailBarViewController : DestinationCollectionDetailBarViewController?
    var currentSegmentType : destinationDisplayType?
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        indexOfTableView = self.tabView.indexOfTabViewItem(withIdentifier: "destinationTableView")
        tableViewItem = self.tabViewItems[indexOfTableView!]
        indexOfCollectionView = self.tabView.indexOfTabViewItem(withIdentifier: "destinationCollectionView")
        collectionViewItem = self.tabViewItems[indexOfCollectionView!]
        
        destinationTableViewController = tableViewItem!.viewController as! TidiTableViewController?
        destinationCollectionViewController = collectionViewItem!.viewController as! DestinationCollectionViewController?
        
        currentSegmentType = DestinationTabViewController.destinationDisplayType(rawValue: StorageManager().getDefaultDestinationView())
        setTabSegment(selectedSegment: currentSegmentType!.rawValue)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.toogleDestinationTypeButtonPushed), name: NSNotification.Name("destinationTypeDidChange"), object: nil)
        
    }
    
    func setTabSegment(selectedSegment : Int) {
        
        if selectedSegment == 0 {
            self.tabView.selectTabViewItem(at: indexOfTableView!)
           
            let contentViewController = self.parent as! MainWindowContainerViewController
            let quickDropTableViewController = contentViewController.quickDropViewController
            quickDropTableViewController?.delegate = destinationTableViewController as! DestinationTableViewController
            
        } else if selectedSegment == 1 {
            self.tabView.selectTabViewItem(at: indexOfCollectionView!)
        }
        
        currentSegmentType = DestinationTabViewController.destinationDisplayType(rawValue: selectedSegment)
    }

    @objc func toogleDestinationTypeButtonPushed(notification : Notification) {
        
        if let selectedSegment = notification.userInfo!["segment"] as? Int {
            setTabSegment(selectedSegment: selectedSegment)
            currentSegmentType = DestinationTabViewController.destinationDisplayType(rawValue: selectedSegment)
        }
   }
    
   
}
