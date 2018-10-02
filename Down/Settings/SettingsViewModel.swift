//
//  SettingsViewModel.swift
//  Down
//
//  Created by Ruud Puts on 02/10/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import DownKit

class SettingsViewModel {
    var title: String {
        return showWelcomeMessage ? "Down" : "Settings"
    }
    var showWelcomeMessage: Bool
    var welcomeMessage = "Welcome to Down!\n\nTo get started configure your downoader and indexers below"

    let datasource: [ApiApplicationType: [DownApplicationType]] = [
        .download: [ .sabnzbd ],
        .dvr: [ .sickbeard ],
        .dmr: [ .couchpotato ],
    ]

    init(showWelcomeMessage: Bool) {
        self.showWelcomeMessage = showWelcomeMessage
    }

    func title(for type: ApiApplicationType) -> String {
        switch type {
        case .download: return "Downloaders"
        case .dvr: return "Movie indexers"
        case .dmr: return "TV Show indexers"
        }
    }
}
