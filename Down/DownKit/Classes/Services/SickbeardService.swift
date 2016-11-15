//
//  SickbeardService.swift
//  Down
//
//  Created by Ruud Puts on 14/03/15.
//  Copyright (c) 2015 Ruud Puts. All rights reserved.
//

import RealmSwift
import Alamofire

open class SickbeardService: Service {
    
    open static let shared = SickbeardService()
    
    open static let defaultPort = 8081
    fileprivate var shows: Results<SickbeardShow> {
        return DownDatabase.shared.fetchAllSickbeardShows()
    }
    
    fileprivate let bannerDownloadQueue = DispatchQueue(label: "com.ruudputs.down.BannerDownloadQueue", attributes: [])
    fileprivate let posterDownloadQueue = DispatchQueue(label: "com.ruudputs.down.PosterDownloadQueue", attributes: [])
    
    public enum ErrorType: Int {
        case guardFailed = -1
        case invalidValue = -2
    }
    
    fileprivate enum SickbeardNotifyType {
        case showCacheUpdated
        case showAdded
    }
    
    override open func addListener(_ listener: ServiceListener) {
        if listener is SickbeardListener {
            super.addListener(listener)
        }
    }
    
    override open func startService() {
        super.startService()
        NSLog("SickbeardService - Last updated: \(Preferences.sickbeardLastCacheRefresh ?? Date.init(timeIntervalSince1970: 0))")
        NSLog("SickbeardService - Refreshing show cache")
        refreshShowCache()
        
        let defaultShow = SickbeardShow()
        defaultShow.tvdbId = 0
        downloadPoster(defaultShow, force: true)
        downloadBanner(defaultShow, force: true)
    }
    
    // MARK: - Public methods
    
    internal func parseNzbName(_ nzbName: String) -> SickbeardEpisode? {
        // Check if show contains season/episode identifiers
        let regex = try! NSRegularExpression(pattern: "S\\d+(.)?E\\d+", options: .caseInsensitive)
        let seasonRange = regex.rangeOfFirstMatch(in: nzbName, options: [], range: nzbName.fullNSRange) as NSRange!
        
        guard seasonRange?.location != NSNotFound else {
            return nil
        }
        
        // Take everything before season/episode identifiers
        let cleanedName = nzbName.substring(0..<(seasonRange?.location)! - 1)
        
        // Get te components
        let nameComponents = cleanedName.components(separatedBy: ".")
        
        // Let the DownDatabase.shared manager match te best show
        if let show = DownDatabase.shared.showBestMatchingComponents(nameComponents) {
            let identifierStart = seasonRange!.location + 1
            let identifierEnd = seasonRange!.location + seasonRange!.length
            let seasonEpisodeIdentifier = nzbName.substring(identifierStart..<identifierEnd).uppercased().replacingOccurrences(of: ".", with: "")
            let components = seasonEpisodeIdentifier.components(separatedBy: "E")
            
            let seasonId = Int(components.first!)!
            let episodeId = Int(components.last!)!
            
            return show.getSeason(seasonId)?.getEpisode(episodeId)
        }
        else {
            print("Failed to parse nzb \(nzbName), with show name components \(nameComponents)")
        }
        
        return nil
    }
    
    open func getEpisodesAiringToday() -> Results<SickbeardEpisode> {
        let episodes = DownDatabase.shared.episodesAiringOnDate(Date());

        for episode in episodes {
            fetchEpisodeData(episode)
        }

        return episodes
    }
    
    open func getEpisodesAiringSoon() -> Results<SickbeardEpisode> {
        let episodes = DownDatabase.shared.episodesAiringAfter(Date.tomorrow(), max: 5);
        
        for episode in episodes {
            fetchEpisodeData(episode)
        }
        
        return episodes
    }
    
    open func getRecentlyAiredEpisodes() -> Results<SickbeardEpisode> {
        let episodes = DownDatabase.shared.lastAiredEpisodes(maxDays: 4);
        
        for episode in episodes {
            fetchEpisodeData(episode)
        }
        
        return episodes
    }
    
