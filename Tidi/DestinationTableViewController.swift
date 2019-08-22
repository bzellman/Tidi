//
//  SourceTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/11/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class DestinationTableViewController: NSViewController {
    
    //Mark: - Properties
    
    let storageManager = StorageManager()
    var sourceDestinationFileURLArray : [URL] = []
    var sourceDestinationFilewithAttributesArray : [TidiFile] = []
    var showInvisibles = false
    
    
    //Mark: - Outlets
    
    
    @IBOutlet weak var destinationTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            destinationTableView.delegate = self
            destinationTableView.dataSource = self
            destinationTableView.registerForDraggedTypes([.fileURL, .tableViewIndex])
            destinationTableView.setDraggingSourceOperationMask(.move, forLocal: false)
        
            var selectedDestinationTableFolder: URL? {
                didSet {
                    if let selectedDestinationTableFolder = selectedDestinationTableFolder {
                        sourceDestinationFileURLArray = contentsOf(folder: selectedDestinationTableFolder)
                        let unsortedFileWithAttributeArray = fileAttributeArray(fileURLArray: sourceDestinationFileURLArray)
                        sourceDestinationFilewithAttributesArray = sortFiles(sortByKeyString: "date-created-DESC", tidiArray: unsortedFileWithAttributeArray)
                        destinationTableView.reloadData()
                        destinationTableView.scrollRowToVisible(0)
                    } else {
                        //Handle more gracefully
                        print("No File Set")
                    }
                }
            }
        
            if storageManager.checkForDestinationFolder() == nil {
                storageManager.saveDefaultDestinationFolder()
            }
        
            selectedDestinationTableFolder = storageManager.checkForDestinationFolder()!
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
    }
    
}

// MARK: - Getting file or folder information - needs it's own class - to likely be reused

extension DestinationTableViewController {
    // this will be common code and likley should have it's own custom class when refactoring and cleaning up
    
    func contentsOf(folder: URL) -> [URL] {
        let fileManager = FileManager.default
        
        do {
            let folderContents = try fileManager.contentsOfDirectory(atPath: folder.path)
            let folderFileURLS = folderContents.map {return folder.appendingPathComponent($0)}
            
            return folderFileURLS
        } catch {
            return []
        }
    }
    
    // Need when setting metadata
//    func infoAbout(url:URL) -> String {
//        let fileManger = FileManager.default
//        do {
//            let attributes = try fileManger.attributesOfItem(atPath: url.path)
//            var report: [String] = ["\(url.path)", ""]
//
//            for (key, value) in attributes {
//                if key.rawValue == "NSFileExtendedAttributes" { continue }
//                report.append("\(key.rawValue):\t \(value)")
//            }
//
//            return report.joined(separator: "\n")
//        } catch {
//            return "No Info availbile for \(url.path)"
//        }
//    }
    
    func sortFiles(sortByKeyString : String, tidiArray : [TidiFile]) -> [TidiFile] {

        switch sortByKeyString {
            case "date-created-DESC":
                print("SORTED")
                let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $0.createdDateAttribute as! Date > $1.createdDateAttribute as! Date})
              return sortedtidiArrayWithFileAttributes
//            case "date-modified-DESC":
//                let fileAttributeKeyString : String = "creationDate"
//                let isSortOrderDesc = true
//                let objectTypeString : String = Date.className()
//                let sortedFileURLArray = sortFileArrayByType(fileAttributeKeyString: fileAttributeKeyString, fileURLArray: fileURLArray, type: objectTypeString, isSortOrderDesc : isSortOrderDesc)
//                return fileURLArray
//            case "size-DESC":
//                let fileAttributeKeyString : String = "size"
//                let isSortOrderDesc = true
//                let objectTypeString : String = Date.className()
//                let sortedFileURLArray = sortFileArrayByType(fileAttributeKeyString: fileAttributeKeyString, fileURLArray: fileURLArray, type: objectTypeString, isSortOrderDesc : isSortOrderDesc)
//                return fileURLArray
            case "file-name-DESC":
                //different patern for Name
                return tidiArray
            default:
                return tidiArray
        }
    }
    //Generic function to get a files attributes from a URL by requested type
    func fileAttributeArray(fileURLArray : [URL]) -> [TidiFile] {
//        print(fileURLArray)
        let fileManager = FileManager.default
        let createdDateAttribute : FileAttributeKey = FileAttributeKey.creationDate
        let modifiedDateAttributeRawString : String = "NSFileModificationDate"
        let fileSizeAttribute : FileAttributeKey = FileAttributeKey.size
//        let fileNameAttribute : String = "NSFileCreatedDate"
        
        var tidiFileArray : [TidiFile] = []
        
        for url in fileURLArray {
            do {
                var tidiFileToAdd : TidiFile = TidiFile.init()
                tidiFileToAdd.url = url
                let attributes = try fileManager.attributesOfItem(atPath: url.path)
                for (key, value) in attributes {
                    if key.rawValue == modifiedDateAttributeRawString {
                        tidiFileToAdd.modifiedDateAttribute = value as? Date
                    }
                    
                    if key == createdDateAttribute {
                        tidiFileToAdd.createdDateAttribute = value as? Date
                    }
                    
                    if  key == fileSizeAttribute {
                        tidiFileToAdd.fileSizeAttribute = value as? Int
                    }
                }
//                print((tupleToAdd) as Any)
                tidiFileArray.append(tidiFileToAdd)
            } catch {
                return []
            }
            
        }
        
        return tidiFileArray
//        print("SORTED")
//        let sorted = tupleArrayWithURLandAttribute.sorted(by: { $0.createdDateAttribute > $1.createdDateAttribute})
//        var sortedURLs : [URL] = []
//
//        for url in 0 ..< sorted.count {
//            sortedURLs.append(sorted[url].0)
//            print(sorted[url].createdDateAttribute as Any)
//
//        }
//        print(sortedURLs as Any)
        
    }
    
    
}


