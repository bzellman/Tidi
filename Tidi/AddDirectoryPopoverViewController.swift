//
//  AddDirectoryPopoverViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 1/11/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

protocol AddDirectoryPopoverViewControllerDelegate: AnyObject {
    func createNewDirectory(newDirectoryNameString : String)
}



class AddDirectoryPopoverViewController: NSViewController, NSTextFieldDelegate  {
    
    
    @IBOutlet weak var newDirectoryNameTextField: NSTextField!
    @IBOutlet weak var newDirectoryButtonOutlet: NSButton!
    weak var delegate: AddDirectoryPopoverViewControllerDelegate?
    
    
    @IBAction func addNewDirectoryButtonPressed(_ sender: Any) {
       createNewDirectory()
    }
    
    @IBAction func newDirectoryNameTextFieldAction(_ sender: Any) {
        createNewDirectory()
    }
    
    func createNewDirectory() {
        if newDirectoryNameTextField.stringValue.count > 0 && newDirectoryNameTextField.stringValue.count < 50 { delegate?.createNewDirectory(newDirectoryNameString: newDirectoryNameTextField.stringValue)
            self.dismiss(self)
        }
    }
    
}
