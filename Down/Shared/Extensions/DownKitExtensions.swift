//
//  DownKitExtensions.swift
//  Down
//
//  Created by Ruud Puts on 08/09/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import DownKit

extension Quality {
    var displayString: String {
        switch self {
        case .hd1080p: return "1080P"
        case .hd720p: return "720P"
        case .hdtv: return "HD TV"
        case .unkown: return ""
        }
    }
}

extension DvrShow.Status {
    var displayString: String {
        switch self {
        case .continuing: return "Continuing"
        case .ended: return "Ended"
        case .unkown: return ""
        }
    }
}