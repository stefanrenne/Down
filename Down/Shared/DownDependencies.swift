//
//  DownDependencies.swift
//  Down
//
//  Created by Ruud Puts on 04/11/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import DownKit

class DownDependencies: AllDownDependencies {
    var persistence: ApplicationPersisting
    var viewControllerFactory: ViewControllerProducing!
    var router: Router!

    // DownKit
    var database: DownDatabase

    var apiApplication: ApiApplication!
    var apiInteractorFactory: ApiApplicationInteractorProducing!

    var downloadApplication: DownloadApplication!
    var downloadInteractorFactory: DownloadInteractorProducing!

    var dvrApplication: DvrApplication!
    var dvrInteractorFactory: DvrInteractorProducing!
    var dvrRequestBuilder: DvrRequestBuilding!

    var dmrApplication: DmrApplication!
    var dmrInteractorFactory: DmrInteractorProducing!

    init() {
        persistence = UserDefaults.standard
        database = RealmDatabase.default

        reloadApplication(.download)
        reloadApplication(.dvr)
        reloadApplication(.dmr)
    }

    static func recursiveInit() -> DownDependencies {
        let dependencies = DownDependencies()

        //! Ehm..
        dependencies.viewControllerFactory = ViewControllerFactory(dependencies: dependencies)

        return dependencies
    }

    func reloadApplication(_ type: ApiApplicationType) {
        switch type {
        case .download: downloadApplication = persistence.load(type: .sabnzbd) as? DownloadApplication
        case .dvr: dvrApplication = persistence.load(type: .sabnzbd) as? DvrApplication
        case .dmr: dmrApplication = persistence.load(type: .sabnzbd) as? DmrApplication
        }
    }
}

typealias AllDownDependencies = DownKitDependencies
    & ApplicationPersistenceDependency
    & ViewControllerFactoryDependency
    & RouterDependency

protocol ApplicationPersistenceDependency {
    var persistence: ApplicationPersisting { get }
}

protocol ViewControllerFactoryDependency {
    var viewControllerFactory: ViewControllerProducing! { get }
}

protocol RouterDependency {
    var router: Router! { get set }
}
