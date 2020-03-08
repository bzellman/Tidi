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

protocol FilePathUpdateDelegate : AnyObject {
    func updateFilePathLabel(newLabelString : String)
}

protocol headerUpdateDelegate : AnyObject {
//    func updateFilePathLabel(newLabelString : String)
}

class DestinationCollectionViewController : NSViewController, AddCategoryPopoverViewControllerDelegate  {
    
    var currentIndexPathsOfDragSession : [IndexPath]?
    let directoryItemIdentifier : NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "directoryItemIdentifier")
    var alertFired : Bool = false
    var isSourceDataEmpty : Bool?
    var detailBarViewController : DestinationCollectionDetailBarViewController?
    var addCategegoryPopoverViewController : AddCategoryPopoverViewController?
    var detailBarDelegate : FilePathUpdateDelegate?
    var categoryItemsArray : [[URL]]?
    var categoryArray : [String]?
    var defaultFirstCategory : String = "General"
   
    var indexPathOfDragOrigin : IndexPath?
    var indexPathOfDragDestination : IndexPath?
    var tempDragIndexPath : IndexPath?
    
    @IBOutlet weak var titleButton: NSButton!
    @IBOutlet weak var destinationCollectionView: NSCollectionView!
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
           if segue.identifier == "detailBarSegue" {
               detailBarViewController = segue.destinationController as? DestinationCollectionDetailBarViewController
                detailBarDelegate = detailBarViewController
           }
        
            if segue.identifier == "addCategegoryPopoverSegue" {
                addCategegoryPopoverViewController = segue.destinationController as? AddCategoryPopoverViewController
                addCategegoryPopoverViewController?.delegate = self
            }
   }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        StorageManager().clearAllDestinationCollection()
