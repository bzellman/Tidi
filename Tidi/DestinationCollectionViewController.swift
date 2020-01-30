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
    var currentIndexPathsOfDragSession : [IndexPath]?
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
    }
    
    func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 8.0
        flowLayout.minimumLineSpacing = 8.0
        
        destinationCollectionView.delegate = self
        destinationCollectionView.dataSource = self
        destinationCollectionView.register(NSNib(nibNamed: "DestinationCollectionItem", bundle: nil), forItemWithIdentifier: directoryItemIdentifier)
        destinationCollectionView.collectionViewLayout = flowLayout
        destinationCollectionView.registerForDraggedTypes([.fileURL, .tidiFile])
        destinationCollectionView.setDraggingSourceOperationMask(NSDragOperation.move, forLocal: true)
    }
}

extension DestinationCollectionViewController : NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        let indexPath = proposedDropIndexPath.pointee as IndexPath
        if (proposedDropIndexPath.pointee.item < self.destinationDirectoryArray.count) {
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                return .move
            }
        } else {
            destinationCollectionView.item(at: indexPath)?.highlightState = .none
        }
        return.generic
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        
            let pasteboard = draggingInfo.draggingPasteboard
            let pasteboardItems = pasteboard.pasteboardItems
            
            let tidiFilesToMove = pasteboardItems!.compactMap{ $0.tidiFile(forType: .tidiFile) }

            var moveToURL : URL
            var wasErorMoving = false
           
            moveToURL = self.destinationDirectoryArray[indexPath.item]
            
            for tidiFile in tidiFilesToMove {
               StorageManager().moveItem(atURL: tidiFile.url!, toURL: moveToURL) { (Bool, Error) in
                   if (Error != nil) {
                       let errorString : String  = "Well this is embarrassing. \n\nLooks like there was an error trying to move your files"
                       AlertManager().showSheetAlertWithOnlyDismissButton(messageText: errorString, buttonText: "Okay", presentingView: self.view.window!)
                       wasErorMoving = true
                   }
               }
            }

            if wasErorMoving == true {
               return false
            } else {
               return true
            }
    }
        
    func collectionView(_ collectionView: NSCollectionView, didChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) {
        if indexPaths.first?.item != self.destinationCollectionView.visibleItems().count-1 && highlightState == .asDropTarget {
            collectionView.item(at: indexPaths.first!.item)?.view.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
        } else {
            collectionView.item(at: indexPaths.first!.item)?.view.layer?.backgroundColor = NSColor.clear.cgColor
        }
    }
}



extension DestinationCollectionViewController : NSCollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 90.0, height: 90.0)
    }
    
}
extension DestinationCollectionViewController : NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.destinationDirectoryArray.count + 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(withIdentifier: directoryItemIdentifier, for: indexPath) as? DestinationCollectionItem else { return NSCollectionViewItem() }
        if indexPath.item < destinationDirectoryArray.count {
            item.textField?.stringValue = self.destinationDirectoryArray[indexPath.item].lastPathComponent
            item.backgroundLayer.isHidden = true
        } else {
            item.textField?.stringValue = "+"
        }
        
        return item
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
}