    open func showWithId(_ tvdbid: Int) -> SickbeardShow? {
        var showWithId: SickbeardShow? = nil
        for show in shows {
            if show.tvdbId == tvdbid && !show.isInvalidated {
                showWithId = show
                break
            }
        }
        
        return showWithId
    }
    
    open func refreshEpisodesForShow(_ show: SickbeardShow) {
        for season in show.seasons {
            for episode in season.episodes {
                fetchEpisodeData(episode)
            }
        }
    }

    // MARK: - Shows
    
    open func refreshShowCache(force: Bool = false) {
        // Find shows to refresh, episodes aired since last update
        fetchShows { tvdbIds in
            if self.shows.count == 0 || force {
                NSLog("SickbeardService - Refreshing full cache")
                let shows: [SickbeardShow] = tvdbIds.map {
                    let show = SickbeardShow()
                    show.tvdbId = $0
                    
                    return show
                }
                
                self.refreshShows(shows, completionHandler: {
                    Preferences.sickbeardLastCacheRefresh = Date().withoutTime()
                    self.notifyListeners(.showCacheUpdated)
                })
            }
            else if let lastCacheRefresh = Preferences.sickbeardLastCacheRefresh {
                var knownShowIds = Array(self.shows.map { $0.tvdbId })
                
                // Clean up deleted shows
                let deletedShowIds = knownShowIds.filter { !tvdbIds.contains($0) }
                NSLog("SickbeadService - Deleted shows: \(deletedShowIds)")
                deletedShowIds.forEach {
                    if let show = self.showWithId($0) {
                        NSLog("SickbeadService - Deleting show: \(show.name)")
                        DownDatabase.shared.deleteSickbeardShow(show)
                        knownShowIds.remove(at: deletedShowIds.index(of: $0)!)
                    }
                }
                
                // Find new shows
                let newShowIds = tvdbIds.filter { !knownShowIds.contains($0) }
                NSLog("SickbeadService - New shows: \(newShowIds)")
                
                var showsIdsToRefresh = [SickbeardShow]()
                showsIdsToRefresh += newShowIds.map {
                    let show = SickbeardShow()
                    show.tvdbId = $0
                    
                    return show
                }
                
                // Find shows to refresh, episodes aired since last update
                let showsToRefresh = DownDatabase.shared.fetchShowsWithEpisodesAiredSince(lastCacheRefresh)
                for show in showsToRefresh {
                    NSLog("SickbeardService - Refreshing \(show.name)")
                    showsIdsToRefresh.append(show)
                }
                
                NSLog("SickbeardService - Refreshing \(showsIdsToRefresh.count) shows")
                
                self.refreshShows(showsIdsToRefresh) {
                    Preferences.sickbeardLastCacheRefresh = Date().withoutTime()
                    self.notifyListeners(.showCacheUpdated)
                }
            }
        }
    }
    
    private func fetchShows(completion: @escaping ([Int]) -> Void) {
        let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=shows"
        Alamofire.request(url).responseJSON { handler in
            if handler.validateResponse() {
                let showData = (JSON(handler.result.value!)["data"] as JSON).rawValue as! [String: AnyObject]
                completion(Array(showData.keys).map { Int($0)! })
            }
            else {
                print("Error while fetching Sickbeard shows list: \(handler.result.error!)")
            }
        }
    }

    public func refreshShow(_ show: SickbeardShow, _ completionHandler: @escaping (SickbeardShow?) -> Void) {
        let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=show&tvdbid=\(show.tvdbId)"
        Alamofire.request(url).responseJSON { handler in
            if handler.validateResponse() {
                var refreshedShow: SickbeardShow?
                
                let json = JSON(handler.result.value!)
                if json["result"].string != "failure" {
                    refreshedShow = self.parseShowData(JSON(handler.result.value!)["data"], forTvdbId: show.tvdbId)
                    
                    self.downloadBanner(refreshedShow!)
                    self.downloadPoster(refreshedShow!)
                    self.refreshShowSeasons(refreshedShow!, completionHandler: {
                        DownDatabase.shared.storeSickbeardShow(refreshedShow!)
                        NSLog("SickbeardService - Refreshed \(refreshedShow!.name)")
                        
                        completionHandler(refreshedShow)
                    })
                    
                    return
                }
                
                completionHandler(refreshedShow)
            }
            else {
                print("Error while fetching Sickbeard showData: \(handler.result.error!)")
            }
        }
    }
    
