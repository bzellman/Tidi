//
//  DestinationCollectionViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 1/18/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Foundation
import QuickLook
import Quartz
import Cocoa

class DestinationCollectionViewController : NSViewController  {
    
    var destinationDirectoryArray : [URL] = []
    let directoryItemIdentifier : NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "directoryItemIdentifier")
    
    @IBOutlet weak var destinationCollectionView: NSCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setSourceData()
        configureCollectionView()
    }
    
    func setSourceData() {
        let storageMangager = StorageManager()
        let destinationFolderArrayFromStorage : [String] = storageMangager.getQuickDropArray()
        destinationDirectoryArray = []
        
        for (index, item) in destinationFolderArrayFromStorage.enumerated() {
            let URLString = item
            let url = URL.init(string: URLString)
            var isDirectory : ObjCBool = true
            let fileExists : Bool = FileManager.default.fileExists(atPath: url!.relativePath, isDirectory: &isDirectory)
            if fileExists && isDirectory.boolValue {
               destinationDirectoryArray.append(url!)
            } else {
                storageMangager.removeQuickDropItem(row: index)
               let missingFolderName : String = url!.lastPathComponent
               let alertStringWithURL : String = "Something went wrong! \n\nWe can't find the Folder \"\(missingFolderName)\". It may have been moved or deleted. \n\nPlease re-add \(missingFolderName) at it's updated location."
               AlertManager().showSheetAlertWithOnlyDismissButton(messageText: alertStringWithURL, buttonText: "Okay", presentingView: self.view.window!)
           }
        }
        print(destinationDirectoryArray)
    }
    
    func configureCollectionView() {
        destinationCollectionView.delegate = self
        destinationCollectionView.dataSource = self
        destinationCollectionView.register(NSNib(nibNamed: "DestinationCollectionItem", bundle: nil), forItemWithIdentifier: directoryItemIdentifier)
    }
    
}


extension DestinationCollectionViewController : NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.destinationDirectoryArray.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(withIdentifier: directoryItemIdentifier, for: indexPath) as? DestinationCollectionItem else { return NSCollectionViewItem() }
        item.textField?.stringValue = self.destinationDirectoryArray[indexPath.item].lastPathComponent
        return item
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
}

extension DestinationCollectionViewController : NSCollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 90.0, height: 90.0)
    }
    
}
