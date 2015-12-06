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
    public dynamic var id = ""
    public dynamic var name = ""
    public dynamic var airDate = ""
    public dynamic var quality = ""
    public dynamic var status = ""
    public dynamic var filename = ""
    
    public dynamic weak var show: SickbeardShow?
    public dynamic weak var season: SickbeardSeason?
    
    // MARK: Warning: set uniqueId before storing
    
//    public convenience init(id: String, season: SickbeardSeason, show: SickbeardShow) {
//        self.init()
//        
//        self.id = id
//        self.show = show
//        self.season = season
//        uniqueId = "\(show.tvdbId)-\(season.id)-\(id)"//objectHash = NSUUID().UUIDString
//    }
    
    // MARK: Realm
    
    public override static func primaryKey() -> String {
        return "uniqueId"
    }
    
    // MARK: Public getters
    
//    public var displayName: String {
//        var displayName = name
////        if season != nil && show != nil {
////            displayName = "\(show!.name) - S\(season!.id)E\(id) - \(name)"
////        }
//        return displayName
//    }
    
}