    fileprivate func refreshShows(_ shows: [SickbeardShow], completionHandler: @escaping () -> Void) {
        let showRefreshGroup = DispatchGroup();
        
        shows.forEach {
            showRefreshGroup.enter()
            
            refreshShow($0) { _ in
                showRefreshGroup.leave()
            }
        }
        
        showRefreshGroup.notify(queue: DispatchQueue.main) {
            completionHandler()
        }
    }
    
    public func deleteShow(_ show: SickbeardShow, _ completionHandler: @escaping (Bool) -> Void) {
        let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=show.delete&tvdbid=\(show.tvdbId)"
        Alamofire.request(url).responseJSON { handler in
            if handler.validateResponse() {
                let json = JSON(handler.result.value!)
                let success = json["result"].string != "failure"
                
                if success {
                    DownDatabase.shared.deleteSickbeardShow(show)
                    self.notifyListeners(.showCacheUpdated)
                }
                completionHandler(success)
            }
            else {
                print("Error while deleting Sickbeard show: \(handler.result.error!)")
            }
        }
    }
    
    // MARK: Adding shows
    
    open func addShow(_ show: SickbeardShow, initialState state: SickbeardEpisode.SickbeardEpisodeStatus, completionHandler: @escaping (Bool, SickbeardShow?) -> Void) -> Void {
        let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=show.addnew&tvdbid=\(show.tvdbId)&status=\(state.rawValue.lowercased())"
        Alamofire.request(url).responseJSON { handler in
            let errorClosure: (String) -> (Void) = {
                NSLog("Error while adding show: " + $0)
                completionHandler(false, nil)
            }
            
            if handler.validateResponse() {
                let json = JSON(handler.result.value!)
                guard json["result"].string != "failure" else {
                    errorClosure(json["message"].string!)
                    return
                }

                NSLog("Added show \(show.name)")
                self.refreshShowAfterAdd(show) {
                    completionHandler(true, $0)
                }
            }
            else {
                errorClosure(handler.result.error!.localizedDescription)
            }
        }
    }
    
    // Don't like having to add this function, but recursive blocks result in a segfault 11
    fileprivate func refreshShowAfterAdd(_ show: SickbeardShow, _ completionHandler: @escaping (SickbeardShow) -> Void) {
        self.refreshShow(show) {
            guard let addedShow = $0 else {
                NSLog("Show still refreshing, retrying")
                Thread.sleep(forTimeInterval: 0.5)
                self.refreshShowAfterAdd(show, completionHandler)
                return
            }
            
            self.downloadBanner(show, force: true)
            self.downloadPoster(show, force: true)
            
            self.notifyListeners(.showAdded, withItem: addedShow)
            completionHandler(addedShow)
        }
    }
    
    open func searchForShow(query: String, completionHandler: @escaping ([SickbeardShow]) -> Void) {
        guard let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        
        let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=sb.searchtvdb&lang=en&name=" + escapedQuery
        Alamofire.request(url).responseJSON { handler in
            if handler.validateResponse() {
                let searchData = JSON(handler.result.value!)["data"]["results"]

                let shows = self.parseSearchResults(searchData)
                completionHandler(shows)
            }
            else {
                print("Error while fetching Sickbeard showData: \(handler.result.error!)")
            }
        }
    }
    
    fileprivate func parseSearchResults(_ json: JSON) -> [SickbeardShow] {
        var shows = [SickbeardShow]()
        
        json.forEach { (_, data) in
            let show = SickbeardShow()
            show.tvdbId = data["tvdbid"].int!
            show.name = data["name"].string!
            
            shows.append(show)
        }
        
        return shows
    }
    
