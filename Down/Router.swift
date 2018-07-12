//
//  Router.swift
//  Down
//
//  Created by Ruud Puts on 07/06/2018.
//  Copyright © 2018 Mobile Sorcery. All rights reserved.
//

import DownKit
import UIKit

class Router {    
    let window: UIWindow
    let viewControllerFactory: ViewControllerProducing
    let database: DownDatabase
    
    var downloadRouter: DownloadRouter!
    var dvrRouter: DvrRouter!
    
    var navigationController: UINavigationController? {
        return window.rootViewController as? UINavigationController
    }
    
    init(window: UIWindow, viewControllerFactory: ViewControllerProducing, database: DownDatabase = RealmDatabase.default) {
        self.window = window
        self.viewControllerFactory = viewControllerFactory
        self.database = database
    }
    
    enum Identifier: String {
        case root
        case detail
    }
    
    func start() {
        let tabBarController = UITabBarController()
        
        let downloadViewController = startDownloadRouter(tabBarController: tabBarController)
        let dvrViewController = startDvrRouter(tabBarController: tabBarController)
        tabBarController.viewControllers = [downloadViewController, dvrViewController]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    func showSettings(application: Application) {
        let viewController = decorate(viewController: viewControllerFactory.makeDvrRoot())
        navigationController?.present(viewController, animated: true, completion: nil)
    }

    func decorate(viewController: UIViewController) -> UIViewController {
        if var routingViewController = viewController as? Routing {
            routingViewController.router = self
        }

        if var databaseConuming = viewController as? DatabaseConsuming {
            databaseConuming.database = database
        }

        return viewController
    }
}

private extension Router {
    func startDownloadRouter(tabBarController: UITabBarController) -> UIViewController {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Downloads", image: nil, tag: 0)

        downloadRouter = DownloadRouter(parent: self,
                                        viewControllerFactory: viewControllerFactory,
                                        navigationController: navigationController,
                                        database: database)
        downloadRouter.start()

        return navigationController
    }

    func startDvrRouter(tabBarController: UITabBarController) -> UIViewController {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Shows", image: nil, tag: 0)

        dvrRouter = DvrRouter(parent: self,
                              viewControllerFactory: viewControllerFactory,
                              navigationController: navigationController,
                              database: database)
        dvrRouter.start()

        return navigationController
    }
}

protocol Routing {
    var router: Router? { get set } //! Convert UI to Xibs to make non optional
}

protocol ChildRouter {
    var parent: Router { get set }
    var viewControllerFactory: ViewControllerProducing { get set }
}

protocol ApplicationRouting: ChildRouter {
    func showSettings()
}

extension ApplicationRouting {
    func showSettings() {
    }
}
