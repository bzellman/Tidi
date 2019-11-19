//
//  InfoPanelViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/11/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class InfoPanelViewController : NSViewController, TidiTableViewFileUpdate {
    
    @IBOutlet weak var fileImageView: NSImageView!
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var fileSizeLabel: NSTextField!
    @IBOutlet weak var dateCreatedLabel: NSTextField!
    @IBOutlet weak var dateModifiedLabel: NSTextField!
    @IBOutlet weak var nameDescriptorLabel: NSTextField!
    @IBOutlet weak var sizeDescriptorLabel: NSTextField!
    @IBOutlet weak var createdDescriptorLabel: NSTextField!
    @IBOutlet weak var modifiedDescriptorLabel: NSTextField!
    @IBOutlet weak var tidiLogoImageView: NSImageView!
    
    var isFileSelected : Bool = false
    
    override func viewDidLoad() {
        super .viewDidLoad()
        let contentViewController = self.parent?.parent as! MainWindowContainerViewController
        contentViewController.destinationViewController?.fileDelegate = self
        contentViewController.sourceViewController?.fileDelegate = self
        
        if isFileSelected == false {
            fileImageView.isHidden = true
            fileNameLabel.isHidden = true
            fileSizeLabel.isHidden = true
            dateCreatedLabel.isHidden = true
            dateModifiedLabel.isHidden = true
            nameDescriptorLabel.isHidden = true
            sizeDescriptorLabel.isHidden = true
            createdDescriptorLabel.isHidden = true
            modifiedDescriptorLabel.isHidden = true
            tidiLogoImageView.isHidden = false

        }
        
    }
    
    
    
    func fileInFocus(_ tidiFile: TidiFile, inFocus: Bool) {
        isFileSelected = inFocus
        
        if isFileSelected == true {
            fileImageView.isHidden = false
            fileNameLabel.isHidden = false
            fileSizeLabel.isHidden = false
            dateCreatedLabel.isHidden = false
            dateModifiedLabel.isHidden = false
            nameDescriptorLabel.isHidden = false
            sizeDescriptorLabel.isHidden = false
            createdDescriptorLabel.isHidden = false
            modifiedDescriptorLabel.isHidden = false
            tidiLogoImageView.isHidden = true
        }
        
        fileImageView.image = NSWorkspace.shared.icon(forFile: tidiFile.url!.path)
        fileNameLabel.stringValue = tidiFile.url!.lastPathComponent
        let byteFormatter = ByteCountFormatter()
        byteFormatter.countStyle = .binary
        let sizeString = byteFormatter.string(fromByteCount: tidiFile.fileSizeAttribute!)
        fileSizeLabel.stringValue = sizeString
        dateCreatedLabel.stringValue = DateFormatter.localizedString(from: tidiFile.createdDateAttribute!, dateStyle: .long, timeStyle: .none)
        dateModifiedLabel.stringValue = DateFormatter.localizedString(from: tidiFile.modifiedDateAttribute!, dateStyle: .long, timeStyle: .short)
//        dateModifiedLabel.stringValue = tidiFile
        
        
    }
    
    
}
