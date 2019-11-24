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
    
    let storageManager = StorageManager()
    var quickDropTableSourceURLArray : [URL] = []
    var quickDropSourceArrayAsStrings : [String] = []
    public var scrollEnabled : Bool = false
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var quickDropTableView: NSTableView!
    
    @IBAction func addNewQuickDropDirectoryButtonPressed (_ sender: Any) {
        openFilePickerToChooseFile()
    }
    
    @IBAction func removeMenuItemClicked(_ sender: Any) {
        removeQuickDropFolder(row: self.quickDropTableView.clickedRow)
    }
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        quickDropTableView.delegate = self
        quickDropTableView.dataSource = self
        
        quickDropTableView.registerForDraggedTypes([.fileURL, .tableViewIndex, .tidiFile])
        quickDropTableView.setDraggingSourceOperationMask(.move, forLocal: false)
        quickDropTableView.allowsMultipleSelection = false
        setTableViewDataSource()
        
    }
    
    func setTableViewDataSource() {
        quickDropSourceArrayAsStrings = storageManager.getQuickDropArray()
        quickDropTableSourceURLArray = []
        
        for item in quickDropSourceArrayAsStrings {
            
            let URLString = item
            let url = URL.init(string: URLString)
            quickDropTableSourceURLArray.append(url!)
        }
        
        quickDropTableView.reloadData()
        
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        print(view.frame.height)
        print((quickDropTableView.rowHeight  * CGFloat.init(integerLiteral: quickDropTableSourceURLArray.count)))
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
                if self.storageManager.addDirectoryToQuickDropArray(directoryToAdd: panel.urls[0].absoluteString) == false {
                    
                    let alert = NSAlert()
                    alert.messageText = "That folder is already added to Quick Drop"
                    alert.addButton(withTitle: "Cancel")
                    alert.addButton(withTitle: "Choose a different folder")
                    alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
                        if modalResponse == .alertSecondButtonReturn {
                            self.openFilePickerToChooseFile()
                        }
                    })
                    
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
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("QuickDropCellView"), owner: self) as! NSTableCellView
            cell.textField?.stringValue = item.lastPathComponent
                return cell
                
        }

        return nil
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
            let tidiFile = tidiFilesToMove.first

            var moveToURL : URL
            var wasErorMoving = false
            
            moveToURL = quickDropTableSourceURLArray[row]
            print("Movetourl:", moveToURL)

            for (index, tidiFile) in tidiFilesToMove.enumerated() {
                self.storageManager.moveItem(atURL: tidiFile.url!, toURL: moveToURL, row: row) { (Bool, Error) in
                    if (Error != nil) {
                        //To-do: throw user alert and reload both tables
                        print("Error Moving Files: %s", Error!)
                        wasErorMoving = true
                    } else {
                        print("File Moved")
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
