//
//  DestinationCollectionItem.swift
//  Tidi
//
//  Created by Brad Zellman on 1/26/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa

protocol SetRightClickedItemDelegate : AnyObject {
    func setRightClickedItem(pointOfItem : NSPoint)
}

class DestinationCollectionItem: NSCollectionViewItem {

    var removeItemDelegate : SetRightClickedItemDelegate?

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
    
    override func rightMouseDown(with event: NSEvent) {
        let pointOfClick : NSPoint = NSPoint(x: self.view.frame.origin.x, y: self.view.frame.origin.y)
//        let pointOfMouse : NSPoint = NSPoint(x: event.locationInWindow., y: event.absoluteY)
        print(pointOfMouse)
        print(pointOfClick)
        removeItemDelegate?.setRightClickedItem(pointOfItem: pointOfClick)
    }
}