    fileprivate func parseShowData(_ json: JSON, forTvdbId tvdbId: Int) -> SickbeardShow {
        let name = json["show_name"].string!
        let status = json["status"].string!
        let quality = json["quality"].string!
        let airs = json["airs"].string!
        let network = json["network"].string!
        
        let show = SickbeardShow()
        show.tvdbId = tvdbId
        show.name = name
        show.status = SickbeardShow.SickbeardShowStatus(rawValue: status) ?? show.status
        show.quality = SickbeardShow.SickbeardShowQuality(rawValue: quality) ?? show.quality
        show.airs = airs
        show.network = network
        
        return show
    }
    
    fileprivate func refreshShowSeasons(_ show: SickbeardShow, completionHandler: @escaping () -> Void) {
        let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=show.seasons&tvdbid=\(show.tvdbId)"
        Alamofire.request(url).responseJSON { handler in
            if handler.validateResponse() {
                self.parseShowSeasons(JSON(handler.result.value!)["data"], forShow: show)
                completionHandler()
            }
            else {
                print("Error while fetching Sickbeard showData: \(handler.result.error!)")
            }
        }
    }
    
    fileprivate func parseShowSeasons(_ json: JSON, forShow show: SickbeardShow) {
        let seasons = List<SickbeardSeason>()
        let dateFormatter = DateFormatter.downDateFormatter()
        
        let seaonsKeys = Array((json.rawValue as! [String: AnyObject]).keys)
        for seasonKey in seaonsKeys {
            let seasonJson = json[seasonKey] as JSON
        
            let season = SickbeardSeason() //(id: seasonKey, show: show)
            season.id = Int(seasonKey)!
            season.show = show
            
            // Parse season episodes
            let episodeKeys = Array((seasonJson.rawValue as! [String: AnyObject]).keys)
            for episodeKey in episodeKeys {
                let episodeJson = seasonJson[episodeKey] as JSON
                
                let episode = SickbeardEpisode() //(id: episodeKey, season: season, show: show)
                episode.id = Int(episodeKey)!
                episode.name = episodeJson["name"].string!
                episode.airDate = dateFormatter.date(from: episodeJson["airdate"].string!)
                episode.quality = episodeJson["quality"].string!
                let status = episodeJson["status"].string!
                episode.status = SickbeardEpisode.SickbeardEpisodeStatus(rawValue: status) ?? episode.status
                episode.season = season
                episode.show = show
                
                season._episodes.append(episode)
            }
            
            seasons.append(season)
        }
        show._seasons = seasons
    }
    
    // MARK: - Episodes
    
    @discardableResult
    fileprivate func fetchEpisodeData(_ episode: SickbeardEpisode) -> Bool {
        guard episode.plot.length == 0 else {
            return false
        }
        
        if let tvdbId = episode.show?.tvdbId, let seasonId = episode.season?.id {
            let command = "episode&tvdbid=\(tvdbId)&season=\(seasonId)&episode=\(episode.id)"
            let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=\(command)"
            Alamofire.request(url).responseJSON { handler in
                if handler.validateResponse() {
                    DispatchQueue.main.async {
                        let plot = JSON(handler.result.value!)["data"]["description"].string ?? ""
                        DownDatabase.shared.setPlot(plot, forEpisode: episode)
                    }
                }
                else {
                    print("Error while fetching Sickbeard episode data: \(handler.result.error!)")
                }
            }
            
            return true
        }
        
        return false
    }
    
    open func update(_ status: SickbeardEpisode.SickbeardEpisodeStatus, forEpisode episode: SickbeardEpisode, completion: @escaping (Error?) -> (Void)) {
        guard let tvdbId = episode.show?.tvdbId, let seasonId = episode.season?.id else {
            completion(NSError(domain: "Down.SickbeardService", code: ErrorType.guardFailed.rawValue, userInfo: [NSLocalizedDescriptionKey: "Guard failed"]))
            return
        }
        
        guard SickbeardEpisode.SickbeardEpisodeStatus.updatable.contains(status) else {
            completion(NSError(domain: "Down.SickbeardService", code: ErrorType.invalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "Invalid value for 'status'"]))
            return
        }
        
