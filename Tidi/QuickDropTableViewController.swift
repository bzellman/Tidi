//
//  QuickDropTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 11/21/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

protocol QuickDropTableViewControllerDelegate : AnyObject {
    func quickDropItemDoubleClicked(urlOfSelectedFoler : URL)
}

class QuickDropTableViewController: NSViewController {
    
    let storageManager = StorageManager()
    var quickDropTableSourceURLArray : [URL] = []
    var quickDropSourceArrayAsStrings : [String] = []
    var delegate : QuickDropTableViewControllerDelegate?
    
    public var scrollEnabled : Bool = false
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var quickDropTableView: NSTableView!
    
    @IBAction func addNewQuickDropDirectoryButtonPressed (_ sender: Any) {
        openFilePickerToChooseFile()
    }
    
    @IBAction func removeMenuItemClicked(_ sender: Any) {
        removeQuickDropFolder(row: self.quickDropTableView.clickedRow)
    }
    
    @IBAction func quickDropItemDoubleClicked(_ sender: Any) {
        delegate?.quickDropItemDoubleClicked(urlOfSelectedFoler: quickDropTableSourceURLArray[quickDropTableView.clickedRow])
    }
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        quickDropTableView.delegate = self
        quickDropTableView.dataSource = self
        
        
        quickDropTableView.registerForDraggedTypes([.fileURL, .tableViewIndex, .tidiFile])
        quickDropTableView.setDraggingSourceOperationMask(.move, forLocal: false)
        quickDropTableView.allowsMultipleSelection = false
    }
    
    override func viewWillAppear() {
        super .viewWillAppear()
        
        setTableViewDataSource()
    }
    
    func setTableViewDataSource() {
        quickDropSourceArrayAsStrings = storageManager.getQuickDropArray()
        quickDropTableSourceURLArray = []
        
        for (index, item) in quickDropSourceArrayAsStrings.enumerated() {
            let URLString = item
            let url = URL.init(string: URLString)
            var isDirectory : ObjCBool = true
            let fileExists : Bool = FileManager.default.fileExists(atPath: url!.relativePath, isDirectory: &isDirectory)
            if fileExists && isDirectory.boolValue {
               quickDropTableSourceURLArray.append(url!)
            } else {
                storageManager.removeQuickDropItem(row: index)
               let missingFolderName : String = url!.lastPathComponent
               let alertStringWithURL : String = "Something went wrong! \n\nWe can't find the QuickDrop Folder \"\(missingFolderName)\". It may have been moved or deleted. \n\nPlease re-add \(missingFolderName) at it's updated location."
               AlertManager().showSheetAlertWithOnlyDismissButton(messageText: alertStringWithURL, buttonText: "Okay", presentingView: self.view.window!)
           }
            
        }
        
        quickDropTableView.reloadData()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        if view.frame.height > (quickDropTableView.rowHeight  * CGFloat.init(integerLiteral: quickDropTableSourceURLArray.count)) {
            scrollView.verticalScrollElasticity = .none
        } else {
          scrollView.verticalScrollElasticity = .allowed
        }
    }
    
    func removeQuickDropFolder(row : Int) {
        storageManager.removeQuickDropItem(row: row)
        setTableViewDataSource()
    }
    
    func openFilePickerToChooseFile() {
        guard let window = NSApplication.shared.mainWindow else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                DirectoryManager().allowFolder(urlToAllow: panel.urls[0])
                if self.storageManager.addDirectoryToQuickDropArray(directoryToAdd: panel.urls[0].absoluteString) == false {
                    AlertManager().showSheetAlertWithOneAction(messageText: "That folder is already added to Quick Drop", dismissButtonText: "Cancel", actionButtonText: "Choose a different folder", presentingView: self.view.window!) {
                        self.openFilePickerToChooseFile()
                    }
                }
                self.setTableViewDataSource()
                }
            }
    }
}

extension QuickDropTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return quickDropTableSourceURLArray.count
    }
}

extension QuickDropTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableColumn == tableView.tableColumns[0] {
            let item = quickDropTableSourceURLArray[row]
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("QuickDropCellView"), owner: self) as! TidiQuickDropTableCell
            cell.textField?.stringValue = item.lastPathComponent
            if row < 9 {
                cell.folderLabel.stringValue = "⌘ " + String(row+1)
            } else {
                cell.folderLabel.stringValue = ""
            }
            
            return cell
                
        }

        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    
    // MARK: DRAGGING FUNCTIONS

        func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation)
            -> NSDragOperation {

                if let source = info.draggingSource as? NSTableView, source !== tableView {
                      return .move
                  }

                return[]
        }


        func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {

            let pasteboard = info.draggingPasteboard
            let pasteboardItems = pasteboard.pasteboardItems

            let tidiFilesToMove = pasteboardItems!.compactMap{ $0.tidiFile(forType: .tidiFile) }

            var moveToURL : URL
            var wasErorMoving = false
            
            moveToURL = quickDropTableSourceURLArray[row]

            for tidiFile in tidiFilesToMove {
                self.storageManager.moveItem(atURL: tidiFile.url!, toURL: moveToURL) { (Bool, Error) in
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

}
