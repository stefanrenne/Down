//
//  DownloadItemDetailViewController.swift
//  Down
//
//  Created by Ruud Puts on 06/10/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import UIKit
import DownKit
import CircleProgressView
import Kingfisher

import RxSwift
import RxCocoa

class DownloadItemDetailViewController: UIViewController & Depending {
    typealias Dependencies = RouterDependency & DownloadInteractorFactoryDependency & DvrApplicationDependency
    let dependencies: Dependencies

    private let viewModel: DownloadItemDetailViewModel
    private let tableViewController: DownloadItemDetailTableViewController

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    private var disposeBag = DisposeBag()

    init(dependencies: Dependencies, viewModel: DownloadItemDetailViewModel) {
        self.dependencies = dependencies
        self.viewModel = viewModel
        tableViewController = DownloadItemDetailTableViewController()

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"

        configureTableView()
        applyStyling()
        bind(to: viewModel)
    }

    private func configureTableView() {
        tableView.tableFooterView = UIView()
        
        tableViewController.prepare(tableView: tableView)
        tableView.dataSource = tableViewController
    }

    private func applyStyling() {
        view.style(as: .backgroundView)
        tableView.style(as: .defaultTableView)
        titleLabel.style(as: .boldTitleLabel)
        subtitleLabel.style(as: .titleLabel)
        statusLabel.style(as: .detailLabel)
        progressView.style(as: .progressView(for: dependencies.downloadApplication.downType))
        retryButton.style(as: .applicationButton(dependencies.dvrApplication.downType))
        deleteButton.style(as: .deleteButton)
    }
}

extension DownloadItemDetailViewController: ReactiveBinding {
    typealias Bindable = DownloadItemDetailViewModel

    func bind(to viewModel: DownloadItemDetailViewModel) {
        let output = viewModel.transform(input: makeInput())

        output.refinedItem
            .map { $0.title }
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)

        output.refinedItem
            .map { $0.subtitle }
            .drive(subtitleLabel.rx.text)
            .disposed(by: disposeBag)

        output.refinedItem
            .map { $0.statusText }
            .drive(statusLabel.rx.text)
            .disposed(by: disposeBag)

        output.refinedItem
            .map { $0.statusStyle }
            .do(onNext: { self.statusLabel.style(as: $0) })
            .drive()
            .disposed(by: disposeBag)

        output.refinedItem
            .map { !$0.hasProgress }
            .drive(progressView.rx.isHidden)
            .disposed(by: disposeBag)

        output.refinedItem
            .map { $0.progress }
            .drive(progressView.rx.progress)
            .disposed(by: disposeBag)

        output.refinedItem
            .map { !$0.canRetry }
            .drive(retryButton.rx.isHidden)
            .disposed(by: disposeBag)

        output.refinedItem
            .map { $0.headerImageUrl }
            .do(onNext: { self.headerImageView.kf.setImage(with: $0) })
            .drive()
            .disposed(by: disposeBag)

        output.refinedItem
            .map { $0.detailSections }
            .drive(tableViewController.rx.dataModel)
            .disposed(by: disposeBag)

        output.refinedItem
            .do(onNext: { _ in self.tableView.reloadData() })
            .drive()
            .disposed(by: disposeBag)

        output.itemDeleted
            .filter { $0 }
            .subscribe(onNext: { _ in
                self.dependencies.router.close(viewController: self)
            })
            .disposed(by: disposeBag)
    }

    func makeInput() -> DownloadItemDetailViewModel.Input {
        let deleteButtonTapped = deleteButton.rx.tap

        return DownloadItemDetailViewModel.Input(deleteButtonTapped: deleteButtonTapped)
    }
}
