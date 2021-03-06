//
//  DvrShowDetailsTableViewModel.swift
//  Down
//
//  Created by Ruud Puts on 09/09/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import DownKit

class DvrShowDetailsTableViewModel: NSObject, Depending {
    typealias Dependencies = DvrApplicationDependency
    let dependencies: Dependencies

    let viewModel: DvrShowDetailsViewModel

    init(dependencies: Dependencies, viewModel: DvrShowDetailsViewModel) {
        self.dependencies = dependencies
        self.viewModel = viewModel
    }

    func prepare(tableView: UITableView) {
        tableView.registerCell(nibName: DvrEpisodeCell.reuseIdentifier)
        tableView.registerHeaderFooter(nibName: TableHeaderView.reuseIdentifier)
    }
}

extension DvrShowDetailsTableViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.show.seasons.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.show.sortedSeasons[section].episodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DvrEpisodeCell.reuseIdentifier, for: indexPath)
        guard let episodeCell = cell as? DvrEpisodeCell else {
            return cell
        }

        let episode = viewModel.show.sortedSeasons[indexPath.section].sortedEpisodes[indexPath.row]
        episodeCell.viewModel = DvrEpisodeCellModel(episode: episode)

        return cell
    }
}

extension DvrShowDetailsTableViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.reuseIdentifier)
        guard let headerView = view as? TableHeaderView else {
            return nil
        }

        let season = viewModel.show.sortedSeasons[section]
        headerView.viewModel = TableHeaderViewModel(title: "Season \(season.identifier)", icon: nil)

        return view
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.style(as: .defaultCell)
        cell.style(as: .selectableCell(application: dependencies.dvrApplication.downType))
    }
}

private extension DvrShow {
    var sortedSeasons: [DvrSeason] {
        return seasons.sorted(by: { Int($0.identifier)! > Int($1.identifier)! })
    }
}

private extension DvrSeason {
    var sortedEpisodes: [DvrEpisode] {
        return episodes.sorted(by: { Int($0.identifier)! > Int($1.identifier)! })
    }
}
