//
//  DownloadItemDetailViewModel.swift
//  Down
//
//  Created by Ruud Puts on 06/10/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import UIKit
import DownKit
import RxSwift
import RxCocoa

protocol DownloadItemDetailViewModel {
    var title: String { get }
    var subtitle: String? { get }
    var statusText: String { get }
    var statusStyle: ViewStyling<UILabel> { get }
    var headerImageUrl: URL? { get }

    var downloadItem: DownloadItem { get }
    func makeItemRows() -> [DownloadItemDetailRow]
    var detailRows: [[DownloadItemDetailRow]] { get }

    var itemHasProgress: Bool { get }
    var itemCanRetry: Bool { get }
}

extension DownloadItemDetailViewModel {
    var title: String {
        return downloadItem.displayName
    }

    var detailRows: [[DownloadItemDetailRow]] {
        var sections = [makeItemRows()]

        if let dvrShowRows = makeDvrEpisodeRows() {
            sections.append(dvrShowRows)
        }

        return sections
    }

    private func makeDvrEpisodeRows() -> [DownloadItemDetailRow]? {
        guard let episode = downloadItem.dvrEpisode,
              let show = downloadItem.dvrEpisode?.show else {
            return nil
        }

        return [
            DownloadItemDetailRow(key: .showName, value: show.name),
            DownloadItemDetailRow(key: .episodeNumber, value: episode.seasonIdentifierString ?? "-"),
            DownloadItemDetailRow(key: .episodeName, value: episode.name),
            DownloadItemDetailRow(key: .episodeAirdate, value: episode.airdate?.dateString ?? "-"),
//            DownloadItemDetailRow(key: .episodePlot, value: episode.plot)
        ]
    }
}

extension DownloadItemDetailViewModel {
    typealias DeleteItemDependencies = DownloadInteractorFactoryDependency

    func deleteDownloadItem(dependencies: DeleteItemDependencies) -> Single<Bool> {
        return dependencies.downloadInteractorFactory
            .makeDeleteItemInteractor(for: dependencies.downloadApplication, item: downloadItem)
            .observe()
    }
}
