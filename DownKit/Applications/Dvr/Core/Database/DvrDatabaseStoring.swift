//
//  DvrDataStorage.swift
//  DownKit
//
//  Created by Ruud Puts on 18/06/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import RxSwift

public protocol DvrDatabase: Database {
    func store(show: DvrShow)
    func delete(show: DvrShow)
    func fetchShows() -> Observable<[DvrShow]>
    func fetchShow(matching nameComponents: [String]) -> Maybe<DvrShow>
}

protocol DvrDatabaseStoring {
    func store(in database: DvrDatabase)
}
