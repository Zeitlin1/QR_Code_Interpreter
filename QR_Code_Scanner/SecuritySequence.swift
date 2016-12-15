//
//  SecuritySequence.swift
//  QR_Code_Scanner
//
//  Created by Anthony on 12/13/16.
//  Copyright © 2016 Anthony. All rights reserved.
//

import Foundation

struct SecuritySequence {
    
    var scanSequence = [Int: String]()
    
    var publicArray = [Int: String]()
    
    var count: Int {
        return scanSequence.count
    }
    
   // var bloomArray = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    mutating func removeAt(index: Int) {
        if !publicArray.isEmpty {
        publicArray.removeValue(forKey: index)
        }
    }
    
    mutating func addOn(val: String, num: Int) {
        if publicArray.count < scanSequenceDepth {
        scanSequence.updateValue(val, forKey: num)
        publicArray.updateValue(val, forKey: num)
        }
    }
}
