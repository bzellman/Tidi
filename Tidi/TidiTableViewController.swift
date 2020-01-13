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
    
    func updateFilter(filterString : String)
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
    var tableSourceDisplayTidiFileArray : [TidiFile] = []
    var showInvisibles = false
    var tidiTableView : NSTableView = NSTableView.init()
    
    var isSourceFolderSet = false
    var isDestinationTableFolderSet = false
    
    var currentDirectoryURL : URL = URL.init(fileURLWithPath: " ")
    var destinationDirectoryURL : URL = URL.init(fileURLWithPath: " ")
 
    var backURLArray : [URL] = []
    var forwardURLArray : [URL] = []
    
    var isBackButtonEnabled : Bool = false
    var isForwardButtonEnabled : Bool = false
    
    var currentlySelectedItems : [(TidiFile, Int)] = []
    
    var currentSortStringKey : String = ""
    
    var changeFolderButton : NSButton = NSButton.init()
    
    var activeFilterString : String = ""
    var shouldReloadTableView : Bool = false
    var isUpdatingTable : Bool = false
    
    var currentTableID : String?
    var currentTableName : String?
    var debugInt : Int = 0
    
    weak var delegate: TidiTableViewDelegate?
    weak var fileDelegate : TidiTableViewFileUpdate?
    
    var selectedTableFolderURL: URL? {
        didSet {
            if let selectedTableFolderURL = selectedTableFolderURL {
                sourceFileURLArray = contentsOf(folder: selectedTableFolderURL)
                let unsortedFileWithAttributeArray = fileAttributeArray(fileURLArray: sourceFileURLArray)
                selectedFolderTidiFileArray = sortFiles(sortByKeyString: currentSortStringKey, tidiArray: unsortedFileWithAttributeArray)
                tidiTableView.reloadData()
                tidiTableView.scrollRowToVisible(0)
            } else {
                AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "There's no folder set for your \(currentTableName ?? "Default Tidi Folder"). \n\nPlease set a folder", buttonText: "Ok", presentingView: self.view.window!)
                print("No File Set")
            }
        }
    }
    
    var selectedFolderTidiFileArray : [TidiFile]? {
        didSet {
            filterArray(filterString: activeFilterString)
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
        
        DirectoryManager().loadBookmarks()
        
        currentSortStringKey = "date-created-DESC"
        NotificationCenter.default.addObserver(self, selector: #selector(self.tableInFocusDidChange), name: NSNotification.Name("tableInFocusDidChangeNotification"), object: nil)
        
        tidiTableView.registerForDraggedTypes([.fileURL, .tableViewIndex, .tidiFile])
        tidiTableView.setDraggingSourceOperationMask(.move, forLocal: false)
        tidiTableView.allowsMultipleSelection = true
        tidiTableView.usesAlternatingRowBackgroundColors = true
        
        //To-Do: Localize Strings
        tidiTableView.tableColumns[0].headerCell.stringValue = "File Name"
        tidiTableView.tableColumns[1].headerCell.stringValue = "Date Created"
        tidiTableView.tableColumns[2].headerCell.stringValue = "File Size"
       

        shouldReloadTableView = true
        
        
    }
        

    @IBAction func rowDoubleClicked(_ sender: Any) {
        if tidiTableView.selectedRow < 0 { return }
        let selectedItem = tableSourceDisplayTidiFileArray[tidiTableView.selectedRow]
        let newURL = selectedItem.url
        
        if newURL!.hasDirectoryPath {
            currentDirectoryURL = newURL!
            backURLArray.append(selectedTableFolderURL!)
            selectedTableFolderURL = newURL
            isBackButtonEnabled = true
            delegate?.navigationArraysEvaluation(backURLArrayCount: backURLArray.count, forwarURLArrayCount: forwardURLArray.count, activeTable: currentTableID!)
            clearIsSelected()
        } else {
            if currentlySelectedItems.count == 1{
                NSWorkspace.shared.open(currentlySelectedItems[0].0.url!)
            }
            
        }
    }
    

    @IBAction func tableClickedToBringIntoFocus(_ sender: Any) {
        /// Use Broadcast Notification since it's possible this can be extended to be a tabbed or multiwindow application
        NotificationCenter.default.post(name: NSNotification.Name("tableInFocusDidChangeNotification"), object: nil, userInfo: ["postedTableID" : currentTableID!])
        toolbarController?.delegate = self
        tidiTableView.delegate = self
        delegate?.updateFilter(filterString: activeFilterString)
        delegate?.navigationArraysEvaluation(backURLArrayCount: backURLArray.count, forwarURLArrayCount: forwardURLArray.count, activeTable: currentTableID!)
        
        if sharedPanel!.isVisible == true {
            if sharedPanel!.delegate !== self {
                sharedPanel!.delegate = self
                sharedPanel!.dataSource = self
            }
            
        sharedPanel!.reloadData()
            
         }
        
    }
    
    @objc func tableInFocusDidChange(notification : Notification) {
        let tableIDwhichChanged = notification.userInfo!["postedTableID"] as! String
        
        if tableIDwhichChanged != self.currentTableID && selectedFolderTidiFileArray != nil {
            toolbarController?.delegate = self
            tidiTableView.delegate = self
            delegate?.updateFilter(filterString: "")
            tableSourceDisplayTidiFileArray = selectedFolderTidiFileArray!
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
            clearIsSelected()
            if tidiTableView.selectedRow >= 0  {
            fileDelegate?.fileInFocus(tableSourceDisplayTidiFileArray[tidiTableView.selectedRow], inFocus: true)
            
            for index in tidiTableView.selectedRowIndexes{
                currentlySelectedItems.append((tableSourceDisplayTidiFileArray[index], index))
                tableSourceDisplayTidiFileArray[index].isSelected = true
            }
        }
    }
    
    func filterArray(filterString: String) {
        if filterString == "" {
            if currentSortStringKey != "" {
                tableSourceDisplayTidiFileArray = sortFiles(sortByKeyString: currentSortStringKey, tidiArray: selectedFolderTidiFileArray!)
            } else {
                tableSourceDisplayTidiFileArray = selectedFolderTidiFileArray!
            }
        } else {
            if currentSortStringKey != "" {
              tableSourceDisplayTidiFileArray = sortFiles(sortByKeyString: currentSortStringKey, tidiArray: selectedFolderTidiFileArray!.filter {
                  $0.url?.lastPathComponent.range(of: filterString, options: .caseInsensitive) != nil
              })
            } else {
                tableSourceDisplayTidiFileArray = selectedFolderTidiFileArray!
            }
        }
        
        activeFilterString = filterString
        
        if shouldReloadTableView {
            tidiTableView.reloadData()
            shouldReloadTableView = false
        }
        
    }
    
    override func keyDown(with event: NSEvent) {
        
        switch event.modifierFlags.intersection(NSEvent.modifierFlags) {
        
        /// Check if event chraters are an int.. convert to array, reduce array to an Int
        case [.command] where event.characters?.isInt == true:
            var eventIntArray = [Int]()
            for char in event.characters! {
                eventIntArray.append(Int(String(char))!)
            }
            let eventInt = eventIntArray.reduce(0) { return $0*10 + $1 }
            moveToQuickDrop(quickDropSelectionEvent: eventInt)
            
        case [.command] where event.keyCode == 51:
            moveItemsToTrash()
        default:
            break
        }
        
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
            sharedPanel!.dataSource = self as QLPreviewPanelDataSource
            sharedPanel!.makeKeyAndOrderFront(self)
            }
    }
    

    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return 1
    }

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        let url = currentlySelectedItems.first?.0.url
        return url! as QLPreviewItem
    }
    
    
    func updateTableFolderURL(newURL : URL) {
        self.selectedTableFolderURL = newURL
    }
    
    func isFolder(filePath: String) -> Bool {
        let fileNSURL = NSURL(fileURLWithPath: filePath)
        
        do {
            let itemTypeIdentifier = try fileNSURL.resourceValues(forKeys: [.typeIdentifierKey]).first?.value
            print(itemTypeIdentifier as! String)
            
            if itemTypeIdentifier as! String == String(kUTTypeFolder.self) {
                return true
            } else {
                return false
            }
            
        } catch {
            return false
        }
    }
    
    
    func sortFiles(sortByKeyString : String, tidiArray : [TidiFile]) -> [TidiFile] {
        currentSortStringKey = sortByKeyString
        switch sortByKeyString {
        case "date-created-DESC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $0.createdDateAttribute! > $1.createdDateAttribute!})
            return sortedtidiArrayWithFileAttributes
        case "date-created-ASC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $1.createdDateAttribute! > $0.createdDateAttribute!})
            return sortedtidiArrayWithFileAttributes
        case "date-modified-DESC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $0.createdDateAttribute! > $1.createdDateAttribute!})
            return sortedtidiArrayWithFileAttributes
        case "date-modified-ASC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $1.createdDateAttribute! > $0.createdDateAttribute!})
            return sortedtidiArrayWithFileAttributes
        case "file-size-DESC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $0.fileSizeAttribute! > $1.fileSizeAttribute!})
            return sortedtidiArrayWithFileAttributes
        case "file-size-ASC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $1.fileSizeAttribute! > $0.fileSizeAttribute!})
            return sortedtidiArrayWithFileAttributes
        case "file-name-DESC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { ($0.url?.lastPathComponent.lowercased())! > $1.url!.lastPathComponent.lowercased()})
            return sortedtidiArrayWithFileAttributes
        case "file-name-ASC":
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { ($1.url?.lastPathComponent.lowercased())! > $0.url!.lastPathComponent.lowercased()})
            return sortedtidiArrayWithFileAttributes
        default:
            return tidiArray
        }
    }
    
    //Generic function to get a files attributes from a URL by requested type
    func fileAttributeArray(fileURLArray : [URL]) -> [TidiFile] {
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
        currentlySelectedItems = []
        for tidiFile in self.tableSourceDisplayTidiFileArray {
            if tidiFile.isSelected == true {
                tidiFile.isSelected = false
            }
        }
    }
    
    func contentsOf(folder: URL) -> [URL] {
        let fileManager = FileManager.default
        
        do {
            let folderContents = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return folderContents
        } catch {
            return []
        }
    }
    
    
    // To-do: Move to DirectoryManager
    func openFilePickerToChooseFile() {
        guard let window = NSApplication.shared.mainWindow else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                self.selectedTableFolderURL = panel.urls[0]
                DirectoryManager().allowFolder(urlToAllow: self.selectedTableFolderURL!)
                let mainWindowContainerViewController = self.parent as! MainWindowContainerViewController
                if mainWindowContainerViewController.isOnboarding == true {
                    if self.currentTableID == "SourceTableViewController" {
                        self.storageManager.saveDefaultSourceFolder(self.selectedTableFolderURL)
                        mainWindowContainerViewController.showOnboarding(setAtOnboardingStage: .setDestination)
                        NotificationCenter.default.post(name: NSNotification.Name("defaultSourceFolderDidChangeNotification"), object: nil)
                    } else if self.currentTableID == "DestinationTableViewController" {
                        self.storageManager.saveDefaultDestinationFolder(self.selectedTableFolderURL)
                        mainWindowContainerViewController.showOnboarding(setAtOnboardingStage: .setReminder)
                        NotificationCenter.default.post(name: NSNotification.Name("defaultDestinationFolderDidChangeNotification"), object: nil)
                    }
                }
                self.changeFolderButton.imagePosition = .imageLeft
                self.changeFolderButton.title = "- " + self.selectedTableFolderURL!.lastPathComponent
                self.currentDirectoryURL = panel.urls[0]
            } else if result == NSApplication.ModalResponse.cancel {
                let mainWindowContainerViewController = self.parent as! MainWindowContainerViewController
                if mainWindowContainerViewController.isOnboarding == true {
                    if self.currentTableID == "SourceTableViewController" {
                        mainWindowContainerViewController.showOnboarding(setAtOnboardingStage: .setSource)
                    } else if self.currentTableID == "DestinationTableViewController" {
                        mainWindowContainerViewController.showOnboarding(setAtOnboardingStage: .setDestination)
                    }
                }
            }
        }
        
    }
    
    func moveItemsToTrash() {

        let sortedCurrentlySelectedItems = currentlySelectedItems.sorted(by: { ($0.1 < $1.1) })
        var arrayOfTrashedFiles : [(tidiFile : TidiFile, index : Int)] = []
        
        for tidiFile in sortedCurrentlySelectedItems {
            do {
                try FileManager.default.trashItem(at: tidiFile.0.url!, resultingItemURL: nil)
                arrayOfTrashedFiles.append(tidiFile)
            }
            catch let error as NSError {
                AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "There was an error moving your file to the trash \n\n" + error.localizedDescription, buttonText: "Okay", presentingView: self.view.window!)
                print("Something went wrong: \(error)")
            }
        }
        
        var toReduceIndexBy : Int = 0
        
        for tidiFile in arrayOfTrashedFiles {
            let tidiFileIndex : Int = tidiFile.1 - toReduceIndexBy
            self.tableSourceDisplayTidiFileArray.remove(at: tidiFileIndex)
            
            let indexSet : IndexSet = [tidiFileIndex]
            self.tidiTableView.beginUpdates()
            self.tidiTableView.removeRows(at: indexSet, withAnimation: .slideUp)
            self.tidiTableView.endUpdates()
            toReduceIndexBy = toReduceIndexBy + 1
            
            self.selectedFolderTidiFileArray?.removeAll(where: { (tidiFileToRemove) -> Bool in
                tidiFileToRemove.url == tidiFile.0.url
            })
        }
        
        clearIsSelected()
    }
    

}

