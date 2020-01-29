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
        view.wantsLayer = true
        self.highlightState = .asDropTarget
        view.layer?.cornerRadius = 8.0
        setDashedBoarder()
    }
    
    func setDashedBoarder() {
        let dashHeight: CGFloat = 3
        let dashLength: CGFloat = 10
        let dashColor: NSColor = .red

       // setup the context
        let currentContext = NSGraphicsContext.current!.cgContext
        currentContext.setLineWidth(dashHeight)
        currentContext.setLineDash(phase: 0, lengths: [dashLength])
        currentContext.setStrokeColor(dashColor.cgColor)

       // draw the dashed path
        currentContext.addRect(backgroundLayer.bounds.insetBy(dx: dashHeight, dy: dashHeight))
        currentContext.strokePath()
        
//    let dashedBoarder = CAShapeLayer()
//    dashedBoarder.strokeColor = NSColor.white.cgColor
//    dashedBoarder.lineDashPattern = [2, 2]
//    dashedBoarder.frame = backgroundLayer.bounds
//    dashedBoarder.fillColor = nil
//        dashedBoarder.path = CGPath.init(roundedRect: backgroundLayer.bounds, cornerWidth: 8.0, cornerHeight: 8.0, transform: nil)
//        backgroundLayer.layer?.addSublayer(dashedBoarder as CALayer)
    }
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            
            if isSelected {
                view.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
            } else {
                view.layer?.backgroundColor = NSColor.clear.cgColor
            }
        }
    }
    
    public override var highlightState: NSCollectionViewItem.HighlightState {
        didSet {
            guard self.highlightState != oldValue else { return }
//            updateViewSelection()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        print("MOUSE DOWN")
        if event.clickCount == 2 {
//            doubleClickActionHandler?()
        }
    }
       
    
}
