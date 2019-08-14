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
    //need to become dynamic
    
    let defaultSourceFolderURL = NSURL(string: "file:///Users/uicentric/Downloads/")
    
    
    var sourceTableFileFolderURL: NSURL = NSURL(string: "file:///Users/uicentric/Downloads/")!
    var sourceTableFileURLArray: [URL] = []
    
    
    
    @IBOutlet weak var sourceTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceTableView.delegate = self
        sourceTableView.dataSource = self
        
        sourceTableView.registerForDraggedTypes([.fileURL])
        sourceTableView.setDraggingSourceOperationMask(.move, forLocal: false)
        
    }
    
    
    
    var filesList = contentsOf(folder: self.sourceTableFileFolderURL)
    
    
    
    
}

extension SourceTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.sourceTableFileURLArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: .sourceCellView, owner: self) as! NSTableCellView
        cell.textField?.stringValue = self.sourceTableFileURLArray[row] as! String
        return cell
    }

    
}

extension SourceTableViewController: NSTableViewDelegate {
    
}

extension NSUserInterfaceItemIdentifier {
    static let sourceCellView = NSUserInterfaceItemIdentifier("sourceCellView")
}
