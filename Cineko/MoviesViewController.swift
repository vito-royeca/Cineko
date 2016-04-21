//
//  MoviesViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

class MoviesViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var dynamicFetchRequest:NSFetchRequest?
    var favoritesFetchRequest:NSFetchRequest?
    var watchlistFetchRequest:NSFetchRequest?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadDynamic()
        loadFavorites()
        loadWatchlist()
    }
    
    // MARK: Actions
    @IBAction func genreAction(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func organizeAction(sender: UIBarButtonItem) {
        
    }
    
    // MARK: Custom methods
    func loadDynamic() {
        
    }
    
    func loadFavorites() {
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.favoritesFetchRequest = NSFetchRequest(entityName: "Movie")
            self.favoritesFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
            self.favoritesFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
            self.favoritesFetchRequest!.sortDescriptors = [
                NSSortDescriptor(key: "releaseDate", ascending: true),
                NSSortDescriptor(key: "title", ascending: true)]
            
            performUIUpdatesOnMain {
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? ThumbnailTableViewCell {
                    MBProgressHUD.hideHUDForView(cell, animated: true)
                }
                self.tableView.reloadData()
            }
        }
        
        do {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? ThumbnailTableViewCell {
                MBProgressHUD.showHUDAddedTo(cell, animated: true)
            }
            
            try TMDBManager.sharedInstance().accountFavoriteMovies(completion)
        } catch {}
    }
    
    func loadWatchlist() {
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.watchlistFetchRequest = NSFetchRequest(entityName: "Movie")
            self.watchlistFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
            self.watchlistFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
            self.watchlistFetchRequest!.sortDescriptors = [
                NSSortDescriptor(key: "releaseDate", ascending: true),
                NSSortDescriptor(key: "title", ascending: true)]
            
            performUIUpdatesOnMain {
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as? ThumbnailTableViewCell {
                    MBProgressHUD.hideHUDForView(cell, animated: true)
                }
                self.tableView.reloadData()
            }
        }
        
        do {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as? ThumbnailTableViewCell {
                MBProgressHUD.showHUDAddedTo(cell, animated: true)
            }
            
            try TMDBManager.sharedInstance().accountWatchlistMovies(completion)
        } catch {}
    }
}

// MARK: UITableViewDataSource
extension MoviesViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ThumbnailTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Now Showing"
            cell.fetchRequest = dynamicFetchRequest
            cell.displayType = .Poster
        case 1:
            cell.titleLabel.text = "My Favorites"
            cell.fetchRequest = favoritesFetchRequest
            cell.displayType = .Poster
        case 2:
            cell.titleLabel.text = "My Watchlist"
            cell.fetchRequest = watchlistFetchRequest
            cell.displayType = .Poster
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
extension MoviesViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ThumbnailTableViewCell.Height
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension MoviesViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SeeAllViewController") as? SeeAllViewController,
            let navigationController = navigationController {
            
            var title:String?
            var fetchRequest:NSFetchRequest?
            var displayType:DisplayType?
            
            switch tag {
            case 0:
                title = "Now Showing"
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
        switch tag {
        case 0:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MovieDetailsViewController") as? MovieDetailsViewController,
                let navigationController = navigationController {
                let movie = displayable as! Movie
                controller.movieID = movie.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        default:
            return
        }
    }
}
