//
//  TidiTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/21/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

protocol TidiTableViewDelegate: AnyObject  {

    func navigationArraysEvaluation(backURLArrayCount : Int, forwarURLArrayCount : Int, activeTable : String)
}

protocol TidiTableViewFileUpdate: AnyObject {
    func fileInFocus(_ tidiFile: TidiFile, inFocus: Bool)
}

class TidiTableViewController: NSViewController  {
    
    // MARK: Properties
    // IBOutlets set from subclasses for each table
    let storageManager = StorageManager()
    var sourceFileURLArray : [URL] = []
    var tableSourceTidiFileArray : [TidiFile] = []
    var showInvisibles = false
    var tidiTableView : NSTableView = NSTableView.init()
    var toolbarController : ToolbarViewController?
    
    var needsToSetDefaultLaunchFolder = false
    
    var currentDirectoryURL : URL = URL.init(fileURLWithPath: " ")
    var destinationDirectoryURL : URL = URL.init(fileURLWithPath: " ")
 
    var backURLArray : [URL] = []
    var forwardURLArray : [URL] = []
    
    var isBackButtonEnabled : Bool = false
    var isForwardButtonEnabled : Bool = false
    
    
    //Make enum later?
    var currentTableID : String?
    
    weak var delegate: TidiTableViewDelegate?
    weak var fileDelegate : TidiTableViewFileUpdate?
    
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
        
        //Localize later
        tidiTableView.tableColumns[0].headerCell.stringValue = "File Name"
        tidiTableView.tableColumns[1].headerCell.stringValue = "Date Added"
        tidiTableView.tableColumns[2].headerCell.stringValue = "File Size"
       
        
        
        if storageManager.checkForDestinationFolder() == nil {
            // Currently Hardcoded -- Need to make dynamic
            storageManager.saveDefaultDestinationFolder()
        }
        
        
        
        if currentTableID == "DestinationTableViewController" {
             selectedTableFolderURL = storageManager.checkForDestinationFolder()!
            //Need a check if nil
            destinationDirectoryURL = storageManager.checkForSourceFolder()!!
            currentDirectoryURL = storageManager.checkForDestinationFolder()!!
        }
        
