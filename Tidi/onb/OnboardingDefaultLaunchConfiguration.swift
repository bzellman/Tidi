//
//  OnboardingDefaultLaunchConfiguration.swift
//  Tidi
//
//  Created by Bradley Zellman on 3/17/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa
import Foundation

class OnboardingDefaultLaunchConfiguration: NSViewController {

    let radioButtonController : TidiRadioButtonController = TidiRadioButtonController()
    let storageManager : StorageManager = StorageManager()
    @IBOutlet weak var fileListRadioButton: NSButton!
    @IBOutlet weak var folderGroupRadioButton: NSButton!
    
    @IBAction func folderRadioButtonSelected(_ sender: Any) {
        radioButtonController.buttonArrayUpdated(buttonSelected: folderGroupRadioButton)
    }
    
    @IBAction func fileListRadioButtonSelected(_ sender: Any) {
        radioButtonController.buttonArrayUpdated(buttonSelected: fileListRadioButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radioButtonController.buttonArray = [fileListRadioButton, folderGroupRadioButton]
        radioButtonController.defaultButton = fileListRadioButton
    }
    
    override func viewWillDisappear() {
        if radioButtonController.defaultButton == fileListRadioButton {
            storageManager.setDefaultDestinationView(defaultDestinationViewType: 0)
        } else if radioButtonController.defaultButton == fileListRadioButton {
            storageManager.setDefaultDestinationView(defaultDestinationViewType: 1)
        }
    }
    
}

class TidiRadioButtonController: NSObject {
    
    var buttonArray : [NSButton] = []
    var currentleySelectedButton : NSButton?
    var defaultButton : NSButton = NSButton() {
        didSet {
            buttonArrayUpdated(buttonSelected: self.defaultButton)
        }
    }
    
    func buttonArrayUpdated(buttonSelected : NSButton) {
        for button in buttonArray {
            if button == buttonSelected {
                currentleySelectedButton = button
                button.state = .on
            } else {
                button.state = .off
            }
        }
    }
    
}
