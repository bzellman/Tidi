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
    
    func showSheetAlertWithOneAction(messageText: String, dismissButtonText: String, actionButtonText : String, presentingView : NSWindow, actionButtonClosure: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.addButton(withTitle: actionButtonText)
        alert.addButton(withTitle: dismissButtonText)
        alert.beginSheetModal(for: presentingView) { (response) in
            if response == .alertFirstButtonReturn {
                actionButtonClosure()
            }
        }
    }
    
    func showPopUpAlertWithOneAction(messageText: String, dismissButtonText: String, actionButtonText : String, presentingView : NSWindow, actionButtonClosure: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.addButton(withTitle: actionButtonText)
        alert.addButton(withTitle: dismissButtonText)
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            actionButtonClosure()
            presentingView.close()
        }
    }

    func showPopUpAlertWithOnlyDismissButton(messageText: String, informativeText : String, buttonText: String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.addButton(withTitle: buttonText)
        alert.runModal()
    }

}