        if storageManager.checkForSourceFolder() == nil {
            needsToSetDefaultLaunchFolder = true
        } else {
            if currentTableID == "SourceTableViewController" {
                selectedTableFolderURL = storageManager.checkForSourceFolder()!
                destinationDirectoryURL = storageManager.checkForDestinationFolder()!!
                currentDirectoryURL = storageManager.checkForSourceFolder()!!

            }

        }
    
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if currentTableID == "SourceTableViewController" {
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
            backURLArray.append(selectedTableFolderURL!)
            selectedTableFolderURL = newURL
            isBackButtonEnabled = true
            delegate?.navigationArraysEvaluation(backURLArrayCount: backURLArray.count, forwarURLArrayCount: forwardURLArray.count, activeTable: currentTableID!)
        }
    }
    

    @IBAction func tableClickedToBringIntoFocus(_ sender: Any) {
        toolbarController?.delegate = self
//        delegate?.didUpdateFocus(sender: self as! TidiTableViewController, tableID: currentTableID!)
        delegate?.navigationArraysEvaluation(backURLArrayCount: backURLArray.count, forwarURLArrayCount: forwardURLArray.count, activeTable: currentTableID!)
        
        fileDelegate?.fileInFocus(tableSourceTidiFileArray[tidiTableView.selectedRow], inFocus: true)
    }
    
    
    func updateTableFolderURL(newURL : URL) {
        self.selectedTableFolderURL = newURL
    }
    
    
    func sortFiles(sortByKeyString : String, tidiArray : [TidiFile]) -> [TidiFile] {
        
        switch sortByKeyString {
        case "date-created-DESC":
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
                let tidiFileToAdd : TidiFile = TidiFile.init()
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
                        tidiFileToAdd.fileSizeAttribute = value as? Int64
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
                self.storageManager.saveDefaultSourceFolder(self.selectedTableFolderURL)
                self.currentDirectoryURL = panel.urls[0]
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
        } else if tableColumn == tableView.tableColumns[2] {
            let byteFormatter = ByteCountFormatter()
            byteFormatter.countStyle = .binary
            let item = byteFormatter.string(fromByteCount: tableSourceTidiFileArray[row].fileSizeAttribute!)
            
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
                
                tableView.draggingDestinationFeedbackStyle = .none
                if let source = info.draggingSource as? NSTableView, source === tableView {
                    var isDirectory : ObjCBool = false
                    if FileManager.default.fileExists(atPath: tableSourceTidiFileArray[row].url!.relativePath, isDirectory: &isDirectory) {
                        if isDirectory.boolValue == true {
                            tableView.draggingDestinationFeedbackStyle = .regular
                            tableView.selectionHighlightStyle = .regular
                             return .move
                        } else {
                         tableView.draggingDestinationFeedbackStyle = .regular
                         return []
                        }
                    } else {
                        return .move
                    }
                } else {
                    tableView.draggingDestinationFeedbackStyle = .regular
                    return .move
                }
//            return []
        }
    
    
        func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
    
            let pasteboard = info.draggingPasteboard
            let pasteboardItems = pasteboard.pasteboardItems

            let oldIndexs = pasteboardItems!.compactMap{ $0.integer(forType: .tableViewIndex) }
            let tifiFiles = pasteboardItems!.compactMap{ $0.tidiFile(forType: .tidiFile) }
            
            let oldIndex = oldIndexs.first
            let tidiFile = tifiFiles.first
            
            let destinationFolderURL = self.destinationDirectoryURL
            let tidiFileToMoveDirectory : URL = (tidiFile?.url!.deletingLastPathComponent())!

            //Check to see if the folder is being moved within the same table - if not, allow move to the current directory of the destination table being dragged to
            var isDirectory : ObjCBool = false
            if FileManager.default.fileExists(atPath: tableSourceTidiFileArray[row].url!.relativePath, isDirectory: &isDirectory) {
                if isDirectory.boolValue == true || info.draggingSource as? NSTableView !== tableView {
                    var moveToURL : URL
                    if isDirectory.boolValue {
                        moveToURL = tableSourceTidiFileArray[row].url!.absoluteURL
                    } else {
                        moveToURL = self.currentDirectoryURL
                    }
                    self.storageManager.moveItem(atURL: tidiFile!.url!, toURL: moveToURL, row: row) { (Bool, Error) in
                        if (Error != nil) {
                            print(Error as Any)
                        } else {
                            if isDirectory.boolValue == false {
                                self.tableSourceTidiFileArray.insert(tidiFile!, at: row)
                                self.tidiTableView.reloadData()
                            }
                            //Might want being/end updates when implmenting this for multiple file drags
 
                        }
                    }
                } else {
                    print("conditions not met")
                }
            }
            
            return true
        }
    
    

    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {

        if operation == .move, let items = session.draggingPasteboard.pasteboardItems {
            let indexes = items.compactMap{ $0.integer(forType: .tableViewIndex) }
            tableView.reloadData()
        }
    }
    
//    func debugNavSegment() {
//        print("Back Array")
//        print(backURLArray)
//        print("Forward Array")
//        print(forwardURLArray)
//    }
}


extension NSUserInterfaceItemIdentifier {
    static let tidiCellView = NSUserInterfaceItemIdentifier("tidiCellView")
}

extension TidiTableViewController: TidiToolBarDelegate {

    func backButtonPushed(sender: ToolbarViewController) {
        let currentURL = selectedTableFolderURL as! URL
        forwardURLArray.append(currentURL)
        selectedTableFolderURL = backURLArray.last
        
        if backURLArray.count > 0 {
            backURLArray.removeLast()
        }
        
        if backURLArray.count == 0 {
            forwardURLArray.removeAll()
        }
        
        delegate?.navigationArraysEvaluation(backURLArrayCount: backURLArray.count, forwarURLArrayCount: forwardURLArray.count, activeTable: currentTableID!)
//        debugNavSegment()
    }
    
    func forwardButtonPushed(sender: ToolbarViewController) {
        let currentURL = selectedTableFolderURL as! URL
        backURLArray.append(currentURL)
        selectedTableFolderURL = forwardURLArray.last
        if forwardURLArray.count > 0 {
            forwardURLArray.removeLast()
        }
        
        delegate?.navigationArraysEvaluation(backURLArrayCount: backURLArray.count, forwarURLArrayCount: forwardURLArray.count, activeTable: currentTableID!)
//        debugNavSegment()
    }

}
