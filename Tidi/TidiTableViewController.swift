//
//  TidiTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/21/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import QuickLook
import Quartz
import Cocoa

protocol TidiTableViewDelegate: AnyObject {

    func navigationArraysEvaluation(backURLArrayCount : Int, forwarURLArrayCount : Int, activeTable : String)
}

protocol TidiTableViewFileUpdate: AnyObject {
    func fileInFocus(_ tidiFile: TidiFile, inFocus: Bool)
}



class TidiTableViewController: NSViewController, QLPreviewPanelDataSource, QLPreviewPanelDelegate    {
    
    // MARK: Properties
    // IBOutlets set from subclasses for each table
    let storageManager = StorageManager()
    let sharedPanel = QLPreviewPanel.shared()
    
    var sourceFileURLArray : [URL] = []
    var tableSourceTidiFileArray : [TidiFile] = []
    var showInvisibles = false
    var tidiTableView : NSTableView = NSTableView.init()
//    var toolbarController : ToolbarViewController?
    
    var needsToSetDefaultSourceTableFolder = false
    var needsToSetDefaultDestinationTableFolder = false
    
    var currentDirectoryURL : URL = URL.init(fileURLWithPath: " ")
    var destinationDirectoryURL : URL = URL.init(fileURLWithPath: " ")
 
    var backURLArray : [URL] = []
    var forwardURLArray : [URL] = []
    
    var isBackButtonEnabled : Bool = false
    var isForwardButtonEnabled : Bool = false
    
    var currentlySelectedItems : [(TidiFile, Int)] = []
    
    var currentSortStringKey : String = ""
    
    //Make enum later?
    var currentTableID : String?
    
    weak var delegate: TidiTableViewDelegate?
    weak var fileDelegate : TidiTableViewFileUpdate?
    
    var selectedTableFolderURL: URL? {
        didSet {
            if let selectedTableFolderURL = selectedTableFolderURL {
                sourceFileURLArray = contentsOf(folder: selectedTableFolderURL)
                let unsortedFileWithAttributeArray = fileAttributeArray(fileURLArray: sourceFileURLArray)
                tableSourceTidiFileArray = sortFiles(sortByKeyString: currentSortStringKey, tidiArray: unsortedFileWithAttributeArray)
                tidiTableView.reloadData()
                tidiTableView.scrollRowToVisible(0)
            } else {
                //Handle more gracefully
                print("No File Set")
            }
        }
    }
    
