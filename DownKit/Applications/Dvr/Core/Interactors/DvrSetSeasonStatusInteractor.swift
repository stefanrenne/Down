//
//  DvrSetSeasonStatusInteractor.swift
//  DownKit
//
//  Created by Ruud Puts on 18/06/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import RxSwift

public class DvrSetSeasonStatusInteractor: CompoundInteractor {
    public typealias Interactors = (setStatus: DvrSetSeasonStatusGateway, showDetails: DvrShowDetailsInteractor)
    public var interactors: Interactors

    public typealias Element = DvrShowDetailsInteractor.Element
    var subject: Variable<Element> = Variable(DvrShow())

    var database: DvrDatabase!
    let disposeBag = DisposeBag()

    public required init(interactors: Interactors) {
        self.interactors = interactors
    }

    convenience init(interactors: Interactors, database: DvrDatabase) {
        self.init(interactors: interactors)
        self.database = database
    }

    public func observe() -> Observable<DvrShow> {
        interactors.setStatus
            .observe()
            .subscribe(onNext: { _ in
                let show = self.interactors.setStatus.season.show!
                self.refreshShowDetails(show: show)
            })
            .disposed(by: disposeBag)

        return subject.asObservable()
    }

    private func refreshShowDetails(show: DvrShow) {
        interactors.showDetails
            .setShow(show)
            .observe()
            .subscribe(onNext: {
                $0.store(in: self.database)
                self.subject.value = $0
            })
            .disposed(by: disposeBag)
    }
}