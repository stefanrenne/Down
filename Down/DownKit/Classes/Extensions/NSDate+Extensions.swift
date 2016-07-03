//
//  NSDate+Extensions.swift
//  Down
//
//  Created by Ruud Puts on 22/06/16.
//  Copyright © 2016 Ruud Puts. All rights reserved.
//

import Foundation

public extension NSDate {
    
    func dateWithoutTime() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        return calendar.dateFromComponents(components)!
    }
    
}