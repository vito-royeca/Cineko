//
//  TVShowsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

class TVShowsViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var dynamicFetchRequest:NSFetchRequest?
    var favoritesFetchRequest:NSFetchRequest?
    var watchlistFetchRequest:NSFetchRequest?
    let tvShowGroups = ["Popular", "Top Rated", "On The Air"]
    var tvShowGroup:String?
    
    // MARK: Actions
    @IBAction func organizeAction(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Select", message: nil, preferredStyle: .ActionSheet)
        
        for group in tvShowGroups {
            // add a checkmark for the current group using Unicode
            let title = group == tvShowGroup ? "\u{2713} \(tvShowGroup!)" : group
            
            let handler = {(alert: UIAlertAction!) in
                self.tvShowGroup = group
                NSUserDefaults.standardUserDefaults().setValue(self.tvShowGroup, forKey: "tvShowGroup")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.loadDynamic()
            }
            alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: handler))
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        if let tvShowGroup = NSUserDefaults.standardUserDefaults().valueForKey("tvShowGroup") as? String {
            self.tvShowGroup = tvShowGroup
        } else {
            tvShowGroup = tvShowGroups.first
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadDynamic()
        loadFavorites()
        loadWatchlist()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let tableView = tableView {
            tableView.reloadData()
        }
    }
    
    // MARK: Custom methods
    func loadDynamic() {
        var path:String?
        var descriptors:[NSSortDescriptor]?
        
        if let tvShowGroup = tvShowGroup {
            switch tvShowGroup {
            case tvShowGroups[0]:
                path = TMDBConstants.TVShows.Popular.Path
                descriptors = [
                    NSSortDescriptor(key: "popularity", ascending: false),
                    NSSortDescriptor(key: "name", ascending: true)]
            case tvShowGroups[1]:
                path = TMDBConstants.TVShows.TopRated.Path
                descriptors = [
                    NSSortDescriptor(key: "voteAverage", ascending: false),
                    NSSortDescriptor(key: "name", ascending: true)]
            case tvShowGroups[2]:
                path = TMDBConstants.TVShows.OnTheAir.Path
                descriptors = [
                    NSSortDescriptor(key: "name", ascending: true)]
            default:
                return
            }
        }
        
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.dynamicFetchRequest = NSFetchRequest(entityName: "TVShow")
            self.dynamicFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
            self.dynamicFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", arrayIDs)
            self.dynamicFetchRequest!.sortDescriptors = descriptors
            
            performUIUpdatesOnMain {
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? ThumbnailTableViewCell {
                    MBProgressHUD.hideHUDForView(cell, animated: true)
                }
                self.tableView.reloadData()
            }
        }
        
        do {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? ThumbnailTableViewCell {
                MBProgressHUD.showHUDAddedTo(cell, animated: true)
            }
            
            try TMDBManager.sharedInstance().tvShows(path!, completion: completion)
        } catch {}
    }
    
    func loadFavorites() {
        favoritesFetchRequest = NSFetchRequest(entityName: "TVShow")
        favoritesFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        favoritesFetchRequest!.sortDescriptors = [
            NSSortDescriptor(key: "firstAirDate", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)]
        
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.favoritesFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", arrayIDs)
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        
        do {
            try TMDBManager.sharedInstance().accountFavoriteTVShows(completion)
        } catch {
            favoritesFetchRequest!.predicate = NSPredicate(format: "favorite = %@", NSNumber(bool: true))
            self.tableView.reloadData()
        }
    }
    
    func loadWatchlist() {
        watchlistFetchRequest = NSFetchRequest(entityName: "TVShow")
        watchlistFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        watchlistFetchRequest!.sortDescriptors = [
            NSSortDescriptor(key: "firstAirDate", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)]
        
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.watchlistFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", arrayIDs)
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        
        do {
            try TMDBManager.sharedInstance().accountWatchlistTVShows(completion)
        } catch {
            watchlistFetchRequest!.predicate = NSPredicate(format: "watchlist = %@", NSNumber(bool: true))
            self.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSource
extension TVShowsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ThumbnailTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = tvShowGroup
            cell.fetchRequest = dynamicFetchRequest
            cell.displayType = .Poster
            cell.captionType = .Title
        case 1:
            cell.titleLabel.text = "My Favorites"
            cell.fetchRequest = favoritesFetchRequest
            cell.displayType = .Poster
            cell.captionType = .Title
        case 2:
            cell.titleLabel.text = "My Watchlist"
            cell.fetchRequest = watchlistFetchRequest
            cell.displayType = .Poster
            cell.captionType = .Title
        default:
            break
        }
        
        cell.tag = indexPath.row
        cell.delegate = self
        cell.loadData()
        return cell
    }
}

// MARK: UITableViewDelegate
extension TVShowsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ThumbnailTableViewCell.Height
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension TVShowsViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SeeAllViewController") as? SeeAllViewController,
            let navigationController = navigationController {
            
            var title:String?
            var fetchRequest:NSFetchRequest?
            var displayType:DisplayType?
            
            switch tag {
            case 0:
                title = tvShowGroup
                fetchRequest = dynamicFetchRequest
                displayType = .Poster
            case 1:
                title = "My Favorites"
                fetchRequest = favoritesFetchRequest
                displayType = .Poster
            case 2:
                title = "My Watchlist"
                fetchRequest = watchlistFetchRequest
                displayType = .Profile
            default:
                return
            }
            
            controller.navigationItem.title = title
            controller.fetchRequest = fetchRequest
            controller.displayType = displayType
            controller.view.tag = tag
            controller.delegate = self
            navigationController.pushViewController(controller, animated: true)
        }
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TVShowDetailsViewController") as? TVShowDetailsViewController,
            let navigationController = navigationController {
            let tvShow = displayable as! TVShow
            controller.tvShowID = tvShow.objectID
            navigationController.pushViewController(controller, animated: true)
        }
    }
}
