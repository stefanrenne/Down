//
//  DvrEpisode.swift
//  DownKit
//
//  Created by Ruud Puts on 21/06/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import RealmSwift

public class DvrEpisode: Object {
    @objc dynamic var key = UUID().uuidString
    @objc public dynamic var identifier = ""
    @objc public dynamic var name = ""
    @objc public dynamic var airdate: Date?
    @objc public dynamic var quality = Quality.unknown
    @objc public dynamic var status = DvrEpisodeStatus.unknown
    
    @objc public dynamic var show: DvrShow!
    @objc public dynamic var season: DvrSeason!
    
    public convenience init(identifier: String, name: String, airdate: Date?,
                            quality: Quality = .unknown, status: DvrEpisodeStatus = .unknown) {
        self.init()
        self.identifier = identifier
        self.name = name
        self.airdate = airdate
        self.quality = quality
        self.status = status
    }
    
    override public static func primaryKey() -> String? {
        return "key"
    }
}

@objc
public enum DvrEpisodeStatus: Int {
    case unknown
    case wanted
    case skipped
    case archived
    case ignored
    case snatched
    case downloaded
}