    var toolbarController : ToolbarViewController? {
        didSet{
            if currentTableID == "DestinationTableViewController" {
                toolbarController?.destinationTableViewController = self
            } else if currentTableID == "SourceTableViewController" {
                toolbarController?.sourceTableViewController = self
            }
           
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tidiTableView.delegate = self
        tidiTableView.dataSource = self
        
        tidiTableView.registerForDraggedTypes([.fileURL, .tableViewIndex, .tidiFile])
        tidiTableView.setDraggingSourceOperationMask(.move, forLocal: false)
        tidiTableView.allowsMultipleSelection = true
        tidiTableView.usesAlternatingRowBackgroundColors = true
        
        
        //TODO: Localize Strings
        tidiTableView.tableColumns[0].headerCell.stringValue = "File Name"
        tidiTableView.tableColumns[1].headerCell.stringValue = "Date Created"
        tidiTableView.tableColumns[2].headerCell.stringValue = "File Size"
       
        
        currentSortStringKey = "date-created-DESC"
        
    }
        

    @IBAction func rowDoubleClicked(_ sender: Any) {
        if tidiTableView.selectedRow < 0 { return }
        let selectedItem = tableSourceTidiFileArray[tidiTableView.selectedRow]
        let newURL = selectedItem.url
        
        if newURL!.hasDirectoryPath {
            currentDirectoryURL = newURL!
            backURLArray.append(selectedTableFolderURL!)
            selectedTableFolderURL = newURL
            isBackButtonEnabled = true
            delegate?.navigationArraysEvaluation(backURLArrayCount: backURLArray.count, forwarURLArrayCount: forwardURLArray.count, activeTable: currentTableID!)
            clearIsSelected()
        }
    }
    

    @IBAction func tableClickedToBringIntoFocus(_ sender: Any) {
        
        toolbarController?.delegate = self
        clearIsSelected()
        delegate?.navigationArraysEvaluation(backURLArrayCount: backURLArray.count, forwarURLArrayCount: forwardURLArray.count, activeTable: currentTableID!)

        
        
        if tidiTableView.selectedRow >= 0  {
            fileDelegate?.fileInFocus(tableSourceTidiFileArray[tidiTableView.selectedRow], inFocus: true)
            
            for index in tidiTableView.selectedRowIndexes{
                currentlySelectedItems.append((tableSourceTidiFileArray[index], index))
                tableSourceTidiFileArray[index].isSelected = true
                
                if sharedPanel!.isVisible == true {
                    if sharedPanel!.delegate !== self {
                        sharedPanel!.delegate = self
                        sharedPanel!.dataSource = self as! QLPreviewPanelDataSource
                    }
                    
                    sharedPanel!.reloadData()
                    
                 }
                
            }
        }
        
    }
    
    override func keyDown(with event: NSEvent) {
        
        if event.characters == " " {
            if sharedPanel!.isVisible == true {
                 sharedPanel!.close()
             }
            togglePreviewPanel()
        }

    }

    
    
    func togglePreviewPanel() {
        if currentlySelectedItems.count == 1 {
            sharedPanel!.delegate = self
            sharedPanel!.dataSource = self as! QLPreviewPanelDataSource
            sharedPanel!.makeKeyAndOrderFront(self)
            }
    }
    

    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return 1
    }

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        let url = currentlySelectedItems.first?.0.url
        return url as! QLPreviewItem
    }
    
    
    func updateTableFolderURL(newURL : URL) {
        self.selectedTableFolderURL = newURL
    }
    
    
    
    func sortFiles(sortByKeyString : String, tidiArray : [TidiFile]) -> [TidiFile] {
        currentSortStringKey = sortByKeyString
        switch sortByKeyString {
        case "date-created-DESC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $0.createdDateAttribute! > $1.createdDateAttribute as! Date})
            return sortedtidiArrayWithFileAttributes
        case "date-created-ASC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $1.createdDateAttribute! > $0.createdDateAttribute as! Date})
            return sortedtidiArrayWithFileAttributes
        case "date-modified-DESC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $0.createdDateAttribute! > $1.createdDateAttribute as! Date})
            return sortedtidiArrayWithFileAttributes
        case "date-modified-ASC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $1.createdDateAttribute! > $0.createdDateAttribute as! Date})
            return sortedtidiArrayWithFileAttributes
        case "file-size-DESC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $0.fileSizeAttribute! > $1.fileSizeAttribute as! Int64})
            return sortedtidiArrayWithFileAttributes
        case "file-size-ASC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $1.fileSizeAttribute! > $0.fileSizeAttribute!})
            return sortedtidiArrayWithFileAttributes
        case "file-name-DESC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { ($0.url?.lastPathComponent)! > $1.url?.lastPathComponent as! String})
            return sortedtidiArrayWithFileAttributes
        case "file-name-ASC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { ($1.url?.lastPathComponent)! > $0.url?.lastPathComponent as! String})
            return sortedtidiArrayWithFileAttributes
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
    
    func clearIsSelected() {
        // Would rather not itterate over the whole array
        currentlySelectedItems = []
        for tidiFile in self.tableSourceTidiFileArray {
            if tidiFile.isSelected == true {
                tidiFile.isSelected = false
            }
        }
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
                if self.currentTableID == "SourceTableViewController" {
                    if self.needsToSetDefaultSourceTableFolder == true {
                        self.storageManager.saveDefaultSourceFolder(self.selectedTableFolderURL)
                        self.needsToSetDefaultSourceTableFolder = false
                    }
                } else if self.currentTableID == "DestinationTableViewController" {
                    if self.needsToSetDefaultDestinationTableFolder == true {
                        self.storageManager.saveDefaultDestinationFolder(self.selectedTableFolderURL)
                        self.needsToSetDefaultDestinationTableFolder = false
                    }
                    
                }
                
                self.currentDirectoryURL = panel.urls[0]
            }
        }
        
    }
    
    func moveItemsToTrash() {
        
        var arrayOfTidiFilesToTrash : [TidiFile] = []
        
        for tidiFile in self.tableSourceTidiFileArray {
            if tidiFile.isSelected == true {
                arrayOfTidiFilesToTrash.append(tidiFile)
            }
        }
        
        
        
        for tidiFile in arrayOfTidiFilesToTrash {
            print(tidiFile.url?.lastPathComponent)
            
            do {
                try FileManager.default.trashItem(at: tidiFile.url!, resultingItemURL: nil)
            }
            catch let error as NSError {
                print("Something went wrong: \(error)")
            }
        }
        
        self.tableSourceTidiFileArray.removeAll { $0.isSelected == true }
        
        clearIsSelected()
        tidiTableView.reloadData()
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
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let descriptor : NSSortDescriptor = tableView.sortDescriptors.first!
            if descriptor.key == "dateCreateSortKey" && descriptor.ascending == false {
                tableSourceTidiFileArray = sortFiles(sortByKeyString: "date-created-DESC", tidiArray: tableSourceTidiFileArray)
            } else if descriptor.key == "dateCreateSortKey" && descriptor.ascending == true {
                tableSourceTidiFileArray = sortFiles(sortByKeyString: "date-created-ASC", tidiArray: tableSourceTidiFileArray)
            } else if descriptor.key == "dateModifiedSortKey" && descriptor.ascending == false {
                tableSourceTidiFileArray = sortFiles(sortByKeyString: "date-modified-DESC", tidiArray: tableSourceTidiFileArray)
            } else if descriptor.key == "dateModifiedSortKey" && descriptor.ascending == true {
                tableSourceTidiFileArray = sortFiles(sortByKeyString: "date-modified-ASC", tidiArray: tableSourceTidiFileArray)
            } else if descriptor.key == "fileNameSortKey" && descriptor.ascending == false {
                tableSourceTidiFileArray = sortFiles(sortByKeyString: "file-name-DESC", tidiArray: tableSourceTidiFileArray)
            } else if descriptor.key == "fileNameSortKey" && descriptor.ascending == true {
                tableSourceTidiFileArray = sortFiles(sortByKeyString: "file-name-ASC", tidiArray: tableSourceTidiFileArray)
            } else if descriptor.key == "fileSizeSortKey" && descriptor.ascending == false {
                tableSourceTidiFileArray = sortFiles(sortByKeyString: "file-size-DESC", tidiArray: tableSourceTidiFileArray)
            } else if descriptor.key == "fileSizeSortKey" && descriptor.ascending == true {
                tableSourceTidiFileArray = sortFiles(sortByKeyString: "file-size-ASC", tidiArray: tableSourceTidiFileArray)
            }
        
        tableView.reloadData()
        tidiTableView.scrollRowToVisible(0)
    }
    
    // MARK: DRAGGING FUNCTIONS
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        print(tableView.selectedRowIndexes)
        let tidiFileToAdd = tableSourceTidiFileArray[row]
        return PasteboardWriter(tidiFile: tidiFileToAdd, at: row)
    }
    
        func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation)
            -> NSDragOperation {
                
                var isDirectory : ObjCBool = false
                if row < tableSourceTidiFileArray.count {
                    if FileManager.default.fileExists(atPath: tableSourceTidiFileArray[row].url!.relativePath, isDirectory: &isDirectory) {
                        if isDirectory.boolValue == true {
                            tableView.draggingDestinationFeedbackStyle = .regular
                            tableView.setDropRow(row, dropOperation: .on)
                            return .move
                        }
                    
                    }
                }
                
                if let source = info.draggingSource as? NSTableView, source !== tableView {
                      tableView.setDropRow(-1, dropOperation: .on)
                      return .move
                  }
                
                return[]
        }
    
    
        func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
    
            let pasteboard = info.draggingPasteboard
            let pasteboardItems = pasteboard.pasteboardItems

            let tidiFilesToMove = pasteboardItems!.compactMap{ $0.tidiFile(forType: .tidiFile) }
            let tidiFile = tidiFilesToMove.first
            
            let destinationFolderURL = self.destinationDirectoryURL
            let tidiFileToMoveDirectory : URL = (tidiFile?.url!.deletingLastPathComponent())!
            
            var moveToURL : URL
            var wasErorMoving = false
            if row == -1 || tableSourceTidiFileArray.count < 0 {
                moveToURL = self.currentDirectoryURL
            } else {
                // Validation that this is directory happens in  prepare for drop method. If it isn't a directory, row would be set to -1.
                moveToURL = tableSourceTidiFileArray[row].url!.absoluteURL
            }
