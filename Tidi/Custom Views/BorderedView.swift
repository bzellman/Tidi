//
//  BorderedView.swift
//  Tidi
//
//  Created by Brad Zellman on 1/29/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa

class BorderedView: NSView {
    

    override func draw(_ dirtyRect: NSRect) {
   
        let path : NSBezierPath = NSBezierPath(roundedRect: self.bounds, xRadius: 10.0, yRadius: 10.0)
        let cgpath : CGPath = CGPath(roundedRect: NSRectToCGRect(self.bounds), cornerWidth: 10.0, cornerHeight: 10.0, transform: nil)
        path.addClip()
        
        super.draw(dirtyRect)

        let dashHeight: CGFloat = 2
        let dashLength: CGFloat = 6
        let dashColor: NSColor = .lightGray

        // setup the context
        let currentContext = NSGraphicsContext.current!.cgContext
        currentContext.setLineWidth(dashHeight)
        currentContext.setLineDash(phase: 0, lengths: [dashLength])
        currentContext.setStrokeColor(dashColor.cgColor)

        // draw the dashed path
        currentContext.addPath(cgpath)
        currentContext.strokePath()
    }
    

    
}
