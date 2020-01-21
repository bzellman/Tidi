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
import FileWatcher_macOS

protocol TidiTableViewDelegate: AnyObject {
    func navigationArraysEvaluation(backURLArrayCount : Int, forwarURLArrayCount : Int, activeTable : String)
    
    func updateFilter(filterString : String)
}

protocol TidiTableViewFileUpdate: AnyObject {
    func fileInFocus(_ tidiFile: TidiFile, inFocus: Bool)
}


enum sortStyleKey {
    case dateCreatedDESC
    case dateCreatedASC
    case dateModifiedDESC
    case dateModifiedASC
    case fileSizeDESC
    case fileSizeASC
    case fileNameDESC
    case fileNameASC
}

class TidiTableViewController: NSViewController, QLPreviewPanelDataSource, QLPreviewPanelDelegate, AddDirectoryPopoverViewControllerDelegate   {
    
    // MARK: Properties
    /// IBOutlets set from subclasses for each table
    let storageManager = StorageManager()
    let sharedPanel = QLPreviewPanel.shared()
    
    var sourceFileURLArray : [URL] = []
    var showInvisibles = false
    var tidiTableView : NSTableView?
    
    var isSourceFolderSet = false
    var isDestinationTableFolderSet = false
    
    var currentDirectoryURL : URL = URL.init(fileURLWithPath: " ")
    var destinationDirectoryURL : URL = URL.init(fileURLWithPath: " ")
 
    var backURLArray : [URL] = []
    var forwardURLArray : [URL] = []
    
    var isBackButtonEnabled : Bool = false
    var isForwardButtonEnabled : Bool = false
    
    var currentlySelectedItems : [(TidiFile, Int)] = []
    
    var currentSortStyleKey : sortStyleKey?
    
    var changeFolderButton : NSButton = NSButton.init()
    
    var activeFilterString : String = ""
    var shouldReloadTableView : Bool = false
    var shouldLoadTableProperties : Bool = false
    
    var currentTableID : String?
    var currentTableName : String?
    var debugInt : Int = 0
    
    var addDirectoryDelegate : AddDirectoryPopoverViewControllerDelegate?
    var addDirectoryPopoverViewController : AddDirectoryPopoverViewController?
    
    var directoryManager : DirectoryManager = DirectoryManager()
    var tidiFileArrayController : TidiFileArrayController = TidiFileArrayController()
    
    weak var delegate: TidiTableViewDelegate?
    weak var fileDelegate : TidiTableViewFileUpdate?
    
    
    