        let command = "episode.setstatus&status=\(status.rawValue.lowercased())&tvdbid=\(tvdbId)&season=\(seasonId)&episode=\(episode.id)&force=1"
        let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=\(command)"
        Alamofire.request(url).responseJSON { handler in
            completion(handler.result.error)
            return
        }
        
        completion(nil)
    }
    
    open func update(_ status: SickbeardEpisode.SickbeardEpisodeStatus, forSeason season: SickbeardSeason, completion: @escaping (Error?) -> (Void)) {
        guard let tvdbId = season.show?.tvdbId else {
            completion(NSError(domain: "Down.SickbeardService", code: ErrorType.guardFailed.rawValue, userInfo: [NSLocalizedDescriptionKey: "Guard failed"]))
            return
        }
        
        guard SickbeardEpisode.SickbeardEpisodeStatus.updatable.contains(status) else {
            completion(NSError(domain: "Down.SickbeardService", code: ErrorType.invalidValue.rawValue, userInfo: [NSLocalizedDescriptionKey: "Invalid value for 'status'"]))
            return
        }
        
        let command = "episode.setstatus&status=\(status.rawValue.lowercased())&tvdbid=\(tvdbId)&season=\(season.id)&force=1"
        let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=\(command)"
        Alamofire.request(url).responseJSON { handler in
            completion(handler.result.error)
            return
        }
        
        completion(nil)
    }
    
    // MARK: - Listeners
    
//    fileprivate func notifyListeners(_ notifyType: SickbeardNotifyType) {
    
    fileprivate func notifyListeners(_ notifyType: SickbeardNotifyType) {
        notifyListeners(notifyType, withItem: nil)
    }
    
    fileprivate func notifyListeners(_ notifyType: SickbeardNotifyType, withItem item: AnyObject?) {
        for listener in self.listeners {
            if listener is SickbeardListener {
                let sickbeardListener = listener as! SickbeardListener
                switch notifyType {
                case .showCacheUpdated:
                    NSLog("SickbeardService - Show cache refreshed")
                    sickbeardListener.sickbeardShowCacheUpdated()
                    break
                case .showAdded:
                    let show = item as! SickbeardShow
                    NSLog("SickbeardService - Show added: \(show.name)")
                    sickbeardListener.sickbeardShowAdded(show)
                }
            }
        }
    }
    
    // MARK: - Banners & Posters
    
    fileprivate func downloadBanner(_ show: SickbeardShow) {
        downloadBanner(show, force: false)
    }
    
    fileprivate func downloadBanner(_ show: SickbeardShow, force: Bool) {
        if show.tvdbId == 289882 {
            
        }
        
        if show.hasBanner && !force {
            return
        }
        
        bannerDownloadQueue.async(execute: {
            
            let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=show.getbanner&tvdbid=\(show.tvdbId)"
            Alamofire.request(url).responseData { handler in
                if handler.validateResponse() {
                    ImageProvider.storeBanner(handler.result.value!, forShow: show.tvdbId)
                }
                else {
                    print("Error while fetching banner: \(handler.result.error!)")
                }
            }
        })
    }
    
    fileprivate func downloadPoster(_ show: SickbeardShow) {
        downloadPoster(show, force: false)
    }
    
    fileprivate func downloadPoster(_ show: SickbeardShow, force: Bool) {
        if show.tvdbId == 289882 {
            
        }
        
        if show.hasPoster && !force {
            return
        }
        
        posterDownloadQueue.async(execute: {
            let url = Preferences.sickbeardHost + "/api/" + Preferences.sickbeardApiKey + "?cmd=show.getposter&tvdbid=\(show.tvdbId)"
            Alamofire.request(url).responseData { handler in
                if handler.validateResponse() {
                    ImageProvider.storePoster(handler.result.value!, forShow: show.tvdbId)
                }
                else {
                    print("Error while fetching poster: \(handler.result.error!)")
                }
            }
        })
    }
    
}
