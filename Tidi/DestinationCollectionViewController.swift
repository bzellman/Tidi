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

class DestinationCollectionViewController : NSViewController  {
    
    var destinationDirectoryArray : [URL] = []
    var currentIndexPathsOfDragSession : [IndexPath]?
    let directoryItemIdentifier : NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "directoryItemIdentifier")
    var alertFired : Bool = false
    var isSourceDataEmpty : Bool?
    var detailBarViewController : DestinationCollectionDetailBarViewController?
    var detailBarDelegate : FilePathUpdateDelegate?
    var categoryDetailsArray : [(category : String, numberOfItems : Int)]?
    var defaultFirstCategory : String = "General"
    
    @IBOutlet weak var titleButton: NSButton!
    @IBOutlet weak var destinationCollectionView: NSCollectionView!
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
           if segue.identifier == "detailBarSegue" {
               detailBarViewController = segue.destinationController as? DestinationCollectionDetailBarViewController
                detailBarDelegate = detailBarViewController
           }
       }
    
    
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
        ///Get Categories
        var categoryArray : [String] = storageMangager.getDestinationCollectionCategory()
        if categoryArray.count < 1 {
            if storageMangager.addCategoryToDestinationCollection(categoryName: defaultFirstCategory) {
                categoryArray.append(defaultFirstCategory)
            }
        }
        
        ///Get Items For Categories
        let destinationFolderArrayFromStorage : [(category : String, urlString : String)] = storageMangager.getDestinationCollection()
        destinationDirectoryArray = []
        
        if  destinationFolderArrayFromStorage.count > 0 {
            var currentCategoryCount : Int = 1
            
            var previousCategory : String?
            
            for (index, item) in destinationFolderArrayFromStorage.enumerated() {
                let currentCategory : String = item.category
                let urlString : String = item.urlString
                let url = URL.init(string: urlString)
                var isDirectory : ObjCBool = true
                
                let fileExists : Bool = FileManager.default.fileExists(atPath: url!.relativePath, isDirectory: &isDirectory)
                if fileExists && isDirectory.boolValue {
                    if currentCategory == previousCategory {
                        currentCategoryCount = currentCategoryCount + 1
                    } else {
                        categoryDetailsArray?.append((previousCategory!, currentCategoryCount))
                        currentCategoryCount = 1
                    }
                    previousCategory = item.category
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

        
        
    }
    
     @objc func dragToCollectionViewEnded() {
        
        if alertFired {
            alertFired = false
        }
        
        destinationCollectionView.item(at: IndexPath(item: destinationDirectoryArray.count, section: 0))?.highlightState = .none
        destinationCollectionView.item(at: IndexPath(item: destinationDirectoryArray.count, section: 0))?.isSelected = false
        destinationCollectionView.item(at: IndexPath(item: destinationDirectoryArray.count, section: 0))?.view.layer?.backgroundColor  = NSColor.clear.cgColor
        
        detailBarDelegate?.updateFilePathLabel(newLabelString: "")
        
    }
    
    
    
}

extension DestinationCollectionViewController : NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        
        
        
        if proposedDropIndexPath.pointee.item < self.destinationDirectoryArray.count {
            
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                detailBarDelegate?.updateFilePathLabel(newLabelString: destinationDirectoryArray[proposedDropIndexPath.pointee.item].absoluteString)
                return .move
            }
            
        } else if proposedDropIndexPath.pointee.item == self.destinationDirectoryArray.count {
           
            let itemsToMove : [URL] = draggingInfo.draggingPasteboard.pasteboardItems!.compactMap{ $0.fileURL(forType: .fileURL) }
            
            for item in itemsToMove {

                if DirectoryManager().isFolder(filePath: item.relativePath) == false {

                    if alertFired == false {
                            AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "You can only add Folders to the __ Tab", buttonText: "Okay", presentingView: self.view.window!)
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

            for item in itemsToMove {
                if StorageManager().addDirectoryToDestinationCollection(newDestinationCollectionItem: ("TEST", item.absoluteString)) {
                    
                    destinationDirectoryArray.append(item)
                    
                    if self.isSourceDataEmpty! {
                       self.isSourceDataEmpty = false
                    }
                    
                    
                    let indexToInsert : Set<IndexPath> = [IndexPath(item: self.destinationDirectoryArray.count-1, section: 0)]
                    
                    self.destinationCollectionView.insertItems(at: indexToInsert)
                    collectionView.item(at: indexPath)?.highlightState = .none
                    collectionView.item(at: indexPath)?.isSelected = false
                    
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
            if  collectionView.item(at: indexPath)?.highlightState == .asDropTarget {
                collectionView.item(at: indexPath)?.view.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
            } else {
                collectionView.item(at: indexPath)?.view.layer?.backgroundColor = NSColor.clear.cgColor
            }
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
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: self.view.frame.width, height: 35)
    }
    
    
}
extension DestinationCollectionViewController : NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.destinationDirectoryArray.count + 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(withIdentifier: directoryItemIdentifier, for: indexPath) as? DestinationCollectionItem else { return NSCollectionViewItem() }
        if indexPath.item < destinationDirectoryArray.count {
//            item.textField?.stringValue = setTextFieldString(labelString: self.destinationDirectoryArray[indexPath.item].lastPathComponent, textField: (item.textField)!)
            
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
        if categoryDetailsArray?.count ?? 0 > 0 {
            return categoryDetailsArray!.count
        } else {
            return 1
        }
        
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
      
        let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DestinationCollectionHeader"), for: indexPath) as! DestinationCollectionHeaderView
      // 2
        view.sectionHeaderLabel.stringValue = "All Items"
      
      return view
    }
    
    
//    func setTextFieldString(labelString : String, textField: NSTextField) -> String {
//        var returnString : String = labelString
//        let stringArray = Array(labelString)
//        var firstLine : String?
//        var secondLine : String?
//        let dict :  [NSAttributedString.Key : NSFont] = [NSAttributedString.Key.font:textField.font!]
//        let totalStringWidth : CGFloat = labelString.size(withAttributes: dict).width
//        let textFieldWidth : CGFloat = textField.alignmentRect(forFrame: textField.frame).width
//
//        print(totalStringWidth)
//        print(textFieldWidth * 2)
//
//        if totalStringWidth >= (textFieldWidth * 2) {
//
//            firstLine = ""
//            secondLine = "..."
//            var count : Int = 0
//            while firstLine!.size(withAttributes: dict).width < textFieldWidth {
//                print(stringArray[count])
//                firstLine?.append(stringArray[count])
//                count = count + 1
//                print(firstLine!.size(withAttributes: dict).width)
//                print(textFieldWidth)
//            }
//
//            count = 0
//
//            while secondLine!.size(withAttributes: dict).width < textFieldWidth {
//                let indexToInsert : String.Index = (secondLine?.index(secondLine!.endIndex, offsetBy: -count))!
//                print(indexToInsert.hashValue)
//                print(stringArray[stringArray.count-count-1])
//                secondLine?.insert(stringArray[stringArray.count-count-1], at: indexToInsert)
//
//                count = count + 1
//            }
//
//            returnString = firstLine! + secondLine!
//            print(firstLine)
//            print(secondLine)
//            print(returnString)
//            return returnString
//        } else {
//            return returnString
//        }
//    }

    
}
