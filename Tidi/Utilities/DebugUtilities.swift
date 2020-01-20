//
//  DebugUtilities.swift
//  Tidi
//
//  Created by Brad Zellman on 1/19/20.
//  Copyright © 2020 Brad Zellman. All rights reserved.
//

import Foundation

class DebugUtilities : NSObject {
    
    func debugNavSegment(backArray : [URL] , forwardArray: [URL] ) {
        print("Back Array")
        print(backArray)
        print("Forward Array")
        print(forwardArray)
    }
}
