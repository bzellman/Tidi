//
//  DestinationCollectionHeaderViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 3/7/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa

class DestinationCollectionHeaderViewController: NSViewController, NSTextFieldDelegate {
    
    var headerId : Int?
    var headerView : DestinationCollectionHeaderView?

    @IBAction func removeButtonPushed(_ sender: Any) {
        headerView = self.view as! DestinationCollectionHeaderView
        NotificationCenter.default.post(name: NSNotification.Name("categoryRemoveButtonPushed"), object: nil, userInfo: ["categoryItemToRemove" : headerView!.headerID!])
    }
    
    @IBOutlet weak var headerTitle: NSTextField!
    
    @IBAction func textFieldUpdated(_ sender: Any) {
        headerView = self.view as! DestinationCollectionHeaderView
        NotificationCenter.default.post(name: NSNotification.Name("categoryHeaderUpdated"), object: nil, userInfo: ["newCategoryName" : headerTitle.stringValue, "categoryItemToUpdate" : headerView!.headerID!])

    }
}
