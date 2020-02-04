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
    var alertFired : Bool = false
    
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
        destinationCollectionView.registerForDraggedTypes([.fileURL])
        destinationCollectionView.setDraggingSourceOperationMask(NSDragOperation.move, forLocal: true)
    }
}

extension DestinationCollectionViewController : NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        
        let indexPath = proposedDropIndexPath.pointee as IndexPath
        
        if proposedDropIndexPath.pointee.item < self.destinationDirectoryArray.count {
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                return .move
            }
        } else if proposedDropIndexPath.pointee.item == self.destinationDirectoryArray.count {
            let itemsToMove : [URL] = draggingInfo.draggingPasteboard.pasteboardItems!.compactMap{ $0.fileURL(forType: .fileURL) }
                for item in itemsToMove {
                    print(item.absoluteString)
                    
                    if DirectoryManager().isFolder(filePath: item.relativePath) == false {
                        if alertFired == false {
                            AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "You can only add Folders to the __ Tab", buttonText: "Okay", presentingView: self.view.window!)
                            alertFired = true
                        }
                        
                        return []
                    }
                }
                
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                return .move
            }
        } else {
            destinationCollectionView.item(at: indexPath)?.highlightState = .none
        }
        return[]
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        
        let pasteboard = draggingInfo.draggingPasteboard
        let pasteboardItems = pasteboard.pasteboardItems
        var itemsToMove : [URL] = []
        
        itemsToMove = pasteboardItems!.compactMap{ $0.fileURL(forType: .fileURL) }
        
        var moveToURL : URL?
        var wasErrorMoving = false
        
        print(indexPath.item)
        print(self.destinationDirectoryArray.count)
        
        if indexPath.item  < self.destinationDirectoryArray.count {
        moveToURL = self.destinationDirectoryArray[indexPath.item]
            for item in itemsToMove {
                StorageManager().moveItem(atURL: item, toURL: moveToURL!) { (Bool, Error) in
                    if (Error != nil) {
                        let errorString : String  = "Well this is embarrassing. \n\nLooks like there was an error trying to move your files"
                        AlertManager().showSheetAlertWithOnlyDismissButton(messageText: errorString, buttonText: "Okay", presentingView: self.view.window!)
                        wasErrorMoving = true
                    }
                }
            }
            
        } else if indexPath.item == self.destinationDirectoryArray.count {
            for item in itemsToMove {
                if StorageManager().addDirectoryToDestinationCollection(directoryToAdd: item.absoluteString) {
                self.destinationCollectionView.reloadData()
                }
            }
        }
        
        
        
        if wasErrorMoving == true {
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) {
        if indexPaths.first?.item != self.destinationCollectionView.visibleItems().count && highlightState == .asDropTarget {
            collectionView.item(at: indexPaths.first!.item)?.view.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
        } else {
            collectionView.item(at: indexPaths.first!.item)?.view.layer?.backgroundColor = NSColor.clear.cgColor
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        alertFired = false
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
        } else {
            item.backgroundLayer.isHidden = false
            item.imageView?.image = NSImage.init(imageLiteralResourceName: "NSAddTemplate")
            item.textField?.stringValue = "New Folder"
        }
        
        return item
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
}