    //MARK: TidiTableViewController Operation and Base Methods
    var selectedTableFolderURL: URL? {
        didSet {
            if let selectedTableFolderURL = selectedTableFolderURL {
                
                sourceFileURLArray = directoryManager.contentsOf(folder: selectedTableFolderURL)
                let unsortedFileWithAttributeArray = tidiFileArrayController.fileAttributeArray(fileURLArray: sourceFileURLArray)
                selectedFolderTidiFileArray = tidiFileArrayController.sortFiles(sortByType: currentSortStyleKey ?? .dateCreatedDESC, tidiArray: unsortedFileWithAttributeArray)
                tidiTableView!.reloadData()
                tidiTableView!.scrollRowToVisible(0)
                self.changeFolderButton.imagePosition = .imageLeft
                self.changeFolderButton.title = "- " + self.selectedTableFolderURL!.lastPathComponent
                startFileWatcherForURL(url: selectedTableFolderURL)
            } else {
                AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "There's no folder set for your \(currentTableName ?? "Default Tidi Folder"). \n\nPlease set a folder", buttonText: "Ok", presentingView: self.view.window!)
                print("No File Set")
            }
            
        }
    }
    
    var selectedFolderTidiFileArray : [TidiFile]? {
        didSet {
            tableSourceDisplayTidiFileArray = tidiFileArrayController.filterArray(unfilteredArray: selectedFolderTidiFileArray!, filterString: activeFilterString, sortByType: currentSortStyleKey ?? .dateCreatedDESC)
        }
    }
    
    var tableSourceDisplayTidiFileArray : [TidiFile]? {
        
        willSet {
            if self.tableSourceDisplayTidiFileArray == nil {
                shouldLoadTableProperties = true
            }
        }
        
        didSet {
            if shouldLoadTableProperties {
                setTableProperties()
                shouldLoadTableProperties = false
            }
            if shouldReloadTableView {
                tidiTableView!.reloadData()
                shouldReloadTableView = false
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
        
        DirectoryManager().loadBookmarks()
        currentSortStyleKey = .dateCreatedDESC
        shouldReloadTableView = true
    }
    
    func setTableProperties() {
        
        tidiTableView!.delegate = self
        tidiTableView!.dataSource = self
         
         currentSortStyleKey = .dateCreatedDESC
         NotificationCenter.default.addObserver(self, selector: #selector(self.tableInFocusDidChange), name: NSNotification.Name("tableInFocusDidChangeNotification"), object: nil)
         
         tidiTableView!.registerForDraggedTypes([.fileURL, .tableViewIndex, .tidiFile])
         tidiTableView!.setDraggingSourceOperationMask(.move, forLocal: false)
         tidiTableView!.allowsMultipleSelection = true
         tidiTableView!.usesAlternatingRowBackgroundColors = true
         
         tidiTableView!.tableColumns[0].headerCell.stringValue = "File Name"
         tidiTableView!.tableColumns[1].headerCell.stringValue = "Date Created"
         tidiTableView!.tableColumns[2].headerCell.stringValue = "File Size"

         shouldReloadTableView = true
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "sourceAddDirectorySegue" {
            addDirectoryPopoverViewController = segue.destinationController as? AddDirectoryPopoverViewController
        } else if segue.identifier == "destinationAddDirectorySegue" {
            addDirectoryPopoverViewController = segue.destinationController as? AddDirectoryPopoverViewController
        }
        
        addDirectoryPopoverViewController?.delegate = self
    }
        

    @IBAction func rowDoubleClicked(_ sender: Any) {
        if tidiTableView!.selectedRow < 0 { return }
        let selectedItem = tableSourceDisplayTidiFileArray![tidiTableView!.selectedRow]
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
        tidiTableView!.delegate = self
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
            tidiTableView!.delegate = self
            delegate?.updateFilter(filterString: activeFilterString)
        }
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
            clearIsSelected()
            if tidiTableView!.selectedRow >= 0  {
                fileDelegate?.fileInFocus(tableSourceDisplayTidiFileArray![tidiTableView!.selectedRow], inFocus: true)
            
            for index in tidiTableView!.selectedRowIndexes{
                currentlySelectedItems.append((tableSourceDisplayTidiFileArray![index], index))
                tableSourceDisplayTidiFileArray![index].isSelected = true
            }
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
        print(currentlySelectedItems)
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
    
    func clearIsSelected() {
        currentlySelectedItems = []
        for tidiFile in self.tableSourceDisplayTidiFileArray! {
            if tidiFile.isSelected == true {
                tidiFile.isSelected = false
            }
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
            self.tableSourceDisplayTidiFileArray!.remove(at: tidiFileIndex)
            removeItemFromTidiTableView(indexSet: [tidiFileIndex])
            toReduceIndexBy = toReduceIndexBy + 1
            
            self.selectedFolderTidiFileArray?.removeAll(where: { (tidiFileToRemove) -> Bool in
                tidiFileToRemove.url == tidiFile.0.url
            })
        }
        
        clearIsSelected()
    }
    
    func createNewDirectory(newDirectoryNameString: String) {
        let directoryManager = DirectoryManager()
        let urlOfNewDirectory : URL = (self.selectedTableFolderURL?.appendingPathComponent(newDirectoryNameString))!

        if directoryManager.fileExists(url: urlOfNewDirectory) == false {
            if directoryManager.createDirectory(url: urlOfNewDirectory) {
//                if tidiFileArrayController.fileAttributeArray(fileURLArray: [urlOfNewDirectory]).count == 1 {
                    let tidiFileToAdd : TidiFile = tidiFileArrayController.fileAttributeArray(fileURLArray: [urlOfNewDirectory]).first!
                    self.selectedFolderTidiFileArray?.append(tidiFileToAdd)
                    self.checkForUpdateTableAndUpdateIfNeeded(tidiFile: tidiFileToAdd)
//                }
            }
        } else {
            AlertManager().showPopUpAlertWithOnlyDismissButton(messageText: "It looks like that folder already exists", informativeText: "Please create a folder with unique name", buttonText: "Okay")
        }
    }
    
    func startFileWatcherForURL(url : URL) {
        
        let filewatcher = FileWatcher([url.relativePath])
        filewatcher.callback = { event in
            
            let eventURL : URL = URL(fileURLWithPath: event.path)
            let parentDirectoryofEventURL : URL = eventURL.deletingLastPathComponent()
            
            /// Ensure No Hidden Files such as a DS Store which are not displated in the table trigger a table modification
            if eventURL.lastPathComponent.prefix(1) != "." && event.description.hasSuffix("was") == false {
                if url.relativePath == parentDirectoryofEventURL.relativePath {
                    if self.directoryManager.contentsOf(folder: url).count > self.sourceFileURLArray.count {
                        self.addNewTidiFile(urlOfNewItem: eventURL)
                    } else if self.directoryManager.contentsOf(folder: url).count < self.sourceFileURLArray.count {
                        self.itemRemovedDetected(urlOfRemovedItem: eventURL)
                    }
                }
            }
        }
        filewatcher.start()
    }
    
    func addNewTidiFile(urlOfNewItem : URL) {
            let tidiFileToAdd : TidiFile = tidiFileArrayController.fileAttributeArray(fileURLArray: [urlOfNewItem]).first!
            self.selectedFolderTidiFileArray?.append(tidiFileToAdd)
            self.checkForUpdateTableAndUpdateIfNeeded(tidiFile: tidiFileToAdd)
    }
    
    func itemRemovedDetected(urlOfRemovedItem : URL) {
        self.selectedFolderTidiFileArray?.removeAll(where: { (tidiFile) -> Bool in
            tidiFile.url == urlOfRemovedItem
        })
    }
    
    func checkForUpdateTableAndUpdateIfNeeded(tidiFile : TidiFile) {
        if self.tableSourceDisplayTidiFileArray!.count > self.tidiTableView!.numberOfRows {
            self.tidiTableView!.beginUpdates()
            let sortedIndex : IndexSet = IndexSet([self.tableSourceDisplayTidiFileArray!.firstIndex(of: tidiFile)!])
            self.tidiTableView!.insertRows(at: sortedIndex, withAnimation: .slideDown)
            self.tidiTableView!.endUpdates()
        }
    }
    
    func removeItemFromTidiTableView(indexSet : IndexSet) {
        self.tidiTableView!.beginUpdates()
        self.tidiTableView!.removeRows(at: indexSet, withAnimation: .slideUp)
        self.tidiTableView!.endUpdates()
    }
}

extension TidiTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableSourceDisplayTidiFileArray!.count
    }
}

extension TidiTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn == tableView.tableColumns[0] {
            let item = tableSourceDisplayTidiFileArray![row].url
            let fileIcon = NSWorkspace.shared.icon(forFile: item!.path)
            fileIcon.size = NSSize(width: 512, height: 512)
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("tidiCellView"), owner: self) as! NSTableCellView
                cell.textField?.stringValue = item!.lastPathComponent
                cell.imageView?.image = fileIcon
                return cell
                
        } else if tableColumn == tableView.tableColumns[1] {
            let item = DateFormatter.localizedString(from: tableSourceDisplayTidiFileArray![row].createdDateAttribute!, dateStyle: .long, timeStyle: .long)
            
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("tidiCellTextView"), owner: self) as! NSTableCellView
                cell.textField?.stringValue = item
                
                cell.textField?.layout()
                return cell
        } else if tableColumn == tableView.tableColumns[2] {
            let byteFormatter = ByteCountFormatter()
            byteFormatter.countStyle = .binary
            let item = byteFormatter.string(fromByteCount: tableSourceDisplayTidiFileArray![row].fileSizeAttribute!)
            
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
                tableSourceDisplayTidiFileArray = tidiFileArrayController.sortFiles(sortByType: .dateCreatedDESC, tidiArray: selectedFolderTidiFileArray!)
                currentSortStyleKey = .dateCreatedDESC
            } else if descriptor.key == "dateCreateSortKey" && descriptor.ascending == true {
               tableSourceDisplayTidiFileArray = tidiFileArrayController.sortFiles(sortByType: .dateCreatedASC, tidiArray: selectedFolderTidiFileArray!)
                currentSortStyleKey = .dateCreatedASC
            } else if descriptor.key == "dateModifiedSortKey" && descriptor.ascending == false {
                tableSourceDisplayTidiFileArray = tidiFileArrayController.sortFiles(sortByType: .dateModifiedDESC, tidiArray: selectedFolderTidiFileArray!)
                currentSortStyleKey = .dateModifiedDESC
            } else if descriptor.key == "dateModifiedSortKey" && descriptor.ascending == true {
                tableSourceDisplayTidiFileArray = tidiFileArrayController.sortFiles(sortByType: .dateModifiedASC, tidiArray: selectedFolderTidiFileArray!)
                currentSortStyleKey = .dateModifiedASC
            } else if descriptor.key == "fileNameSortKey" && descriptor.ascending == false {
                tableSourceDisplayTidiFileArray = tidiFileArrayController.sortFiles(sortByType: .fileNameDESC, tidiArray: selectedFolderTidiFileArray!)
                currentSortStyleKey = .fileNameDESC
            } else if descriptor.key == "fileNameSortKey" && descriptor.ascending == true {
                tableSourceDisplayTidiFileArray = tidiFileArrayController.sortFiles(sortByType: .fileNameASC, tidiArray: selectedFolderTidiFileArray!)
                currentSortStyleKey = .fileNameASC
            } else if descriptor.key == "fileSizeSortKey" && descriptor.ascending == false {
                tableSourceDisplayTidiFileArray = tidiFileArrayController.sortFiles(sortByType: .fileSizeDESC, tidiArray: selectedFolderTidiFileArray!)
                currentSortStyleKey = .fileSizeDESC
            } else if descriptor.key == "fileSizeSortKey" && descriptor.ascending == true {
                tableSourceDisplayTidiFileArray = tidiFileArrayController.sortFiles(sortByType: .fileSizeASC, tidiArray: selectedFolderTidiFileArray!)
                currentSortStyleKey = .fileSizeASC
            }
        
        tidiTableView!.reloadData()
        tidiTableView!.scrollRowToVisible(0)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 28
    }
    
    // MARK: Pasteboard Dragging Methods
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let tidiFileToAdd = tableSourceDisplayTidiFileArray![row]
        return PasteboardWriter(tidiFile: tidiFileToAdd, at: row)
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation)
        -> NSDragOperation {
            
            if row < tableView.numberOfRows && tableView.numberOfRows > 0{
                if directoryManager.isFolder(filePath: self.tableSourceDisplayTidiFileArray![row].url!.relativePath) {
                    tableView.draggingDestinationFeedbackStyle = .regular
                    tableView.setDropRow(row, dropOperation: .on)
                    return .move
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
          let sourceOfDrop = info.draggingSource as! NSTableView
          let sourceOfDropID = sourceOfDrop.identifier
          let currentTableViewID = tableView.identifier
          
          let tidiFilesToMove = pasteboardItems!.compactMap{ $0.tidiFile(forType: .tidiFile) }

          var moveToURL : URL
          var wasErorMoving = false
          if row == -1 || self.tableSourceDisplayTidiFileArray!.count < 0 {
            moveToURL = self.currentDirectoryURL
          } else {
              /// Validation that this is directory happens in  prepare for drop method. If it isn't a directory, row would be set to -1.
            moveToURL = self.tableSourceDisplayTidiFileArray![row].url!.absoluteURL
          }

          for tidiFile in tidiFilesToMove {
              self.storageManager.moveItem(atURL: tidiFile.url!, toURL: moveToURL) { (Bool, Error) in
                  if (Error != nil) {
                      print("Error Moving Files: %s", Error!)
                      AlertManager().showSheetAlertWithOnlyDismissButton(messageText: "There was an error moving some files! \n\n" + Error!.localizedDescription, buttonText: "Okay", presentingView: self.view.window!)
                      wasErorMoving = true
                    
                  }
//                  else {
//                      if sourceOfDropID != currentTableViewID && moveToURL.deletingLastPathComponent() != self.currentDirectoryURL {
//                        tidiFile.url = self.selectedTableFolderURL?.appendingPathComponent(tidiFile.url!.lastPathComponent)
//                        self.selectedFolderTidiFileArray?.append(tidiFile)
//                        self.checkForUpdateTableAndUpdateIfNeeded(tidiFile: tidiFile)
//                    }
//                  }
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
                self.tableSourceDisplayTidiFileArray!.remove(at: tidiFileIndex)
                removeItemFromTidiTableView(indexSet: [tidiFileIndex])
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
                        self.tableSourceDisplayTidiFileArray!.remove(at: tidiFileIndex)
                        self.selectedFolderTidiFileArray?.removeAll(where: { (tidiFileToRemove) -> Bool in
                            tidiFileToRemove.url == tidiFile.0.url
                        })
                        
                        let indexSet : IndexSet = [tidiFileIndex]
                        self.tidiTableView!.beginUpdates()
                        self.tidiTableView!.removeRows(at: indexSet, withAnimation: .slideUp)
                        self.tidiTableView!.endUpdates()
                        toReduceIndexBy = toReduceIndexBy + 1
                    } else {
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
        tableSourceDisplayTidiFileArray = tidiFileArrayController.filterArray(unfilteredArray: selectedFolderTidiFileArray!, filterString: sender.filterTextField.stringValue, sortByType: currentSortStyleKey ?? .dateCreatedDESC)
        activeFilterString = sender.filterTextField.stringValue
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
//        DebugUtilities().debugNavSegment(backArray: backURLArray, forwardArray: forwardURLArray)
    }
    
    func forwardButtonPushed(sender: ToolbarViewController) {
        let currentURL = selectedTableFolderURL!
        backURLArray.append(currentURL)
        selectedTableFolderURL = forwardURLArray.last
        if forwardURLArray.count > 0 {
            forwardURLArray.removeLast()
        }
        
        delegate?.navigationArraysEvaluation(backURLArrayCount: backURLArray.count, forwarURLArrayCount: forwardURLArray.count, activeTable: currentTableID!)
//         DebugUtilities().debugNavSegment(backArray: backURLArray, forwardArray: forwardURLArray)
        
    }

}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
