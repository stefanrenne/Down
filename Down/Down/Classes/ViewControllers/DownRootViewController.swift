//
//  DownRootViewController.swift
//  Down
//
//  Created by Ruud Puts on 03/07/16.
//  Copyright © 2016 Ruud Puts. All rights reserved.
//

import UIKit
import DownKit

class DownRootViewController: DownViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        showNavigationBar(animated)
    }
    
    // MARK: Navigation bar
    
    func showNavigationBar(_ animated: Bool) {
        guard self.navigationController?.viewControllers.count == 2 else {
            return
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func hideNavigationBar(_ animated: Bool) {
        guard self.navigationController?.viewControllers.count == 1 else {
            return
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}

extension UINavigationController {
    
    func setupForApplication(_ application: DownApplication) {
        let color: UIColor
        
        switch application {
        case .sabNZBd:
            color = .downSabNZBdColor()
        case .sickbeard:
            color = .downSickbeardColor()
        case .couchPotato:
            color = .downCouchPotatoColor()
        case .down:
            color = .downRedColor()
            
        }
        
        navigationBar.barTintColor = color
        navigationBar.backgroundColor = color
    }
    
}

extension UINavigationController: DownTabBarItem {
    
    var tabIcon: UIImage {
        if let viewController = viewControllers.first as? DownTabBarItem {
            return viewController.tabIcon
        }

        return UIImage()
    }
    
    var selectedTabBackground: UIColor {
        if let viewController = viewControllers.first as? DownTabBarItem {
            return viewController.selectedTabBackground
        }

        return UIColor.clear
    }
    
    var deselectedTabBackground: UIColor {
        if let viewController = viewControllers.first as? DownTabBarItem {
            return viewController.deselectedTabBackground
        }
        
        return UIColor.clear
    }    
}
