//
//  SickbeardViewController.swift
//  Down
//
//  Created by Ruud Puts on 05/04/15.
//  Copyright (c) 2015 Ruud Puts. All rights reserved.
//

import UIKit
import DownKit

class SickbeardShowsViewController: DownDetailViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var sickbeardService: SickbeardService!
    
    convenience init() {
        self.init(nibName: "SickbeardShowsViewController", bundle: nil)
        
        title = "Shows"
        sickbeardService = serviceManager.sickbeardService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "SickbeardShowCell", bundle:nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "SickbeardShowCell")
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sickbeardService.shows.count
    }
    
    func tableView(tableView: UITableView, isSectionEmtpy section: Int) -> Bool {
        return sickbeardService.shows.count == 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let show = Array(sickbeardService.shows.values)[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SickbeardShowCell", forIndexPath: indexPath) as! SickbeardShowCell
        cell.setCellType(.Sickbeard)
        cell.label?.text = show.name
//        cell.posterView?.image = show.poster
        
        return cell
    }
    
    // MARK: Keeping this for later
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0// 30.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = (NSBundle.mainBundle().loadNibNamed("SickbeardHeaderView", owner: self, options: nil) as Array).first as! SickbeardHeaderView
        headerView.textLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    // MARK: - TableView Delegate
    
}
