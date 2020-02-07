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
    var count : Int = 0
    var isSourceDataEmpty : Bool?
    @IBOutlet weak var titleButton: NSButton!
    @IBOutlet weak var destinationCollectionView: NSCollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StorageManager().clearAllDestinationCollection()
        setSourceData()
        configureCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.dragToCollectionViewEnded), name: NSNotification.Name("tableDragsessionEnded"), object: nil)
        
    }
    
    
    override func viewWillLayout() {
        super.viewWillLayout()
        destinationCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    func setSourceData() {
        let storageMangager = StorageManager()
        let destinationFolderArrayFromStorage : [String] = storageMangager.getDestinationCollection()
        destinationDirectoryArray = []
        
        if  destinationFolderArrayFromStorage.count > 0 {
            
            for (index, item) in destinationFolderArrayFromStorage.enumerated() {
                let URLString = item
                let url = URL.init(string: URLString)
                var isDirectory : ObjCBool = true
                let fileExists : Bool = FileManager.default.fileExists(atPath: url!.relativePath, isDirectory: &isDirectory)
                if fileExists && isDirectory.boolValue {
                   destinationDirectoryArray.append(url!)
                } else {
                    storageMangager.removeDestinationCollectionItem(row: index)
                   let missingFolderName : String = url!.lastPathComponent
                   let alertStringWithURL : String = "Something went wrong! \n\nWe can't find the Folder \"\(missingFolderName)\". It may have been moved or deleted. \n\nPlease re-add \(missingFolderName) at it's updated location."
                   AlertManager().showSheetAlertWithOnlyDismissButton(messageText: alertStringWithURL, buttonText: "Okay", presentingView: self.view.window!)
               }
            }
            isSourceDataEmpty = false
        } else {
            isSourceDataEmpty = true
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
    
     @objc func dragToCollectionViewEnded() {
        if alertFired {
            alertFired = false
        }
    }
    
}

extension DestinationCollectionViewController : NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        print("1")
        if proposedDropIndexPath.pointee.item < self.destinationDirectoryArray.count {
            
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                return .move
            }
            
        } else if proposedDropIndexPath.pointee.item == self.destinationDirectoryArray.count {
           
            let itemsToMove : [URL] = draggingInfo.draggingPasteboard.pasteboardItems!.compactMap{ $0.fileURL(forType: .fileURL) }
            
            for item in itemsToMove {
                print("item.relativePath")
                if DirectoryManager().isFolder(filePath: item.relativePath) == false {
                    print("Is not folder")
                    if alertFired == false {
                            AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "You can only add Folders to the __ Tab", buttonText: "Okay", presentingView: self.view.window!)
                            alertFired = true
                        }
                    return []
                    }
                }

            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                print("Is folder")
                return .move
                
            }
        }
        return[]
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        
        print("3")
        let pasteboard = draggingInfo.draggingPasteboard
        let pasteboardItems = pasteboard.pasteboardItems
        var itemsToMove : [URL] = []
        
        itemsToMove = pasteboardItems!.compactMap{ $0.fileURL(forType: .fileURL) }
        print("items: \(itemsToMove)")
        var moveToURL : URL?
        var wasErrorMoving = false
        
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
            print("Doing This")
            for item in itemsToMove {
                if StorageManager().addDirectoryToDestinationCollection(directoryToAdd: item.absoluteString) {
                    setSourceData()
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
        print("2")
        if indexPaths.first!.item <= self.destinationDirectoryArray.count && highlightState == .asDropTarget {
            collectionView.item(at: indexPaths.first!.item)?.view.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
        } else {
            collectionView.item(at: indexPaths.first!.item)?.view.layer?.backgroundColor = NSColor.clear.cgColor
        }
    }
 
}



extension DestinationCollectionViewController : NSCollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {

        return NSSize(width: 90, height: 90.0)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        
        if isSourceDataEmpty! {
            let verticalInsetSize : CGFloat = (destinationCollectionView.frame.size.height-90-self.titleButton.frame.size.height)/2
            let horizontalInsetSize : CGFloat = (destinationCollectionView.frame.size.width-90)/2
            return NSEdgeInsets(top: verticalInsetSize, left: horizontalInsetSize, bottom: verticalInsetSize, right: horizontalInsetSize)
        } else {
            return NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
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
            item.imageView?.image = NSImage.init(imageLiteralResourceName: "NSFolder")
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
