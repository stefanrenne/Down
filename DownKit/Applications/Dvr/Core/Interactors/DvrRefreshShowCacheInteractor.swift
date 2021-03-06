//
//  DvrRefreshShowCacheInteractor.swift
//  DownKit
//
//  Created by Ruud Puts on 18/06/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import RxSwift

public class DvrRefreshShowCacheInteractor: CompoundInteractor, ObservableInteractor {
    public typealias Interactors = DvrInteractorProducing
    public var interactors: Interactors
    
    public typealias Element = DvrShowListInteractor.Element

    var application: DvrApplication!
    var database: DvrDatabase!
    
    public required init(interactors: Interactors) {
        self.interactors = interactors
    }
    
    convenience init(application: DvrApplication, interactors: Interactors, database: DvrDatabase) {
        self.init(interactors: interactors)
        self.application = application
        self.database = database
    }
    
    public func observe() -> Single<[DvrShow]> {
        return interactors
            .makeShowListInteractor(for: application)
            .observe()
            .flatMap { self.processDeletedShows($0) }
            .flatMap { self.determineShowsToRefresh($0) }
            .flatMap { self.refreshShowDetails($0) }
    }

    func processDeletedShows(_ shows: [DvrShow]) -> Single<[DvrShow]> {
        return Observable.zip([Observable.just(shows), database.fetchShows()])
            .map {
                guard let fetchedShows = $0.first, let storedShows = $0.last,
                      fetchedShows != storedShows else {
                    return shows
                }

                let fetchedShowIdentifiers = fetchedShows.map { $0.identifier }

                storedShows
                    .filter { fetchedShowIdentifiers.index(of: $0.identifier) == nil }
                    .forEach { self.database.delete(show: $0) }

                return shows
            }
            .asSingle()
    }

    func determineShowsToRefresh(_ shows: [DvrShow]) -> Single<[DvrShow]> {
        return Observable.zip([Observable.just(shows), database.fetchShows()])
            .map {
                guard let fetchedShows = $0.first, let storedShows = $0.last else {
                    return shows
                }

                let storedShowsIdentifiers = storedShows.map { $0.identifier }
                let newShows = fetchedShows.filter {
                    storedShowsIdentifiers.index(of: $0.identifier) == nil
                }

                let showsToRefresh = storedShows.filter {
                    !$0.episodeAired(since: Date().addingTimeInterval(-604800)).isEmpty
                }

                return newShows + showsToRefresh
            }
            .asSingle()
    }

    func refreshShowDetails(_ shows: [DvrShow]) -> Single<[DvrShow]> {
        let observables = shows.map {
            self.interactors
                .makeShowDetailsInteractor(for: self.application, show: $0)
                .observe()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .do(onSuccess: {
                    $0.store(in: self.database)
                })
            }

        return Single.zip(observables).observeOn(MainScheduler.instance)
    }
}
