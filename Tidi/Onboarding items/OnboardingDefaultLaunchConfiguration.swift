//
//  OnboardingDefaultLaunchConfiguration.swift
//  Tidi
//
//  Created by Bradley Zellman on 3/17/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa
import Foundation

protocol DefaultDestinationStateDelegate : AnyObject {
    func setDefaultDestinationState(stateValue : Int)
}

class OnboardingDefaultLaunchConfiguration: NSViewController {

    let radioButtonController : TidiRadioButtonController = TidiRadioButtonController()
    let storageManager : StorageManager = StorageManager()
    weak var defaultDestinationStateDelegate : DefaultDestinationStateDelegate?
    
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
        
        if storageManager.getDefaultDestinationView() == 0 {
            radioButtonController.buttonArrayUpdated(buttonSelected: fileListRadioButton)
        } else if storageManager.getDefaultDestinationView() == 1 {
            radioButtonController.buttonArrayUpdated(buttonSelected: folderGroupRadioButton)
        }
        
    }
    
    override func viewWillDisappear() {
        if radioButtonController.currentleySelectedButton == fileListRadioButton {
            storageManager.setDefaultDestinationView(defaultDestinationViewType: 0)
            if defaultDestinationStateDelegate != nil {
                defaultDestinationStateDelegate!.setDefaultDestinationState(stateValue: 0)
            }
                    
        } else if radioButtonController.currentleySelectedButton == folderGroupRadioButton {
            storageManager.setDefaultDestinationView(defaultDestinationViewType: 1)
            
            if defaultDestinationStateDelegate != nil {
                    defaultDestinationStateDelegate!.setDefaultDestinationState(stateValue: 1)
            }
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
