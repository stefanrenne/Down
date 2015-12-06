//
//  DatabaseManager.swift
//  Down
//
//  Created by Ruud Puts on 23/09/15.
//  Copyright © 2015 Ruud Puts. All rights reserved.
//

import Foundation
import RealmSwift

public class DatabaseManager {
    
    let _adapter: DatabaseAdapter
    
    class var databasePath: String {
        let sickbeardDirectory = "\(UIApplication.documentsDirectory)/sickbeard"
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(sickbeardDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            print("Error while creating databasePath: \(error)")
        }
        return sickbeardDirectory + "/sickbeard.realm"
    }
    
    class var databaseExists: Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(databasePath)
    }
    
    public init() {
        _adapter = DatabaseV1Adapter()
    }
    
    var adapter: DatabaseV1Adapter {
        return _adapter as! DatabaseV1Adapter
    }
    
    // MARK: Sickbeard
    
    public func storeSickbeardShows(shows: [String: SickbeardShow]) {
        self.adapter.storeSickbeardShows(Array(shows.values))
    }
    
//    public func storeSickbeardSeasons(seasons: List<SickbeardSeason>, forShow show: SickbeardShow) {
//        self.adapter.storeSickbeardSeasons(seasons, forShow:show)
//    }
//    
//    public func storeSickbeardEpisodes(episodes: [SickbeardEpisode]) {
//        self.adapter.storeSickbeardEpisodes(episodes)
//    }
    
    public func fetchAllSickbeardShows() -> [String: SickbeardShow] {
        var shows = [String: SickbeardShow]()
        for show in self.adapter.allSickbeardShows() {
            shows[show.tvdbId] = show
        }
        
        return shows
    }
    
}