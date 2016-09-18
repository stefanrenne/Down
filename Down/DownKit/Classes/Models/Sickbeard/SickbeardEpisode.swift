//
//  SickbeardShow.swift
//  Down
//
//  Created by Ruud Puts on 06/09/15.
//  Copyright © 2015 Ruud Puts. All rights reserved.
//

import Foundation
import RealmSwift

public class SickbeardEpisode: Object {
    public dynamic var uniqueId = NSUUID().UUIDString
    public dynamic var id = 0
    public dynamic var name = ""
    public dynamic var airDate: NSDate? = nil
    public dynamic var quality = ""
    public dynamic var status = ""
    public dynamic var plot = ""
    
    public dynamic weak var show: SickbeardShow?
    public dynamic weak var season: SickbeardSeason?
    
    public enum SickbeardEpisodeStatus: String {
        case Archived = "Archived"
        case Unaired = "Unaired"
        case Skipped = "Skipped"
        case Wanted = "Wanted"
        case Snatched = "Snatched"
        case Downloaded = "Downloaded"
    }
    
    // MARK: Realm
    
    public override static func primaryKey() -> String {
        return "uniqueId"
    }
    
    // MARK: Public getters
    
    public var title: String {
        var title = name
        if season != nil && show != nil {
            title = String(format: "%@ - S%02dE%02d - %@", show!.name, season!.id, id, name)
        }
        return title
    }
    
    public var daysUntilAiring: Int {
        let today = NSDate().dateWithoutTime()
        
        if let date = airDate where date >= today {
            let calendar = NSCalendar.currentCalendar()
            return calendar.components(.Day, fromDate: today, toDate: date, options: []).day
        }
        
        return -1
    }
    
}

extension Results where T: SickbeardEpisode {
    
    public func sortOldestFirst() -> RealmSwift.Results<T> {
        return self.sorted([SortDescriptor(property:"airDate", ascending: true), SortDescriptor(property:"id", ascending: true)])
    }
    
    public func sortNewestFirst() -> RealmSwift.Results<T> {
        return self.sorted([SortDescriptor(property:"airDate", ascending: false), SortDescriptor(property:"id", ascending: true)])
    }
    
}