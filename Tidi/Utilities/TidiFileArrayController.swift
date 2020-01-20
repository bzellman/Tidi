//
//  TidiFileArrayController.swift
//  Tidi
//
//  Created by Brad Zellman on 1/20/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Foundation

class TidiFileArrayController : NSObject {
    
    var activeFilterString = ""
    
    func sortFiles(sortByType : sortStyleKey, tidiArray : [TidiFile]) -> [TidiFile] {
//        currentSortStringKey = sortByKeyString
        switch sortByType {
        case .dateCreatedDESC:
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $0.createdDateAttribute! > $1.createdDateAttribute!})
            return sortedtidiArrayWithFileAttributes
        case .dateCreatedASC:
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $1.createdDateAttribute! > $0.createdDateAttribute!})
            return sortedtidiArrayWithFileAttributes
        case .dateModifiedDESC:
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $0.createdDateAttribute! > $1.createdDateAttribute!})
            return sortedtidiArrayWithFileAttributes
        case .dateModifiedASC:
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $1.createdDateAttribute! > $0.createdDateAttribute!})
            return sortedtidiArrayWithFileAttributes
        case .fileSizeDESC:
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $0.fileSizeAttribute! > $1.fileSizeAttribute!})
            return sortedtidiArrayWithFileAttributes
        case .fileSizeASC:
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { $1.fileSizeAttribute! > $0.fileSizeAttribute!})
            return sortedtidiArrayWithFileAttributes
        case .fileNameDESC:
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { ($0.url?.lastPathComponent.lowercased())! > $1.url!.lastPathComponent.lowercased()})
            return sortedtidiArrayWithFileAttributes
        case .fileNameASC:
            let sortedtidiArrayWithFileAttributes = tidiArray.sorted(by: { ($1.url?.lastPathComponent.lowercased())! > $0.url!.lastPathComponent.lowercased()})
            return sortedtidiArrayWithFileAttributes
        }
    }
    
    func filterArray(unfilteredArray : [TidiFile], filterString : String, sortByType : sortStyleKey) -> [TidiFile] {
        var tableSourceDisplayTidiFileArray : [TidiFile] = []
        if filterString == "" {
                tableSourceDisplayTidiFileArray = sortFiles(sortByType: sortByType, tidiArray: unfilteredArray)
        } else {
            tableSourceDisplayTidiFileArray = sortFiles(sortByType: sortByType, tidiArray: unfilteredArray.filter {
                  $0.url?.lastPathComponent.range(of: filterString, options: .caseInsensitive) != nil
              })
        }
        
        activeFilterString = filterString
        
        return tableSourceDisplayTidiFileArray
        
    }
    
}