//        StorageManager().clearAllDestinationCollectionCategories()
        
        setSourceData()
        configureCollectionView()
        destinationCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        
        destinationCollectionView.identifier = NSUserInterfaceItemIdentifier(rawValue: "destinationCollectionID")
        NotificationCenter.default.addObserver(self, selector: #selector(self.dragToCollectionViewEnded), name: NSNotification.Name("tableDragsessionEnded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeCategoryButtonPushed), name: NSNotification.Name("categoryRemoveButtonPushed"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCategoryName), name: NSNotification.Name("categoryHeaderUpdated"), object: nil)
        
    }
    
    @objc func removeCategoryButtonPushed(notification : Notification) {
        if let categoryToRemove = notification.userInfo!["categoryItemToRemove"] as? Int {
            print("Should Remove \(categoryArray![categoryToRemove])")
        }
        
    }
    
    @objc func updateCategoryName(notification : Notification) {
        categoryArray![notification.userInfo!["categoryItemToUpdate"] as! Int] = notification.userInfo!["newCategoryName"] as! String
        print(categoryArray)
       
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        destinationCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    func setSourceData() {
        let storageMangager = StorageManager()
        ///Get Categories
        categoryArray = storageMangager.getDestinationCollectionCategory()
        categoryItemsArray = []
        if categoryArray!.count < 1 {
            if storageMangager.addCategoryToDestinationCollection(categoryName: defaultFirstCategory) {
                categoryArray?.append(defaultFirstCategory)
                categoryItemsArray = [[]]
            }
        } else {
            for category in categoryArray! {
                categoryItemsArray?.append([])
            }
        }
        ///Get Items For Categories
        let destinationFolderArrayFromStorage : [(categoryName : String, urlString : String)] = storageMangager.getDestinationCollection()
        
        if  destinationFolderArrayFromStorage.count > 0 {
            
            for (index, item) in destinationFolderArrayFromStorage.enumerated() {
                let urlString : String = item.urlString
                let url = URL.init(string: urlString)
                var isDirectory : ObjCBool = true
                
                let fileExists : Bool = FileManager.default.fileExists(atPath: url!.relativePath, isDirectory: &isDirectory)
                if fileExists && isDirectory.boolValue {
                    ///Check each Category
                    /// if match category - add to array at matching category's index ; default to general if no match,
                    for (index, category) in categoryArray!.enumerated() {
                        if item.categoryName == category {
                            
                            categoryItemsArray![index].append(url!)
                        }
                    }
                    
                } else {
                    storageMangager.removeDestinationCollectionItem(row: 0)
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
        destinationCollectionView.registerForDraggedTypes([.fileURL, .string])
        
    }
    
    func createNewCategory(newDirectoryNameString: String) {
        if StorageManager().addCategoryToDestinationCollection(categoryName: newDirectoryNameString) {
            categoryArray?.append(newDirectoryNameString)
            categoryItemsArray?.append([])
            destinationCollectionView.insertSections([categoryArray!.count-1])
        }
    }
    
    
     @objc func dragToCollectionViewEnded() {
        
        if alertFired {
            alertFired = false
        }
        
//        destinationCollectionView.item(at: IndexPath(item: destinationDirectoryArray.count, section: 0))?.highlightState = .none
//        destinationCollectionView.item(at: IndexPath(item: destinationDirectoryArray.count, section: 0))?.isSelected = false
//        destinationCollectionView.item(at: IndexPath(item: destinationDirectoryArray.count, section: 0))?.view.layer?.backgroundColor  = NSColor.clear.cgColor
        
        detailBarDelegate?.updateFilePathLabel(newLabelString: "")
        
    }
    
    
    
}

extension DestinationCollectionViewController : NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        
        
        
        if proposedDropIndexPath.pointee.item < self.categoryItemsArray![proposedDropIndexPath.pointee.section].count {
            
            if let sourceOfDrop = draggingInfo.draggingSource as? NSCollectionView {
                if sourceOfDrop.identifier == self.destinationCollectionView.identifier && proposedDropIndexPath.pointee as IndexPath != self.indexPathOfDragOrigin! {
                   if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                        if self.indexPathOfDragDestination != proposedDropIndexPath.pointee as IndexPath  || self.indexPathOfDragDestination == nil {
                            
                            self.indexPathOfDragDestination = proposedDropIndexPath.pointee as IndexPath

                            if self.indexPathOfDragOrigin?.section != proposedDropIndexPath.pointee.section {
                                let urlOfItemToInsert : URL = self.categoryItemsArray![self.indexPathOfDragOrigin!.section][indexPathOfDragOrigin!.item]
                                self.categoryItemsArray![self.indexPathOfDragOrigin!.section].remove(at: self.indexPathOfDragOrigin!.item)
                                self.categoryItemsArray![proposedDropIndexPath.pointee.section].insert(urlOfItemToInsert, at: proposedDropIndexPath.pointee.item)
                            }

                            collectionView.moveItem(at: self.indexPathOfDragOrigin!, to: self.indexPathOfDragDestination!)
                            self.indexPathOfDragOrigin! = self.indexPathOfDragDestination!
                        }
    
                        proposedDropOperation.pointee = NSCollectionView.DropOperation.before
                   }

                   return .move
                }
            } else {
                detailBarDelegate?.updateFilePathLabel(newLabelString: categoryItemsArray![proposedDropIndexPath.pointee.section][proposedDropIndexPath.pointee.item].absoluteString)
                return .move
            }
            
            
            
        } else if proposedDropIndexPath.pointee.item == self.categoryItemsArray![proposedDropIndexPath.pointee.section].count {
            
            let itemsToMove : [URL] = draggingInfo.draggingPasteboard.pasteboardItems!.compactMap{ $0.fileURL(forType: .fileURL) }
            
            for item in itemsToMove {

                if DirectoryManager().isFolder(filePath: item.relativePath) == false {

                    if alertFired == false {
                            AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "You can only add Folders to the __", buttonText: "Okay", presentingView: self.view.window!)
                            alertFired = true
                        }
                    return []
                    }
                }

            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                return .copy
            }
        }
        return[]
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        

        let pasteboard = draggingInfo.draggingPasteboard
        let pasteboardItems = pasteboard.pasteboardItems
        var itemsToMove : [URL] = []
        
        itemsToMove = pasteboardItems!.compactMap{ $0.fileURL(forType: .fileURL) }
        
        
        
        if self.indexPathOfDragOrigin != nil && self.indexPathOfDragDestination != nil {
            if self.indexPathOfDragOrigin!.section != self.indexPathOfDragDestination!.section{
                let urlOfItemToInsert : URL = self.categoryItemsArray![self.indexPathOfDragOrigin!.section][indexPathOfDragOrigin!.item]
                self.categoryItemsArray![self.indexPathOfDragOrigin!.section].remove(at: self.indexPathOfDragOrigin!.item)
                self.categoryItemsArray![self.indexPathOfDragDestination!.section].insert(urlOfItemToInsert, at: self.indexPathOfDragDestination!.item)
                print(self.categoryItemsArray!)
                
//                let group = DispatchGroup()
//                group.enter()
//
//                collectionView.performBatchUpdates({
//                    collectionView.deleteItems(at: [self.indexPathOfDragOrigin!])
//                    collectionView.insertItems(at: [self.indexPathOfDragDestination!])
//                }, completionHandler: { (result: Bool) in
//                    group.leave()
//                })
//                group.wait()
            }
            else {
//                collectionView.moveItem(at: self.indexPathOfDragOrigin!, to: self.indexPathOfDragDestination!)
            }
            
            
            var newArrayToSave : [(categoryName : String, urlString : String)] = []
            let arrayOfCollectionViewItems = self.destinationCollectionView.indexPathsForVisibleItems().sorted()
            print("array of visible items count \(arrayOfCollectionViewItems.count)")
            
            for indexPath in arrayOfCollectionViewItems {
                if indexPath.item < categoryItemsArray![indexPath.section].count {
                    let itemInfo : (categoryName: String, urlString: String) = self.destinationCollectionView.item(at: indexPath)?.representedObject as! (categoryName: String, urlString: String)
                    newArrayToSave.append(itemInfo)
                }
            }
            
            for item in newArrayToSave {
                print(item)
            }
            
            StorageManager().clearAllDestinationCollection()
            StorageManager().setDestinationCollection(newDestinationCollection: newArrayToSave)
            
            self.indexPathOfDragOrigin = nil
            self.indexPathOfDragDestination = nil
            
            return true
        }

        var moveToURL : URL?
        var wasErrorMoving = false
        
        if indexPath.item  < self.categoryItemsArray![indexPath.section].count {
            moveToURL = self.categoryItemsArray![indexPath.section][indexPath.item]
            for item in itemsToMove {
                
                StorageManager().moveItem(atURL: item, toURL: moveToURL!) { (Bool, Error) in
                    if (Error != nil) {
                        let errorString : String  = "Well this is embarrassing. \n\nLooks like there was an error trying to move your files"
                        AlertManager().showSheetAlertWithOnlyDismissButton(messageText: errorString, buttonText: "Okay", presentingView: self.view.window!)
                        wasErrorMoving = true
                    }
                }
            }
            
        } else if indexPath.item == self.categoryItemsArray![indexPath.section].count {

            for item in itemsToMove {
                if StorageManager().addDirectoryToDestinationCollection(newDestinationCollectionItem: (categoryArray![indexPath.section], item.absoluteString)) {
                    categoryItemsArray![indexPath.section].append(item)
                    
                    if self.isSourceDataEmpty! {
                       self.isSourceDataEmpty = false
                    }
                    
                    let indexToInsert : Set<IndexPath> = [IndexPath(item: self.categoryItemsArray![indexPath.section].count-1, section: indexPath.section)]
                    self.destinationCollectionView.insertItems(at: indexToInsert)
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
        
        for indexPath in indexPaths {
            if  collectionView.item(at: indexPath)?.highlightState == .asDropTarget && self.indexPathOfDragOrigin == nil {
                collectionView.item(at: indexPath)?.view.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
            } else {
                collectionView.item(at: indexPath)?.view.layer?.backgroundColor = NSColor.clear.cgColor
            }
        }
        
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        if indexPath.item < categoryItemsArray![indexPath.section].count {
            self.indexPathOfDragOrigin = indexPath
            return categoryItemsArray![indexPath.section][indexPath.item] as NSPasteboardWriting
        } else {
            return nil
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }

}



extension DestinationCollectionViewController : NSCollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 90, height: 90.0)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        
        if isSourceDataEmpty! && categoryArray?.count == 1 {
            let verticalInsetSize : CGFloat = (destinationCollectionView.frame.size.height-90-self.titleButton.frame.size.height)/2
            let horizontalInsetSize : CGFloat = (destinationCollectionView.frame.size.width-90)/2
            return NSEdgeInsets(top: verticalInsetSize-35, left: horizontalInsetSize, bottom: verticalInsetSize, right: horizontalInsetSize)
        } else {
            return NSEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: self.view.frame.width, height: 35)
    }
    
    
}
extension DestinationCollectionViewController : NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.categoryItemsArray![section].count + 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        guard let item = collectionView.makeItem(withIdentifier: directoryItemIdentifier, for: indexPath) as? DestinationCollectionItem else { return NSCollectionViewItem() }
        if indexPath.item < categoryItemsArray![indexPath.section].count {
            item.textField?.stringValue = self.categoryItemsArray![indexPath.section][indexPath.item].lastPathComponent
            item.backgroundLayer.isHidden = true
            item.representedObject = (categoryName: self.categoryArray![indexPath.section], urlString: categoryItemsArray![indexPath.section][indexPath.item].absoluteString)
            item.imageView?.image = NSImage.init(imageLiteralResourceName: "NSFolder")
        } else {
            item.backgroundLayer.isHidden = false
            item.imageView?.image = NSImage.init(imageLiteralResourceName: "NSAddTemplate")
            item.textField?.stringValue = "New Folder"
        }
        
        return item
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return categoryItemsArray!.count
        
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
        
        let view : NSView =  NSView()
        
        if kind == NSCollectionView.elementKindSectionHeader {
            let headerView = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DestinationCollectionHeader"), for: indexPath) as! DestinationCollectionHeaderView
            headerView.sectionHeaderLabel.stringValue = self.categoryArray![indexPath.section]
            headerView.identifier = NSUserInterfaceItemIdentifier(rawValue: String(indexPath.section))
            headerView.headerID = indexPath.section
            return headerView
        }
        
        return view
     }
    
}
