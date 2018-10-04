//
//  DvrInteractorFactory.swift
//  DownKit
//
//  Created by Ruud Puts on 17/06/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

public protocol DvrInteractorProducing {
    func makeShowListInteractor(for application: DvrApplication) -> DvrShowListInteractor
    func makeShowDetailsInteractor(for application: DvrApplication, show: DvrShow) -> DvrShowDetailsInteractor
    func makeShowCacheRefreshInteractor(for application: DvrApplication) -> DvrRefreshShowCacheInteractor
    func makeSearchShowsInteractor(for application: DvrApplication, query: String) -> DvrSearchShowsInteractor
    func makeAddShowInteractor(for application: DvrApplication, show: DvrShow) -> DvrAddShowInteractor
    func makeShowBannerInteractor(for application: DvrApplication, show: DvrShow) -> DvrShowBannerInteractor
    func makeShowPosterInteractor(for application: DvrApplication, show: DvrShow) -> DvrShowPosterInteractor
}

public class DvrInteractorFactory: DvrInteractorProducing {
    var database: DvrDatabase
    var gatewayFactory: DvrGatewayProducing
    
    public init(database: DvrDatabase, gatewayFactory: DvrGatewayProducing = DvrGatewayFactory()) {
        self.gatewayFactory = gatewayFactory
        self.database = database
    }
    
    public func makeShowListInteractor(for application: DvrApplication) -> DvrShowListInteractor {
        let gateway = gatewayFactory.makeShowListGateway(for: application)
        
        return DvrShowListInteractor(gateway: gateway)
    }
    
    public func makeShowDetailsInteractor(for application: DvrApplication, show: DvrShow) -> DvrShowDetailsInteractor {
        let gateway = gatewayFactory.makeShowDetailsGateway(for: application, show: show)
        
        return DvrShowDetailsInteractor(gateway: gateway)
    }
    
    public func makeShowCacheRefreshInteractor(for application: DvrApplication) -> DvrRefreshShowCacheInteractor {
        return DvrRefreshShowCacheInteractor(application: application, interactors: self, database: database)
    }

    public func makeSearchShowsInteractor(for application: DvrApplication, query: String) -> DvrSearchShowsInteractor {
        let gateway = gatewayFactory.makeSearchShowsGateway(for: application, query: query)

        return DvrSearchShowsInteractor(gateway: gateway)
    }

    public func makeAddShowInteractor(for application: DvrApplication, show: DvrShow) -> DvrAddShowInteractor {
        let gateway = gatewayFactory.makeAddShowGateway(for: application, show: show)
        let showDetailsInteractor = makeShowDetailsInteractor(for: application, show: show)
        let interactors = (addShow: gateway, showDetails: showDetailsInteractor)

        return DvrAddShowInteractor(interactors: interactors, database: database)
    }

    public func makeShowBannerInteractor(for application: DvrApplication, show: DvrShow) -> DvrShowBannerInteractor {
        let gateway = gatewayFactory.makeFetchBannerGateway(for: application, show: show)

        return DvrShowBannerInteractor(gateway: gateway, show: show)
    }

    public func makeShowPosterInteractor(for application: DvrApplication, show: DvrShow) -> DvrShowPosterInteractor {
        let gateway = gatewayFactory.makeFetchPosterGateway(for: application, show: show)

        return DvrShowPosterInteractor(gateway: gateway, show: show)
    }
}