extension TidiTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableSourceDisplayTidiFileArray.count
    }
}

extension TidiTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn == tableView.tableColumns[0] {
            let item = tableSourceDisplayTidiFileArray[row].url
            let fileIcon = NSWorkspace.shared.icon(forFile: item!.path)
            fileIcon.size = NSSize(width: 512, height: 512)
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("tidiCellView"), owner: self) as! NSTableCellView
                cell.textField?.stringValue = item!.lastPathComponent
                cell.imageView?.image = fileIcon
                return cell
                
        } else if tableColumn == tableView.tableColumns[1] {
            let item = DateFormatter.localizedString(from: tableSourceDisplayTidiFileArray[row].createdDateAttribute!, dateStyle: .long, timeStyle: .long)
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("tidiCellTextView"), owner: self) as! NSTableCellView
                cell.textField?.stringValue = item
                
                cell.textField?.layout()
                return cell
        } else if tableColumn == tableView.tableColumns[2] {
            let byteFormatter = ByteCountFormatter()
            byteFormatter.countStyle = .binary
            let item = byteFormatter.string(fromByteCount: tableSourceDisplayTidiFileArray[row].fileSizeAttribute!)
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("tidiCellTextView"), owner: self) as! NSTableCellView
            cell.textField?.stringValue = item
            cell.imageView?.isHidden = true
            cell.textField?.layout()
            return cell
        }

        return nil
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let descriptor : NSSortDescriptor = tableView.sortDescriptors.first!
            if descriptor.key == "dateCreateSortKey" && descriptor.ascending == false {
                tableSourceDisplayTidiFileArray = sortFiles(sortByKeyString: "date-created-DESC", tidiArray: tableSourceDisplayTidiFileArray)
            } else if descriptor.key == "dateCreateSortKey" && descriptor.ascending == true {
                tableSourceDisplayTidiFileArray = sortFiles(sortByKeyString: "date-created-ASC", tidiArray: tableSourceDisplayTidiFileArray)
            } else if descriptor.key == "dateModifiedSortKey" && descriptor.ascending == false {
                tableSourceDisplayTidiFileArray = sortFiles(sortByKeyString: "date-modified-DESC", tidiArray: tableSourceDisplayTidiFileArray)
            } else if descriptor.key == "dateModifiedSortKey" && descriptor.ascending == true {
                tableSourceDisplayTidiFileArray = sortFiles(sortByKeyString: "date-modified-ASC", tidiArray: tableSourceDisplayTidiFileArray)
            } else if descriptor.key == "fileNameSortKey" && descriptor.ascending == false {
                tableSourceDisplayTidiFileArray = sortFiles(sortByKeyString: "file-name-DESC", tidiArray: tableSourceDisplayTidiFileArray)
            } else if descriptor.key == "fileNameSortKey" && descriptor.ascending == true {
                tableSourceDisplayTidiFileArray = sortFiles(sortByKeyString: "file-name-ASC", tidiArray: tableSourceDisplayTidiFileArray)
            } else if descriptor.key == "fileSizeSortKey" && descriptor.ascending == false {
                tableSourceDisplayTidiFileArray = sortFiles(sortByKeyString: "file-size-DESC", tidiArray: tableSourceDisplayTidiFileArray)
            } else if descriptor.key == "fileSizeSortKey" && descriptor.ascending == true {
                tableSourceDisplayTidiFileArray = sortFiles(sortByKeyString: "file-size-ASC", tidiArray: tableSourceDisplayTidiFileArray)
            }
        
        tableView.reloadData()
        tidiTableView.scrollRowToVisible(0)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 28
    }
    
    // MARK: DRAGGING FUNCTIONS
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let tidiFileToAdd = tableSourceDisplayTidiFileArray[row]
        return PasteboardWriter(tidiFile: tidiFileToAdd, at: row)
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation)
        -> NSDragOperation {
            print("\(debugInt) \(row) \(currentTableID!) \(tableView.numberOfRows)" )
            
            if row < tableView.numberOfRows && tableView.numberOfRows > 0{
                if isFolder(filePath: tableSourceDisplayTidiFileArray[row].url!.relativePath) {
                    tableView.draggingDestinationFeedbackStyle = .regular
                    tableView.setDropRow(row, dropOperation: .on)
                    return .move
                }
            }
            
            if let source = info.draggingSource as? NSTableView, source !== tableView {
                  tableView.setDropRow(-1, dropOperation: .on)
                  return .move
            }
            debugInt = debugInt + 1
            return[]
    }
    
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {

        let pasteboard = info.draggingPasteboard
        let pasteboardItems = pasteboard.pasteboardItems
        let sourceOfDrop = info.draggingSource as! NSTableView
        let sourceOfDropID = sourceOfDrop.identifier
        let currentTableViewID = tableView.identifier
        
        let tidiFilesToMove = pasteboardItems!.compactMap{ $0.tidiFile(forType: .tidiFile) }

        var moveToURL : URL
        var wasErorMoving = false
        if row == -1 || tableSourceDisplayTidiFileArray.count < 0 {
            moveToURL = self.currentDirectoryURL
        } else {
            // Validation that this is directory happens in  prepare for drop method. If it isn't a directory, row would be set to -1.
            moveToURL = tableSourceDisplayTidiFileArray[row].url!.absoluteURL
        }

        for tidiFile in tidiFilesToMove {
            self.storageManager.moveItem(atURL: tidiFile.url!, toURL: moveToURL) { (Bool, Error) in
                if (Error != nil) {
                    print("Error Moving Files: %s", Error!)
                    AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "There was an error moving some files! \n\n" + Error!.localizedDescription, buttonText: "Okay", presentingView: self.view.window!)
                    wasErorMoving = true
                } else {
                    if sourceOfDropID != currentTableViewID && moveToURL.deletingLastPathComponent() != self.currentDirectoryURL {
                        tidiFile.url = self.selectedTableFolderURL?.appendingPathComponent(tidiFile.url!.lastPathComponent)
                        self.selectedFolderTidiFileArray?.append(tidiFile)
                        
                        if self.tableSourceDisplayTidiFileArray.count > tableView.numberOfRows {
                            self.tableSourceDisplayTidiFileArray = self.sortFiles(sortByKeyString: self.currentSortStringKey, tidiArray: self.tableSourceDisplayTidiFileArray)
                            tableView.beginUpdates()
                            let sortedIndex : IndexSet = IndexSet([self.tableSourceDisplayTidiFileArray.firstIndex(of: tidiFile)!])
                            tableView.insertRows(at: sortedIndex, withAnimation: .slideDown)
                            tableView.endUpdates()
                        }
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
            let sortedCurrentlySelectedItems = currentlySelectedItems.sorted(by: { ($0.1 < $1.1) })
            var toReduceIndexBy : Int = 0
            
            for tidiFile in sortedCurrentlySelectedItems {
                let tidiFileIndex : Int = tidiFile.1 - toReduceIndexBy
                self.tableSourceDisplayTidiFileArray.remove(at: tidiFileIndex)

                let indexSet : IndexSet = [tidiFileIndex]
                self.tidiTableView.beginUpdates()
                self.tidiTableView.removeRows(at: indexSet, withAnimation: .slideUp)
                self.tidiTableView.endUpdates()
                toReduceIndexBy = toReduceIndexBy + 1

                let indexToRemove = self.selectedFolderTidiFileArray?.firstIndex(of: tidiFile.0)
                
                if indexToRemove != nil {
                    self.selectedFolderTidiFileArray?.remove(at: indexToRemove!)
                } else {
                    print("error")
                }
            }
            clearIsSelected()
        }
    }
    
    func debugNavSegment() {
        print("Back Array")
        print(backURLArray)
        print("Forward Array")
        print(forwardURLArray)
    }
    
    func moveToQuickDrop(quickDropSelectionEvent : Int) {
        
        let quickDropSelection = quickDropSelectionEvent - 1
        let quickDropSourceArrayAsStrings = storageManager.getQuickDropArray()
        var quickDropTableSourceURLArray : [URL] = []
        
        if quickDropSelection <= quickDropSourceArrayAsStrings.count - 1 {
            
            for item in quickDropSourceArrayAsStrings {
                let URLString = item
                let url = URL.init(string: URLString)
                quickDropTableSourceURLArray.append(url!)
            }
            
            let sortedCurrentlySelectedItems = currentlySelectedItems.sorted(by: { ($0.1 < $1.1) })
 
            var toReduceIndexBy : Int = 0
            
            for tidiFile in sortedCurrentlySelectedItems {
                        
                self.storageManager.moveItem(atURL: tidiFile.0.url!, toURL: quickDropTableSourceURLArray[quickDropSelection]) { (didMove, Error) in
                    if didMove == true && Error == nil {
                        let tidiFileIndex : Int = tidiFile.1 - toReduceIndexBy
                        self.tableSourceDisplayTidiFileArray.remove(at: tidiFileIndex)
                        self.selectedFolderTidiFileArray?.removeAll(where: { (tidiFileToRemove) -> Bool in
                            tidiFileToRemove.url == tidiFile.0.url
                        })
                        
                        let indexSet : IndexSet = [tidiFileIndex]
                        self.tidiTableView.beginUpdates()
                        self.tidiTableView.removeRows(at: indexSet, withAnimation: .slideUp)
                        self.tidiTableView.endUpdates()
                        toReduceIndexBy = toReduceIndexBy + 1
                    } else {
                         print("Error Moving Files:", Error!)
                        AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "There was an error moving some files! \n\n" + Error!.localizedDescription, buttonText: "Okay", presentingView: self.view.window!)
                    }
                }
                
            }
                
        } else {
            AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "There's no Quick Drop Folder with that number", buttonText: "Okay", presentingView: self.view.window!)
        }
        
    }
}


