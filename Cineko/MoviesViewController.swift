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
    var movieGenres:[Genre]?
    var movieGenre:String?
    let movieGroups = ["Popular", "Top Rated", "Coming Soon"]
    var movieGroup:String?
    var dynamicTitle:String?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        movieGenres = ObjectManager.sharedInstance().findObjects("Genre", predicate: NSPredicate(format: "movieGenre = %@", NSNumber(bool: true)), sorters: [NSSortDescriptor(key: "name", ascending: true)]) as? [Genre]
        
        if let movieGenre = NSUserDefaults.standardUserDefaults().valueForKey("movieGenre") as? String {
            self.movieGenre = movieGenre
        }
        
        if let movieGroup = NSUserDefaults.standardUserDefaults().valueForKey("movieGroup") as? String {
            self.movieGroup = movieGroup
        } else {
            movieGroup = movieGroups.first
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadMovieGroup()
        loadFavorites()
        loadWatchlist()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let tableView = tableView {
            tableView.reloadData()
        }
    }
    
    // MARK: Actions
    @IBAction func genreAction(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Select", message: nil, preferredStyle: .ActionSheet)
        
        for genre in movieGenres! {
            // add a checkmark for the current group using Unicode
            let title = genre.name
            
            let handler = {(alert: UIAlertAction!) in
                self.movieGenre = genre.name
                self.dynamicTitle = self.movieGenre
                NSUserDefaults.standardUserDefaults().setValue(self.movieGenre, forKey: "movieGenre")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.loadMovieGenre()
            }
            alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: handler))
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func organizeAction(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Select", message: nil, preferredStyle: .ActionSheet)
        
        for group in movieGroups {
            // add a checkmark for the current group using Unicode
            let title = group
            
            let handler = {(alert: UIAlertAction!) in
                self.movieGroup = group
                self.dynamicTitle = self.movieGroup
                NSUserDefaults.standardUserDefaults().setValue(self.movieGroup, forKey: "movieGroup")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.loadMovieGroup()
            }
            alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: handler))
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Custom methods
    func loadMovieGroup() {
        var path:String?
        var descriptors:[NSSortDescriptor]?
        
        if let movieGroup = movieGroup {
            switch movieGroup {
            case movieGroups[0]:
                path = TMDBConstants.Movies.Popular.Path
                descriptors = [
                    NSSortDescriptor(key: "popularity", ascending: false),
                    NSSortDescriptor(key: "title", ascending: true)]
            case movieGroups[1]:
                path = TMDBConstants.Movies.TopRated.Path
                descriptors = [
                    NSSortDescriptor(key: "voteAverage", ascending: false),
                    NSSortDescriptor(key: "title", ascending: true)]
            case movieGroups[2]:
                path = TMDBConstants.Movies.Upcoming.Path
                descriptors = [
                    NSSortDescriptor(key: "popularity", ascending: false),
                    NSSortDescriptor(key: "title", ascending: true)]
            default:
                return
            }
        }
        
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.dynamicFetchRequest = NSFetchRequest(entityName: "Movie")
            self.dynamicFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
            self.dynamicFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
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
            
            try TMDBManager.sharedInstance().movies(path!, completion: completion)
        } catch {}
    }
    
    func loadMovieGenre() {
        var genreID:Int?
        let descriptors = [NSSortDescriptor(key: "popularity", ascending: false),
        NSSortDescriptor(key: "title", ascending: true)]
        
        for genre in movieGenres! {
            if genre.name == movieGenre {
                genreID = genre.genreID!.integerValue
                break
            }
        }
        
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.dynamicFetchRequest = NSFetchRequest(entityName: "Movie")
            self.dynamicFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
            self.dynamicFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
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
            
            try TMDBManager.sharedInstance().moviesByGenre(genreID!, completion: completion)
        } catch {}
    }
    
    func loadFavorites() {
        favoritesFetchRequest = NSFetchRequest(entityName: "Movie")
        favoritesFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        favoritesFetchRequest!.sortDescriptors = [
            NSSortDescriptor(key: "releaseDate", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)]
        
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.favoritesFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        
        do {
            try TMDBManager.sharedInstance().accountFavoriteMovies(completion)
        } catch {
            favoritesFetchRequest!.predicate = NSPredicate(format: "favorite = %@", NSNumber(bool: true))
            self.tableView.reloadData()
        }
    }
    
    func loadWatchlist() {
        watchlistFetchRequest = NSFetchRequest(entityName: "Movie")
        watchlistFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        watchlistFetchRequest!.sortDescriptors = [
            NSSortDescriptor(key: "releaseDate", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)]
        
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.watchlistFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        
        do {
            try TMDBManager.sharedInstance().accountWatchlistMovies(completion)
        } catch {
            watchlistFetchRequest!.predicate = NSPredicate(format: "watchlist = %@", NSNumber(bool: true))
            self.tableView.reloadData()
        }
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
            cell.titleLabel.text = dynamicTitle
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
                title = dynamicTitle
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
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MovieDetailsViewController") as? MovieDetailsViewController,
            let navigationController = navigationController {
            let movie = displayable as! Movie
            controller.movieID = movie.objectID
            navigationController.pushViewController(controller, animated: true)
        }
    }
}
