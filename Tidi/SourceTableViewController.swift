//
//  SourceTableViewController.swift
//  Tidi
//
//  Created by Brad Zellman on 8/11/19.
//  Copyright © 2019 Brad Zellman. All rights reserved.
//

import Foundation
import Cocoa

class SourceTableViewController: NSViewController {

    
    //Mark: - Properties
    
//    let defaultSourceFolderURL = NSURL(string: "file:///Users/uicentric/Downloads/")
    
    let storageManager = StorageManager()
    var sourceTableFileURLArray: [URL] = []
    var showInvisibles = false
    var needsToSetDefaultLaunchFolder = false
    
    
    var selectedSourceTableFolder: URL? {
        didSet {
            if let selectedSourceTableFolder = selectedSourceTableFolder {
                sourceTableFileURLArray = contentsOf(folder: selectedSourceTableFolder)
                self.sourceTableView.reloadData()
                self.sourceTableView.scrollRowToVisible(0)
                print(sourceTableFileURLArray)
            } else {
                //Handle more gracefully
                print("No File Set")
            }
        }
    }
    
    //Mark: - Outlets
    @IBOutlet weak var sourceTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceTableView.delegate = self
        sourceTableView.dataSource = self
        
        sourceTableView.registerForDraggedTypes([.fileURL])
        sourceTableView.setDraggingSourceOperationMask(.move, forLocal: false)
        
        
        if storageManager.checkForDefaultLaunchFolder() != nil {
            self.selectedSourceTableFolder = storageManager.checkForDefaultLaunchFolder()!
        } else {
            needsToSetDefaultLaunchFolder = true
        }
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if needsToSetDefaultLaunchFolder == true {
            self.openFilePickerToChooseFile()
        }
        
    }
    
}

extension SourceTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.sourceTableFileURLArray.count
    }
    

    
}

extension SourceTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = sourceTableFileURLArray[row]
        let fileIcon = NSWorkspace.shared.icon(forFile: item.path)
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "sourceCellView"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = item.lastPathComponent
            cell.imageView?.image = fileIcon
            return cell
        }
        return nil
    }

}


// MARK: - Getting file or folder information - needs it's own class - to likely be reused

extension SourceTableViewController {
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

extension SourceTableViewController {
    
    func openFilePickerToChooseFile() {
        guard let window = NSApplication.shared.mainWindow else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                self.selectedSourceTableFolder = panel.urls[0]
                self.storageManager.saveDefaultLaunchFolder(self.selectedSourceTableFolder)
            }
        }
    }

}


extension NSUserInterfaceItemIdentifier {
    static let sourceCellView = NSUserInterfaceItemIdentifier("sourceCellView")
}
