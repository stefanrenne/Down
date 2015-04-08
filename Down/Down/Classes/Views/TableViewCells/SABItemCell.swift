//
//  SABQueueItemCell.swift
//  Down
//
//  Created by Ruud Puts on 15/03/15.
//  Copyright (c) 2015 Ruud Puts. All rights reserved.
//

import UIKit

class SABItemCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var queueItem: SABQueueItem?
    var historyItem: SABHistoryItem?
    
    var sabNZBdService: SabNZBdService!
    
    override func awakeFromNib() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.sabNZBdService = appDelegate.serviceManager.sabNZBdService;
    }
    
    internal func setQueueItem(queueItem: SABQueueItem) {
        self.historyItem = nil
        self.queueItem = queueItem
        
        if queueItem.sickbeardEntry != nil {
            titleLabel.text = queueItem.sickbeardEntry!.displayName
        }
        else {
            titleLabel!.text = queueItem.displayName
        }
        
        progressBar!.progress = queueItem.progress / 100
        progressBar!.hidden = !queueItem.hasProgress
        progressLabel!.text = queueItem.progressDescription
        if (self.sabNZBdService.paused!) {
            statusLabel!.text = "-"
        }
        else {
            statusLabel!.text = queueItem.timeRemaining
        }
        categoryLabel!.text = queueItem.category
    }
    
    func setHistoryItem(historyItem: SABHistoryItem) {
        self.queueItem = nil
        self.historyItem = historyItem
        
        if historyItem.sickbeardEntry != nil {
            titleLabel.text = historyItem.sickbeardEntry!.displayName
        }
        else {
            titleLabel!.text = historyItem.displayName
        }
//        progressBar!.progress = historyItem.progress
        progressLabel!.text = historyItem.statusString
        switch (historyItem.status! as SABHistoryItem.SABHistoryItemStatus) {
        case .Finished:
            progressLabel.textColor = UIColor.downGreenColor()
        case .Failed:
            progressLabel.textColor = UIColor.downRedColor()
        default:
            progressLabel.textColor = UIColor.whiteColor()
        }
        
        statusLabel!.text = historyItem.size
        progressBar!.progress = 0
        progressBar!.hidden = true
        
        categoryLabel!.text = historyItem.category
    }
    
}
