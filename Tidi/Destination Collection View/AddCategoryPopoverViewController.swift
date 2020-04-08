//
//  AddCategoryPopoverViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 2/18/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa



protocol AddCategoryPopoverViewControllerDelegate: AnyObject {
    func createNewCategory(newDirectoryNameString : String)
}



class AddCategoryPopoverViewController: NSViewController, NSTextFieldDelegate  {
    
    
    @IBOutlet weak var newCategoryNameTextField: NSTextField!
    @IBOutlet weak var newCategoryButtonOutlet: NSButton!
    weak var delegate: AddCategoryPopoverViewControllerDelegate?
    
    
    @IBAction func addNewCategoryButtonPressed(_ sender: Any) {
       createNewCategory()
    }
    
    @IBAction func newCategoryNameTextFieldAction(_ sender: Any) {
        createNewCategory()
    }
    
    func createNewCategory() {
        if newCategoryNameTextField.stringValue.count > 0 && newCategoryNameTextField.stringValue.count < 50 { delegate?.createNewCategory(newDirectoryNameString: newCategoryNameTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
            self.dismiss(self)
        }
    }
    
}
