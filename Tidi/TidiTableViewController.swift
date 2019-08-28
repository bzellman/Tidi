//
//  TidiTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/21/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class TidiTableViewController: NSViewController {
    
    // MARK: Properties
    
    let storageManager = StorageManager()
    var sourceFileURLArray : [URL] = []
    var tableSourceTidiFileArray : [TidiFile] = []
    var showInvisibles = false
    // IBOutlets set from subclasses for each table
    var tidiTableView : NSTableView = NSTableView.init()
    var needsToSetDefaultLaunchFolder = false
    var currentSourceFolderURL : URL = URL.init(fileURLWithPath: " ")
    var currentDestinationFolderURL : URL = URL.init(fileURLWithPath: " ")
    
    //Make enum later
    var tableID : String = ""
    
    var selectedTableFolderURL: URL? {
        didSet {
            if let selectedTableFolderURL = selectedTableFolderURL {
                sourceFileURLArray = contentsOf(folder: selectedTableFolderURL)
                let unsortedFileWithAttributeArray = fileAttributeArray(fileURLArray: sourceFileURLArray)
                tableSourceTidiFileArray = sortFiles(sortByKeyString: "date-created-DESC", tidiArray: unsortedFileWithAttributeArray)
                tidiTableView.reloadData()
                tidiTableView.scrollRowToVisible(0)
            } else {
                //Handle more gracefully
                print("No File Set")
            }
        }
    }
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        tidiTableView.delegate = self
        tidiTableView.dataSource = self
        tidiTableView.registerForDraggedTypes([.fileURL, .tableViewIndex, .tidiFile])
        tidiTableView.setDraggingSourceOperationMask(.move, forLocal: false)
        
        tidiTableView.tableColumns[0].headerCell.stringValue = "File Name"
        tidiTableView.tableColumns[1].headerCell.stringValue = "Date Added"
       
        if tableID == "DestinationTableViewController" {
            if storageManager.checkForDestinationFolder() == nil {
                storageManager.saveDefaultDestinationFolder()
            }
        
            selectedTableFolderURL = storageManager.checkForDestinationFolder()!
            
        } else if tableID == "SourceTableViewController" {
            if storageManager.checkForDefaultLaunchFolder() != nil {
                self.selectedTableFolderURL = storageManager.checkForDefaultLaunchFolder()!
            } else {
                needsToSetDefaultLaunchFolder = true
            }
            
        }
        
        
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if tableID == "SourceTableViewController" {
            if needsToSetDefaultLaunchFolder == true {
                self.openFilePickerToChooseFile()
            }
        }
    }
    
    
    //This is set from both tables
    @IBAction func rowDoubleClicked(_ sender: Any) {
        if tidiTableView.selectedRow < 0 {return}
        let selectedItem = tableSourceTidiFileArray[tidiTableView.selectedRow]
        let newURL = selectedItem.url
        
        if newURL!.hasDirectoryPath {
            selectedTableFolderURL = newURL
        }
        
    }
    
    func updateTableFolderURL(newURL : URL) {
        self.selectedTableFolderURL = newURL
    }
    

    
    
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
                tidiFileArray.append(tidiFileToAdd)
            } catch {
                return []
            }
            
        }
        
        return tidiFileArray
        
    }
}



extension TidiTableViewController {
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
    
    func openFilePickerToChooseFile() {
        guard let window = NSApplication.shared.mainWindow else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                self.selectedTableFolderURL = panel.urls[0]
                self.storageManager.saveDefaultLaunchFolder(self.selectedTableFolderURL)
            }
        }
    }
}

extension TidiTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableSourceTidiFileArray.count
    }
}

extension TidiTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableColumn == tableView.tableColumns[0] {
            let item = tableSourceTidiFileArray[row].url
            let fileIcon = NSWorkspace.shared.icon(forFile: item!.path)
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("tidiCellView"), owner: self) as! NSTableCellView
                cell.textField?.stringValue = item!.lastPathComponent
                cell.imageView?.image = fileIcon
                return cell
                
        } else if tableColumn == tableView.tableColumns[1] {
            let item = DateFormatter.localizedString(from: tableSourceTidiFileArray[row].createdDateAttribute!, dateStyle: .long, timeStyle: .long)
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("tidiCellView"), owner: self) as! NSTableCellView
                cell.textField?.stringValue = item
                return cell
        }

        return nil
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
//        let pasteboard = NSPasteboard.general
        let tidiFileToAdd = tableSourceTidiFileArray[row]
//        pasteboard.addTypes(TidiFile, owner: Any?)
        return PasteboardWriter(tidiFile: tidiFileToAdd, at: row)
    }
    
        func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation)
            -> NSDragOperation {
//                print("DROP VALIDATED")
                if let source = info.draggingSource as? NSTableView,
                    source === tableView
                {
                    tableView.draggingDestinationFeedbackStyle = .gap
                } else {
                    tableView.draggingDestinationFeedbackStyle = .regular
                }
                return .move
        }
    
        func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
    
            let pasteboard = info.draggingPasteboard
            let pasteboardItems = pasteboard.pasteboardItems

            let oldIndexs = pasteboardItems!.compactMap{ $0.integer(forType: .tableViewIndex) }
            let tifiFiles = pasteboardItems!.compactMap{ $0.tidiFile(forType: .tidiFile) }
            
            let oldIndex = oldIndexs.first
            let tidiFile = tifiFiles.first
            
            if storageManager.checkForDestinationFolder() == nil {
                storageManager.saveDefaultDestinationFolder()
            }
            
            if storageManager.checkForDestinationFolder() == nil {
                storageManager.saveDefaultDestinationFolder()
            }
            
            guard let destinationFolderURL = storageManager.checkForDestinationFolder()! else { return false }
            
            print(URL(fileURLWithPath: (tidiFile?.url!.deletingPathExtension().lastPathComponent)!))
            if destinationFolderURL == URL(fileURLWithPath: (tidiFile?.url!.deletingPathExtension().lastPathComponent)!) {
                print("SAME FOLDER")
            } else {
                self.storageManager.moveItem(atURL: tidiFile!.url!, toURL: destinationFolderURL, row: row) { (Bool, Error) in
                    if (Error != nil) {
                        print(Error as Any)
                    } else {
                        self.tableSourceTidiFileArray.insert(tidiFile!, at: row)
                        //Might want being/end updates when implmenting this for multiple file drags
                        self.tidiTableView.reloadData()
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
    static let tidiCellView = NSUserInterfaceItemIdentifier("tidiCellView")
}