// MARK: DataHandling
extension TidiTableViewController  {
    
    @objc func changeDefaultLaunchFolder() {
        self.isSourceFolderSet = true
        self.openFilePickerToChooseFile()
    }
    
    @objc func changeDefaultDestinationFolder() {
        self.isDestinationTableFolderSet = true
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
    
    func openInFinderButtonPushed(sender: ToolbarViewController){
        
        let arrayOfURLs = self.currentlySelectedItems.map { $0.0.url }

        NSWorkspace.shared.activateFileViewerSelecting(arrayOfURLs as! [URL])

    }
    
    func filterPerformed(sender: ToolbarViewController) {
        shouldReloadTableView = true
        filterArray(filterString: sender.filterTextField.stringValue)
    }

    func backButtonPushed(sender: ToolbarViewController) {
        let currentURL = selectedTableFolderURL!
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
        let currentURL = selectedTableFolderURL!
        backURLArray.append(currentURL)
        selectedTableFolderURL = forwardURLArray.last
        if forwardURLArray.count > 0 {
            forwardURLArray.removeLast()
        }
        
        delegate?.navigationArraysEvaluation(backURLArrayCount: backURLArray.count, forwarURLArrayCount: forwardURLArray.count, activeTable: currentTableID!)
//        debugNavSegment()
    }

}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
