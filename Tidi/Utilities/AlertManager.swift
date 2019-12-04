//
//  AlertManager.swift
//  Tidi
//
//  Created by Brad Zellman on 12/3/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class AlertManager : NSObject {
    
    func showSheetAlertWithOnlyDismissButton(messageText: String, buttonText: String, presentingView : NSWindow) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.addButton(withTitle: buttonText)
        alert.beginSheetModal(for: presentingView, completionHandler: { (modalResponse) -> Void in
        })
        
    }
}
