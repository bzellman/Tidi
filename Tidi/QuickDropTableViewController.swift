//
//  QuickDropTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 11/21/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class QuickDropTableViewController: NSViewController {
    
    let storageManger = StorageManager()
    var quickDropTableSourceURLArray : [URL] = []
    var quickDropSourceArrayAsStrings : [String] = []
    
    @IBOutlet weak var quickDropTableView: NSTableView!
    
    @IBAction func addNewQuickDropDirectoryButtonPressed (_ sender: Any) {
        openFilePickerToChooseFile()
    }
    
    override func viewDidLoad() {
//        self.currentTableID = "QuickDropTableViewController"
        super .viewDidLoad()
        
        quickDropTableView.delegate = self
        quickDropTableView.dataSource = self
        
        quickDropTableView.registerForDraggedTypes([.fileURL, .tableViewIndex, .tidiFile])
//         quickDropTableView.setDraggingSourceOperationMask(.move, forLocal: false)
         quickDropTableView.allowsMultipleSelection = false
         quickDropTableView.usesAlternatingRowBackgroundColors = false
         setTableViewDataSource()
        
        
    }
    
    func setTableViewDataSource() {
        quickDropSourceArrayAsStrings = storageManger.getQuickDropArray()
        
        for item in quickDropSourceArrayAsStrings {
            let URLString = item
            let url = URL.init(fileURLWithPath: URLString)
            quickDropTableSourceURLArray.append(url)
        }
        
        print(quickDropTableSourceURLArray)
        quickDropTableView.reloadData()
        
    }
    
    func openFilePickerToChooseFile() {
        guard let window = NSApplication.shared.mainWindow else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                self.storageManger.addDirectoryToQuickDropArray(directoryToAdd: panel.urls[0].absoluteString)
                }
            }
        setTableViewDataSource()
        
    }
}

extension QuickDropTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        print(quickDropTableSourceURLArray.count)
        return quickDropTableSourceURLArray.count
    }
}

extension QuickDropTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableColumn == tableView.tableColumns[0] {
//            let item = quickDropTableSourceURLArray[row]
//            let fileIcon = NSWorkspace.shared.icon(forFile: item!.path)
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("QuickDropCellView"), owner: self) as! NSTableCellView
//                cell.textField?.stringValue = item!.lastPathComponent
//                cell.imageView?.image = fileIcon
                return cell
                
        }

        return nil
    }
    
    
//    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//        return 28
//    }
    
    // MARK: DRAGGING FUNCTIONS
//    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
////        print(tableView.selectedRowIndexes)
//        let tidiFileToAdd = quickDropTableSourceURLArray[row]
//        return PasteboardWriter(tidiFile: tidiFileToAdd, at: row)
//    }
//
//        func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation)
//            -> NSDragOperation {
//
//                var isDirectory : ObjCBool = false
//                if row < quickDropTableSourceURLArray.count {
//                    if FileManager.default.fileExists(atPath: quickDropTableSourceURLArray[row].url!.relativePath, isDirectory: &isDirectory) {
//                        if isDirectory.boolValue == true {
//                            tableView.draggingDestinationFeedbackStyle = .regular
//                            tableView.setDropRow(row, dropOperation: .on)
//                            return .move
//                        }
//
//                    }
//                }
//
//                if let source = info.draggingSource as? NSTableView, source !== tableView {
//                      tableView.setDropRow(-1, dropOperation: .on)
//                      return .move
//                  }
//
//                return[]
//        }
//
//
//        func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
//
//            let pasteboard = info.draggingPasteboard
//            let pasteboardItems = pasteboard.pasteboardItems
//
//            let tidiFilesToMove = pasteboardItems!.compactMap{ $0.tidiFile(forType: .tidiFile) }
//            let tidiFile = tidiFilesToMove.first
//
//            let destinationFolderURL = self.destinationDirectoryURL
//            let tidiFileToMoveDirectory : URL = (tidiFile?.url!.deletingLastPathComponent())!
//
//            var moveToURL : URL
//            var wasErorMoving = false
//            if row == -1 || quickDropTableSourceURLArray.count < 0 {
//                moveToURL = self.currentDirectoryURL
//            } else {
//                // Validation that this is directory happens in  prepare for drop method. If it isn't a directory, row would be set to -1.
//                moveToURL = quickDropTableSourceURLArray[row].url!.absoluteURL
//            }
//
//            for (index, tidiFile) in tidiFilesToMove.enumerated() {
//                self.storageManager.moveItem(atURL: tidiFile.url!, toURL: moveToURL, row: row) { (Bool, Error) in
//                    if (Error != nil) {
//                        //To-do: throw user alert and reload both tables
//                        print("Error Moving Files: %s", Error!)
//                        wasErorMoving = true
//                    } else {
//                        //To-do: Should build better completion handler- this happens to often - build in async handler with progress
//                        self.quickDropTableSourceURLArray.append(tidiFile)
//                            self.quickDropTableSourceURLArray = self.sortFiles(sortByKeyString: self.currentSortStringKey, tidiArray: self.quickDropTableSourceURLArray)
//                        tableView.reloadData()
//                    }
//                }
//            }
//
//            if wasErorMoving == true {
//                return false
//            } else {
//                return true
//            }
//
//        }
//
//
//    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
//
//        if operation == .move {
//            self.quickDropTableSourceURLArray.removeAll { $0.isSelected == true }
//            tableView.reloadData()
//            clearIsSelected()
//        }
//    }
}