//            print("Move to is %s", moveToURL)
            for (index, tidiFile) in tidiFilesToMove.enumerated() {
                self.storageManager.moveItem(atURL: tidiFile.url!, toURL: moveToURL, row: row) { (Bool, Error) in
                    if (Error != nil) {
                        //To-do: throw user alert
                        print("Error Moving Files: %s", Error!)
                        wasErorMoving = true
                    } else {
                        self.tableSourceTidiFileArray.append(tidiFile)
                        //To-do: Should build better completion handler
                        if index == tidiFilesToMove.count-1 {
                            self.tableSourceTidiFileArray = self.sortFiles(sortByKeyString: self.currentSortStringKey, tidiArray: self.tableSourceTidiFileArray)
                            tableView.reloadData()
                        }
                    }
            
                }
                
            }

            if wasErorMoving == true {
                return false
            } else {
                return true
            }
            
        }
            
    
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        
        if operation == .move {
            
            self.tableSourceTidiFileArray.removeAll { $0.isSelected == true }
            tableView.reloadData()
            clearIsSelected()
        }
    }
    
    func debugNavSegment() {
        print("Back Array")
        print(backURLArray)
        print("Forward Array")
        print(forwardURLArray)
    }
}

// MARK: DataHandling
extension TidiTableViewController  {
    
    @objc func changeDefaultLaunchFolder() {
        self.needsToSetDefaultSourceTableFolder = true
        self.openFilePickerToChooseFile()
    }
    
    @objc func resetDefaultDestinationFolder() {
//        storageManager.clearDefaultDetinationFolder()
        
    }
    
    @objc func changeDefaultDestinationFolder() {
        self.needsToSetDefaultDestinationTableFolder = true
        self.openFilePickerToChooseFile()
    }
}


extension NSUserInterfaceItemIdentifier {
    static let tidiCellView = NSUserInterfaceItemIdentifier("tidiCellView")
}

extension TidiTableViewController: TidiToolBarDelegate {

    
    func trashButtonPushed(sender: ToolbarViewController) {
        moveItemsToTrash()
        
    }
    

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


