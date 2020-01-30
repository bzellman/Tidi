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
        super.draw(dirtyRect)

        let dashHeight: CGFloat = 3
        let dashLength: CGFloat = 10
        let dashColor: NSColor = .red

        // setup the context
        let currentContext = NSGraphicsContext.current!.cgContext
        currentContext.setLineWidth(dashHeight)
        currentContext.setLineDash(phase: 0, lengths: [dashLength])
        currentContext.setStrokeColor(dashColor.cgColor)

        // draw the dashed path
        currentContext.addRect(bounds.insetBy(dx: dashHeight, dy: dashHeight))
        currentContext.strokePath()
    }
    
}
