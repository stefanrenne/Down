//
//  String+Extensions.swift
//  Down
//
//  Created by Ruud Puts on 15/03/15.
//  Copyright (c) 2015 Ruud Puts. All rights reserved.
//

import Foundation

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var length: Int {
        return self.utf16.count
    }
    
    var fullNSRange: NSRange {
        return NSRange(location: 0, length: self.length)
    }
    
    var fullRange: Range<String.Index> {
        return self.startIndex..<self.endIndex
    }
    
    func toFloat() -> Float? {
        return floatValue
    }
    
    init(var fromMB size: Float) {
        var sizeDisplay = "MB"
        if (size < 0) {
            size = size * 1024
            sizeDisplay = "KB"
        }
        else if (size > 1024) {
            size = size / 1024
            sizeDisplay = "GB"
        }
        
        if (size > 0) {
            self = String(format: "%.1f%@", size, sizeDisplay)
        }
        else {
            self = String(format: "%.0f%@", size, sizeDisplay)
        }
    }
}