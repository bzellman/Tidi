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
    
    //    let defaultSourceFolderURL = NSURL(string: "file:///Users/uicentric/Downloads/")
    
    let storageManager = StorageManager()
    var sourceDestinationFileURLArray: [URL] = []
    var showInvisibles = false
    
    
    //Mark: - Outlets
    
    
    
    
    @IBOutlet weak var destinationTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            destinationTableView.delegate = self
            destinationTableView.dataSource = self

            destinationTableView.registerForDraggedTypes([.fileURL])
            destinationTableView.setDraggingSourceOperationMask(.move, forLocal: false)
        
            var selectedDestinationTableFolder: URL? {
                didSet {
                    if let selectedDestinationTableFolder = selectedDestinationTableFolder {
                        sourceDestinationFileURLArray = contentsOf(folder: selectedDestinationTableFolder)
                        destinationTableView.reloadData()
                        destinationTableView.scrollRowToVisible(0)
                        
//                        print(sourceDestinationFileURLArray)
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

extension DestinationTableViewController {

    

    
    
    

}




// MARK: - Getting file or folder information - needs it's own class - to likely be reused

extension DestinationTableViewController {
    // this will be common code and likley should have it's own custom class when refactoring and cleaning up
    
    func contentsOf(folder: URL) -> [URL] {
        let fileManager = FileManager.default
        
        do {
            let folderContents = try fileManager.contentsOfDirectory(atPath: folder.path)
            let folderFileURLS = folderContents
                .map {return folder.appendingPathComponent($0)}
            
            return folderFileURLS
        } catch {
            return []
        }
    }
    
    // Need when setting metadata
    func infoAbout(url:URL) -> String {
        let fileManger = FileManager.default
        do {
            let attributes = try fileManger.attributesOfItem(atPath: url.path)
            var report: [String] = ["\(url.path)", ""]
            
            for (key, value) in attributes {
                if key.rawValue == "NSFileExtendedAttributes" { continue }
                report.append("\(key.rawValue):\t \(value)")
            }
            
            return report.joined(separator: "\n")
        } catch {
            return "No Info availbile for \(url.path)"
        }
    }
    
    
}


extension DestinationTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.sourceDestinationFileURLArray.count
    }
    
    
    
}

extension DestinationTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = sourceDestinationFileURLArray[row]
        let fileIcon = NSWorkspace.shared.icon(forFile: item.path)
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "destinationCellView"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = item.lastPathComponent
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
    
    func tableView(
        _ tableView: NSTableView,
        acceptDrop info: NSDraggingInfo,
        row: Int,
        dropOperation: NSTableView.DropOperation) -> Bool {
        
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
                
                self.storageManager.moveItem(atURL: urlFromString, toURL: destinationFolderURL) { (Bool, Error) in
                    if (Error != nil) {
                        print(Error as Any)
                    }
                    
                }
                destinationTableView.reloadData()
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
