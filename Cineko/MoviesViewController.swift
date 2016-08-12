//
//  MoviesViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import JJJUtils
import MBProgressHUD

class MoviesViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var genreButton: UIBarButtonItem!
    @IBOutlet weak var organizeButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var dynamicFetchRequest:NSFetchRequest?
    var favoritesFetchRequest:NSFetchRequest?
    var watchlistFetchRequest:NSFetchRequest?
    var movieGenres:[Genre]?
    let movieGroups = ["Popular", "Top Rated", "Coming Soon"]
    var dynamicTitle:String?
    private var dataDict = [String: [AnyObject]]()
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        movieGenres = ObjectManager.sharedInstance.findObjects("Genre", predicate: NSPredicate(format: "movieGenre = %@", NSNumber(bool: true)), sorters: [NSSortDescriptor(key: "name", ascending: true)]) as? [Genre]
        
        if let dynamicTitle = NSUserDefaults.standardUserDefaults().valueForKey(TMDBConstants.Device.Keys.MoviesDynamic) as? String {
            self.dynamicTitle = dynamicTitle
        } else {
            dynamicTitle = movieGroups.first
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let dynamicTitle = dynamicTitle {
            if dynamicTitle == movieGroups[0] ||
                dynamicTitle == movieGroups[1] ||
                dynamicTitle == movieGroups[2] {
                loadMovieGroup()
            } else {
                loadMovieGenre()
            }
        } else {
            loadMovieGroup()
        }
        
        loadFavorites()
        loadWatchlist()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let tableView = tableView {
            tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMovieDetailsFromMovies" {
            if let detailsVC = segue.destinationViewController as? MovieDetailsViewController {
                let movie = sender as! Movie
                detailsVC.movieID = movie.objectID
            }
        } else if segue.identifier == "showSeeAllFromMovies" {
            if let detailsVC = segue.destinationViewController as? SeeAllViewController {
                var title:String?
                var fetchRequest:NSFetchRequest?
                
                switch sender as! Int {
                case 0:
                    title = dynamicTitle
                    fetchRequest = dynamicFetchRequest
                case 1:
                    title = "Favorites"
                    fetchRequest = favoritesFetchRequest
                case 2:
                    title = "Watchlist"
                    fetchRequest = watchlistFetchRequest
                default:
                    return
                }
                
                detailsVC.navigationItem.title = title
                detailsVC.fetchRequest = fetchRequest
                detailsVC.displayType = .Poster
                detailsVC.captionType = .Title
                detailsVC.view.tag = sender as! Int
                detailsVC.delegate = self
            }
        }
    }
    
    // MARK: Actions
    @IBAction func genreAction(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Select", message: nil, preferredStyle: .ActionSheet)
        
        for genre in movieGenres! {
            // add a checkmark for the current group using Unicode
            let title = genre.name == dynamicTitle ? "\u{2713} \(dynamicTitle!)" : genre.name
            
            let handler = {(alert: UIAlertAction!) in
                self.dynamicTitle = genre.name
                NSUserDefaults.standardUserDefaults().setValue(self.dynamicTitle, forKey: TMDBConstants.Device.Keys.MoviesDynamic)
                NSUserDefaults.standardUserDefaults().synchronize()
                self.loadMovieGenre()
            }
            alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: handler))
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if let popover = alert.popoverPresentationController {
                popover.barButtonItem = genreButton
                popover.permittedArrowDirections = .Any
                showDetailViewController(alert, sender:genreButton)
            }
        } else {
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func organizeAction(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Select", message: nil, preferredStyle: .ActionSheet)
        
        for group in movieGroups {
            // add a checkmark for the current group using Unicode
            let title = group == dynamicTitle ? "\u{2713} \(dynamicTitle!)" : group
            
            let handler = {(alert: UIAlertAction!) in
                self.dynamicTitle = group
                NSUserDefaults.standardUserDefaults().setValue(group, forKey: TMDBConstants.Device.Keys.MoviesDynamic)
                NSUserDefaults.standardUserDefaults().synchronize()
                self.loadMovieGroup()
            }
            alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: handler))
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if let popover = alert.popoverPresentationController {
                popover.barButtonItem = organizeButton
                popover.permittedArrowDirections = .Any
                showDetailViewController(alert, sender:organizeButton)
            }
        } else {
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Custom methods
    func loadMovieGroup() {
        var path:String?
        var descriptors:[NSSortDescriptor]?
        var refreshData:String?
        
        if let movieGroup = dynamicTitle {
            switch movieGroup {
            case movieGroups[0]:
                path = TMDBConstants.Movies.Popular.Path
                descriptors = [
                    NSSortDescriptor(key: "popularity", ascending: false),
                    NSSortDescriptor(key: "title", ascending: true)]
                refreshData = TMDBConstants.Device.Keys.MoviesPopular
            case movieGroups[1]:
                path = TMDBConstants.Movies.TopRated.Path
                descriptors = [
                    NSSortDescriptor(key: "voteAverage", ascending: false),
                    NSSortDescriptor(key: "title", ascending: true)]
                refreshData = TMDBConstants.Device.Keys.MoviesTopRated
            case movieGroups[2]:
                path = TMDBConstants.Movies.Upcoming.Path
                descriptors = [
                    NSSortDescriptor(key: "popularity", ascending: false),
                    NSSortDescriptor(key: "title", ascending: true)]
                refreshData = TMDBConstants.Device.Keys.MoviesComingSoon
            default:
                return
            }
        }
        
        dynamicFetchRequest = NSFetchRequest(entityName: "Movie")
        dynamicFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        dynamicFetchRequest!.sortDescriptors = descriptors
        
        if TMDBManager.sharedInstance.needsRefresh(refreshData!) {
            let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        TMDBManager.sharedInstance.deleteRefreshData(refreshData!)
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    self.dataDict[refreshData!] = arrayIDs
                    self.dynamicFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
                
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                        MBProgressHUD.hideHUDForView(cell, animated: true)
                    }
                    self.tableView.reloadData()
                }
            }
            
            do {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                try TMDBManager.sharedInstance.movies(path!, completion: completion)
                
            } catch {
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                    MBProgressHUD.hideHUDForView(cell, animated: true)
                }
                dynamicFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", dataDict[refreshData!] as! [NSNumber])
                tableView.reloadData()
            }
            
        } else {
            dynamicFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", dataDict[refreshData!] as! [NSNumber])
            tableView.reloadData()
        }
    }
    
    func loadMovieGenre() {
        var genreID:Int?
        var genreName:String?
        let descriptors = [NSSortDescriptor(key: "popularity", ascending: false),
        NSSortDescriptor(key: "title", ascending: true)]
    
        for genre in movieGenres! {
            if genre.name == dynamicTitle {
                genreID = genre.genreID!.integerValue
                genreName = genre.name
                break
            }
        }
    
        dynamicFetchRequest = NSFetchRequest(entityName: "Movie")
        dynamicFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        dynamicFetchRequest!.sortDescriptors = descriptors
        
        if TMDBManager.sharedInstance.needsRefresh(genreName!) {
            let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        TMDBManager.sharedInstance.deleteRefreshData(genreName!)
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    self.dataDict[genreName!] = arrayIDs
                    self.dynamicFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
                
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                        MBProgressHUD.hideHUDForView(cell, animated: true)
                    }
                    self.tableView.reloadData()
                }
            }
            
            do {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                try TMDBManager.sharedInstance.moviesByGenre(genreID!, completion: completion)
                
            } catch {
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                    MBProgressHUD.hideHUDForView(cell, animated: true)
                }
                dynamicFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", dataDict[genreName!] as! [NSNumber])
                tableView.reloadData()
            }
        
        } else {
            if let genreIDs = dataDict[genreName!] as? [NSNumber] {
                dynamicFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", genreIDs)
            }
            tableView.reloadData()
        }
    }
    
    func loadFavorites() {
        favoritesFetchRequest = NSFetchRequest(entityName: "Movie")
        favoritesFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        favoritesFetchRequest!.sortDescriptors = [
            NSSortDescriptor(key: "releaseDate", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)]
        
        if TMDBManager.sharedInstance.needsRefresh(TMDBConstants.Device.Keys.FavoriteMovies) {
            if TMDBManager.sharedInstance.hasSessionID() {
                let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                    performUIUpdatesOnMain {
                        if let error = error {
                            TMDBManager.sharedInstance.deleteRefreshData(TMDBConstants.Device.Keys.FavoriteMovies)
                            JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                        }
                        
                        self.favoritesFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
                    
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                            MBProgressHUD.hideHUDForView(cell, animated: true)
                        }
                        self.tableView.reloadData()
                    }
                }
                
                do {
                    if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                        MBProgressHUD.showHUDAddedTo(cell, animated: true)
                    }
                    try TMDBManager.sharedInstance.accountFavoriteMovies(completion)
                    
                } catch {
                    favoritesFetchRequest!.predicate = NSPredicate(format: "favorite = %@", NSNumber(bool: true))
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                        MBProgressHUD.hideHUDForView(cell, animated: true)
                    }
                    self.tableView.reloadData()
                }
            } else {
                favoritesFetchRequest = nil
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                    MBProgressHUD.hideHUDForView(cell, animated: true)
                }
                self.tableView.reloadData()
            }

        } else {
            if TMDBManager.sharedInstance.hasSessionID() {
                favoritesFetchRequest!.predicate = NSPredicate(format: "favorite = %@", NSNumber(bool: true))
            } else {
                favoritesFetchRequest = nil
            }
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                MBProgressHUD.hideHUDForView(cell, animated: true)
            }
            self.tableView.reloadData()
        }
    }
    
    func loadWatchlist() {
        watchlistFetchRequest = NSFetchRequest(entityName: "Movie")
        watchlistFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        watchlistFetchRequest!.sortDescriptors = [
            NSSortDescriptor(key: "releaseDate", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)]
        
        if TMDBManager.sharedInstance.needsRefresh(TMDBConstants.Device.Keys.WatchlistMovies) {
            if TMDBManager.sharedInstance.hasSessionID() {
                let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                    performUIUpdatesOnMain {
                        if let error = error {
                            TMDBManager.sharedInstance.deleteRefreshData(TMDBConstants.Device.Keys.WatchlistMovies)
                            JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                        }
                        
                        self.watchlistFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
                    
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                            MBProgressHUD.hideHUDForView(cell, animated: true)
                        }
                        self.tableView.reloadData()
                    }
                }
                
                do {
                    if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                        MBProgressHUD.showHUDAddedTo(cell, animated: true)
                    }
                    try TMDBManager.sharedInstance.accountWatchlistMovies(completion)
                    
                } catch {
                    watchlistFetchRequest!.predicate = NSPredicate(format: "watchlist = %@", NSNumber(bool: true))
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                        MBProgressHUD.hideHUDForView(cell, animated: true)
                    }
                    self.tableView.reloadData()
                }
            } else {
                watchlistFetchRequest = nil
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                    MBProgressHUD.hideHUDForView(cell, animated: true)
                }
                self.tableView.reloadData()
            }
            
        } else {
            if TMDBManager.sharedInstance.hasSessionID() {
                watchlistFetchRequest!.predicate = NSPredicate(format: "watchlist = %@", NSNumber(bool: true))
            } else {
                watchlistFetchRequest = nil
            }
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                MBProgressHUD.hideHUDForView(cell, animated: true)
            }
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
        case 1:
            cell.titleLabel.text = "Favorites"
            cell.fetchRequest = favoritesFetchRequest
        case 2:
            cell.titleLabel.text = "Watchlist"
            cell.fetchRequest = watchlistFetchRequest
        default:
            break
        }
        
        cell.tag = indexPath.row
        cell.displayType = .Poster
        cell.captionType = .Title
        cell.delegate = self
        cell.loadData()
        return cell
    }
}

// MARK: UITableViewDelegate
extension MoviesViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.size.height / 3
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension MoviesViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        performSegueWithIdentifier("showSeeAllFromMovies", sender: tag)
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable, path: NSIndexPath) {
        performSegueWithIdentifier("showMovieDetailsFromMovies", sender: displayable)
    }
}