extension DestinationTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.sourceDestinationFileURLArray.count
    }
    
    
    
}

extension DestinationTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        print(sourceDestinationFileURLArray.count + 1)
        let item = sourceDestinationFilewithAttributesArray[row].url
        let fileIcon = NSWorkspace.shared.icon(forFile: item!.path)
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "destinationCellView"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = item!.lastPathComponent
            cell.imageView?.image = fileIcon
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation)
        -> NSDragOperation {
            if dropOperation == .above {
                return .move
            }
            return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        let pasteboard = info.draggingPasteboard
        let pasteboardItems = pasteboard.pasteboardItems
        
        if let pasteboardItems = pasteboardItems, !pasteboardItems.isEmpty {
         
            for url in pasteboardItems {
                guard let urlStringFromPasteboard  = url.string(forType: NSPasteboard.PasteboardType(rawValue: "public.file-url")) else { return false }
                
                let urlFromString : URL = URL(string: urlStringFromPasteboard)!
                print(urlFromString)
                
                if storageManager.checkForDestinationFolder() == nil {
                    storageManager.saveDefaultDestinationFolder()
                }
                
                guard let destinationFolderURL = storageManager.checkForDestinationFolder()! else { return false }
                
                self.storageManager.moveItem(atURL: urlFromString, toURL: destinationFolderURL, row: row) { (Bool, Error) in
                        if (Error != nil) {
                            print(Error as Any)
//                            return false
                        } else {
                            self.storageManager.saveDefaultDestinationFolder()
                            self.sourceDestinationFileURLArray = self.contentsOf(folder: destinationFolderURL)

                            tableView.beginUpdates()
                            let oldIndexes = info.draggingPasteboard.pasteboardItems?.compactMap{ $0.integer(forType: .tableViewIndex) }
                            var oldIndexOffset = 0
                            var newIndexOffset = 0
                            
                            for oldIndex in oldIndexes! {
                                if oldIndex < row {
                                    tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                                    oldIndexOffset -= 1
                                } else {
                                    tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                                    newIndexOffset += 1
                                }
                            }

//                            tableView.insertRows(at: IndexSet(row...row + self.sourceDestinationFileURLArray.count - 1),
//                                                 withAnimation: .slideDown)
//                            tableView.endUpdates()
//                            return true
                        }
        
                    }
                    
                }
                
        }
        
        return true
    }
        
        
        
    
    
    
    func tableView(
        _ tableView: NSTableView,
        draggingSession session: NSDraggingSession,
        endedAt screenPoint: NSPoint,
        operation: NSDragOperation) {
        //        // Handle items dragged to Trash
        ////        if operation == .delete, let items = session.draggingPasteboard.pasteboardItems {
        ////            let indexes = items.compactMap{ $0.integer(forType: .tableViewIndex) }
        //
        //            for index in indexes.reversed() {
        //                FruitManager.rightFruits.remove(at: index)
        //            }
        //            tableView.removeRows(at: IndexSet(indexes), withAnimation: .slideUp)
        //        }
    }
    
}

extension NSUserInterfaceItemIdentifier {
    static let destinationCellView = NSUserInterfaceItemIdentifier("destinationCellView")
}
