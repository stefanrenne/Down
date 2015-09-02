//
//  SickbeardService.swift
//  Down
//
//  Created by Ruud Puts on 14/03/15.
//  Copyright (c) 2015 Ruud Puts. All rights reserved.
//

public class SickbeardService: Service {

    var refreshTimer: NSTimer?
    
    public var history: Array<SickbeardHistoryItem>!
    public var future: [String: [SickbeardFutureItem]]!
    
    private let bannerQueue = dispatch_queue_create("com.ruudputs.down.BannerQueue", DISPATCH_QUEUE_SERIAL)
    
    private enum SickbeardNotifyType {
        case HistoryUpdated
        case FutureUpdated
    }
   
    override init() {
        self.history = Array<SickbeardHistoryItem>()
        
        super.init()
        
        startTimers()
        refreshFuture()
    }
    
    override public func addListener(listener: ServiceListener) {
        if listener is SickbeardListener {
            super.addListener(listener)
        }
    }
    
    private func startTimers() {
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self,
            selector: "refreshHistory", userInfo: nil, repeats: true)
        
        refreshHistory()
    }
    
    // MARK: - Public methods
    
    internal func historyItemWithResource(resource: String!) -> SickbeardHistoryItem? {
        var historyItem: SickbeardHistoryItem?
        for item: SickbeardHistoryItem in self.history {
            if resource.rangeOfString(item.resource) != nil {
                historyItem = item
                break
            }
        }
        return historyItem
    }
    
    // MARK: - History
    
    @objc private func refreshHistory() {
        let url = PreferenceManager.sickbeardHost + "/" + PreferenceManager.sickbeardApiKey + "?cmd=history&limit=40"
        request(.GET, url).responseJSON { _, _, result in
            if result.isSuccess {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    self.parseHistoryJson(JSON(result.value!))
                    self.refreshCompleted()

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.notifyListeners(.HistoryUpdated)
                    })
                })
            }
            else {
                print("Error while fetching Sickbard history: \(result.error!)")
            }
        }
    }
    
    private func parseHistoryJson(json: JSON!) {
        var history: Array<SickbeardHistoryItem> = Array<SickbeardHistoryItem>()
        
        for jsonItem: JSON in json["data"].array! {
            let tvdbId = jsonItem["tvdbid"].int!
            let showName = jsonItem["show_name"].string!
            let status = jsonItem["status"].string!
            let season = jsonItem["season"].int!
            let episode = jsonItem["episode"].int!
            let resource = jsonItem["resource"].string!
            
            let historyItem = SickbeardHistoryItem(tvdbId, showName, season, episode, status, resource)
            downloadBanner(historyItem)
            history.append(historyItem)
        }
        
        self.history = history
    }
    
    // MARK: - Future
    private func refreshFuture() {
        let url = PreferenceManager.sickbeardHost + "/" + PreferenceManager.sickbeardApiKey + "?cmd=future"
        request(.GET, url).responseJSON { _, _, result in
            if result.isSuccess {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    self.parseFuture(JSON(result.value!))
                    self.refreshCompleted()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.notifyListeners(.FutureUpdated)
                    })
                })
            }
            else {
                print("Error while fetching Sickbeard future: \(result.error!)")
            }
        }
    }
    
    private func parseFuture(json: JSON!) {
        var future = [String: [SickbeardFutureItem]]()
        
        for category in SickbeardFutureItem.Category.values {
            let categoryName = category.rawValue as String
            var items = [SickbeardFutureItem]()
            
            let categoryItems = json["data"][categoryName].array!
            for jsonItem: JSON in categoryItems {
                let tvdbId = jsonItem["tvdbid"].int!
                let showName = jsonItem["show_name"].string!
                let season = jsonItem["season"].int!
                let episode = jsonItem["episode"].int!
                let episodeName = jsonItem["ep_name"].string!
                let airDate = jsonItem["airs"].string!

                let futureItem = SickbeardFutureItem(tvdbId, showName, season, episode, "", episodeName, airDate, category)
                downloadBanner(futureItem)
                items.append(futureItem)
            }
            future[categoryName] = items
        }
        
        self.future = future
    }
    
    // MARK: - Listeners
    
    private func notifyListeners(notifyType: SickbeardNotifyType) {
        for listener in self.listeners {
            if listener is SickbeardListener {
                let sickbeardListener = listener as! SickbeardListener
                switch notifyType {
                case .HistoryUpdated:
                    sickbeardListener.sickbeardHistoryUpdated()
                    break
                case .FutureUpdated:
                    break
                }
            }
        }
    }
    
    // MARK: - Banners
    
    private func downloadBanner(item: SickbeardItem) {
        dispatch_async(bannerQueue, {
            if item.hasBanner {
                return
            }
            
            let url = PreferenceManager.sickbeardHost + "/" + PreferenceManager.sickbeardApiKey + "?cmd=show.getbanner&tvdbid=\(item.tvdbId)"
            request(.GET, url).responseData { _, _, result in
                if result.isSuccess {
                    ImageProvider.storeBanner(result.value!, forShow: item.tvdbId)
                }
                else {
                    print("Error while fetching banner: \(result.error!)")
                }
            }
        })
    }
    
}