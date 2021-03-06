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
    var welcomeMessage = "Welcome to Down!\n\nTo get started configure your downloader and indexers below"

    let datasource: [SettingsSectionModel] = [
        SettingsSectionModel(applicationType: .download, applications: [.sabnzbd]),
        SettingsSectionModel(applicationType: .dvr, applications: [.sickbeard, .sickgear]),
        SettingsSectionModel(applicationType: .dmr, applications: [.couchpotato]),
    ]

    init(showWelcomeMessage: Bool) {
        self.showWelcomeMessage = showWelcomeMessage
    }

    func title(for type: ApiApplicationType) -> String {
        switch type {
        case .download: return "Downloaders"
        case .dvr: return "TV Show indexers"
        case .dmr: return "Movie indexers"
        }
    }

    func icon(for type: ApiApplicationType) -> UIImage? {
        return nil
//        return AssetProvider.icons.for(type)
    }
}
