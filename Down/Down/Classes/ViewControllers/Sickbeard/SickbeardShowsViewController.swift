//
//  SickbeardShowsViewController.swift
//  Down
//
//  Created by Ruud Puts on 19/09/15.
//  Copyright (c) 2015 Ruud Puts. All rights reserved.
//

import UIKit
import DownKit
import Preheat
import Nuke
import RealmSwift

class SickbeardShowsViewController: DownDetailViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var preheatController: PreheatController<UICollectionView>!
    var shows = DownDatabase.shared.fetchAllSickbeardShows()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shows"
        
        addSearchBar()
        addPlusButton()
        
        let cellNib = UINib(nibName: "SickbeardShowCell", bundle:nil)
        collectionView?.registerNib(cellNib, forCellWithReuseIdentifier: "SickbeardShowCell")
        collectionView?.backgroundColor = .downLightGrayColor()

        preheatController = PreheatController(view: collectionView!)
        preheatController.handler = { [weak self] in
            self?.preheatWindowChanged(addedIndexPaths: $0, removedIndexPaths: $1)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        preheatController.enabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // When you disable preheat controller it removes all preheating
        // index paths and calls its handler
        preheatController.enabled = false
    }
    
    func preheatWindowChanged(addedIndexPaths added: [NSIndexPath], removedIndexPaths removed: [NSIndexPath]) {
        func requestsForIndexPaths(indexPaths: [NSIndexPath]) -> [ImageRequest] {
            var requests = [ImageRequest]()
            indexPaths.forEach {
                if $0.item < shows.count {
                    let request = shows[$0.item].posterThumbnailRequest
                    requests.append(request)
                }
            }
            
            return requests
        }
        Nuke.startPreheatingImages(requestsForIndexPaths(added))
        Nuke.stopPreheatingImages(requestsForIndexPaths(removed))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = collectionView!.indexPathsForSelectedItems()?.first where segue.identifier == "SickbeardShow" {
            let show = shows[indexPath.item]
            
            let detailViewController = segue.destinationViewController as! SickbeardShowViewController
            detailViewController.show = show
        }
    }
    
    // MARK: - CollectionView DataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(collectionView: UICollectionView, isSectionEmtpy section: Int) -> Bool {
        return shows.count == 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let show = shows[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SickbeardShowCell", forIndexPath: indexPath) as! SickbeardShowCell
        cell.setCellType(.Sickbeard)
        cell.show = show
        
        cell.posterView.nk_setImageWith(show.posterThumbnailRequest)
        
        return cell
    }
    
    // MARK: - CollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let showsPerLine = 3
        // Calculate the widt
        var cellWidth = self.view.frame.width / CGFloat(showsPerLine)
        
        let modulus = indexPath.row % showsPerLine
        if modulus == 0 {
            // Floor the outer left column
            cellWidth = floor(cellWidth)
        }
        else if modulus == showsPerLine - 1 {
            // Ceil the outer right column
            cellWidth = ceil(cellWidth)
        }
        
        // Calculate the height, aspect ration 66:100
        let cellHeight = (cellWidth / 66 * 100)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return searchBar?.bounds.size ?? CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("SickbeardShow", sender: nil)
    }
    
}

extension SickbeardShowsViewController { // UISearchBarDelegate
    
    override func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedText = searchText.trimmed
        
        shows = DownDatabase.shared.fetchAllSickbeardShows()
        if trimmedText.length > 0 {
            shows = shows.filter("_simpleName contains[c] %@", trimmedText)
        }
        
        super.searchBar(searchBar, textDidChange: searchText)
    }
    
    override func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shows = DownDatabase.shared.fetchAllSickbeardShows()
        
        super.searchBarCancelButtonClicked(searchBar)
    }
    
}

extension SickbeardShowViewController { // Adding show
    
    func addPlusButton() {
        let button = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(plusButtonTapped))
        navigationItem.rightBarButtonItem = button
    }
    
    func plusButtonTapped() {
        performSegueWithIdentifier("addShow", sender: nil)
    }
    
}

extension UISearchBar {
    
    var textfield: UITextField? {
        get {
            return valueForKey("searchField") as? UITextField
        }
    }
    
}

extension SickbeardShow {
    
    var posterThumbnailRequest: ImageRequest {
        get {
            let filePath = UIApplication.documentsDirectory + "/sickbeard/posters/\(tvdbId)_thumb.png"
            return ImageRequest(URL: NSURL(fileURLWithPath: filePath))
        }
    }
    
}
