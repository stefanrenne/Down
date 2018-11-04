//
//  DownloadViewController.swift
//  Down
//
//  Created by Ruud Puts on 27/05/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import UIKit
import DownKit
import RxSwift
import RxCocoa
import RxDataSources

class DownloadViewController: UIViewController & Routing & DatabaseConsuming & DownloadApplicationInteracting {
    var downloadApplication: DownloadApplication!
    var downloadInteractorFactory: DownloadInteractorProducing!
    var database: DownDatabase!
    var router: Router?
    let disposeBag = DisposeBag()

    @IBOutlet weak var headerView: ApplicationHeaderView!
    @IBOutlet weak var statusView: DownloadQueueStatusView!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var viewModel = DownloadViewModel(queueInteractor: downloadInteractorFactory.makeQueueInteractor(for: downloadApplication),
                                           historyInteractor: downloadInteractorFactory.makeHistoryInteractor(for: downloadApplication))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyStyling()
        configureTableView()
        applyViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navigationController = navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.setNavigationBarHidden(false, animated: animated)
        }
    }

    func applyStyling() {
        view.style(as: .backgroundView)
        tableView.style(as: .defaultTableView)
        headerView.style(as: .headerView(for: downloadApplication.downType))
    }
    
    func configureTableView() {
        tableView.delegate = self
        
        tableView.registerCell(nibName: DownloadItemCell.reuseIdentifier)
        tableView.registerHeaderFooter(nibName: TableHeaderView.reuseIdentifier)
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
    }
    
    func applyViewModel() {
        viewModel.queueData.asDriver()
            .drive(statusView.rx.queue)
            .disposed(by: disposeBag)
        
        viewModel.sectionsData.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    let dataSource = RxTableViewSectionedReloadDataSource<TableSectionData>(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell = tableView.dequeueReusableCell(withIdentifier: DownloadItemCell.reuseIdentifier, for: indexPath)
        
        guard let itemCell = cell as? DownloadItemCell else {
            return cell
        }

        if let queueItem = item as? DownloadQueueItem {
            itemCell.viewModel = DownloadItemCellModel(queueItem: queueItem)
        }
        else if let historyItem = item as? DownloadHistoryItem {
            itemCell.viewModel = DownloadItemCellModel(historyItem: historyItem)
        }

        return cell
    })
}

extension DownloadViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.reuseIdentifier)
        guard let headerView = view as? TableHeaderView else {
            return nil
        }

        let data = viewModel.sectionsData.value[section]
        headerView.viewModel = TableHeaderViewModel(title: data.header, icon: data.icon)

        return view
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.style(as: .selectableCell(application: downloadApplication.type))
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = viewModel.itemAt(indexPath: indexPath) else {
            return
        }

        router?.downloadRouter.showDetail(of: item)
    }
}
