//
//  DestinationCollectionDetailBarViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 2/15/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Cocoa

class DestinationCollectionDetailBarViewController: NSViewController, FilePathUpdateDelegate {
    

    @IBOutlet weak var filePathLabel: NSTextField!

    func updateFilePathLabel(newLabelString: String) {
        filePathLabel.stringValue = createDisplayStringForFilePathLabel(string: newLabelString)
    }
    
    func createDisplayStringForFilePathLabel(string : String) -> String {
        if let url : URL = URL(string: string) {
            let stringArray : ArraySlice<String> = (url.pathComponents.dropFirst(2))
                   var urlDisplayString : String = ""
                   
                   for (index, item) in stringArray.enumerated() {
                       urlDisplayString.append(contentsOf: item)
                       if index != stringArray.count-1 {
                           urlDisplayString.append(contentsOf: " ▶︎ ")
                       }
                   }
                   
                   return urlDisplayString
        } else {
            return ""
        }
       
    }
    
}
