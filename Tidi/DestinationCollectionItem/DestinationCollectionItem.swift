//
//  DestinationCollectionItem.swift
//  Tidi
//
//  Created by Brad Zellman on 1/26/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa

class DestinationCollectionItem: NSCollectionViewItem {

    @IBOutlet weak var backgroundLayer: NSView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.highlightState = .none
        view.wantsLayer = true
        view.layer?.cornerRadius = 8.0
        backgroundLayer.isHidden = true
        backgroundLayer.unregisterDraggedTypes()
        self.imageView?.unregisterDraggedTypes()
        self.textField?.unregisterDraggedTypes()
    }
    
}
