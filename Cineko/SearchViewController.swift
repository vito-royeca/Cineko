//
//  SearchViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 26/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import JJJUtils
import MBProgressHUD
import MMDrawerController

class SearchViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var moviesFetchRequest:NSFetchRequest?
    var tvShowsFetchRequest:NSFetchRequest?
    var peopleFetchRequest:NSFetchRequest?

    // MARK: Actions
    @IBAction func menuAction(sender: UIBarButtonItem) {
        if let navigationVC = mm_drawerController.rightDrawerViewController as? UINavigationController {
            var searchSettings:SearchSettingsViewController?
            
            for drawer in navigationVC.viewControllers {
                if drawer is SearchSettingsViewController {
                    searchSettings = drawer as? SearchSettingsViewController
                }
            }
            if searchSettings == nil {
                searchSettings = SearchSettingsViewController()
                navigationVC.addChildViewController(searchSettings!)
            }
            
            navigationVC.popToViewController(searchSettings!, animated: true)
        }
        mm_drawerController.toggleDrawerSide(.Right, animated:true, completion:nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        // add a done button to the keyboard
        let barButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: searchBar, action: #selector(resignFirstResponder))
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, searchBar.frame.size.width, 44))
        toolbar.items = [barButton]
        searchBar.inputAccessoryView = toolbar
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let tableView = tableView {
            tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMovieDetailsFromSearch" {
            if let detailsVC = segue.destinationViewController as? MovieDetailsViewController {
                let movie = sender as! Movie
                detailsVC.movieOID = movie.objectID
            }
        } else if segue.identifier == "showTVShowDetailsFromSearch" {
            if let detailsVC = segue.destinationViewController as? TVShowDetailsViewController {
                let tvShow = sender as! TVShow
                detailsVC.tvShowOID = tvShow.objectID
            }
        } else if segue.identifier == "showPersonDetailsFromSearch" {
            if let detailsVC = segue.destinationViewController as? PersonDetailsViewController {
                let person = sender as! Person
                detailsVC.personOID = person.objectID
            }
        } else if segue.identifier == "showSeeAllFromSearch" {
            if let detailsVC = segue.destinationViewController as? SeeAllViewController {
                var title:String?
                var fetchRequest:NSFetchRequest?
                var displayType:DisplayType?
                var captionType:CaptionType?
                var showCaption = false
                
                switch sender as! Int {
                case 0:
                    title = "Movies"
                    fetchRequest = moviesFetchRequest
                    displayType = .Poster
                    captionType = .Title
                case 1:
                    title = "TV Shows"
                    fetchRequest = tvShowsFetchRequest
                    displayType = .Poster
                    captionType = .Title
                case 2:
                    title = "People"
                    fetchRequest = peopleFetchRequest
                    displayType = .Profile
                    captionType = .Name
                    showCaption = true
                default:
                    ()
                }
                
                detailsVC.navigationItem.title = title
                detailsVC.fetchRequest = fetchRequest
                detailsVC.displayType = displayType
                detailsVC.captionType = captionType
                detailsVC.showCaption = showCaption
                detailsVC.view.tag = sender as! Int
                detailsVC.delegate = self
            }
        }
    }
    
    // MARK: Custom Methods
    func searchMovies(query: String) {
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            performUIUpdatesOnMain {
                if let error = error {
                    self.moviesFetchRequest = nil
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    
                } else {
                    self.moviesFetchRequest = NSFetchRequest(entityName: "Movie")
                    self.moviesFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                    self.moviesFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
                    self.moviesFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "popularity", ascending: false),
                        NSSortDescriptor(key: "title", ascending: true)]
                }
            
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                    MBProgressHUD.hideHUDForView(cell, animated: true)
                }
                self.tableView.reloadData()
            }
        }
        
        do {
            let year = NSUserDefaults.standardUserDefaults().integerForKey(SearchSettingsKeys.MovieYearReleased)
            let includeMovieYearReleased = NSUserDefaults.standardUserDefaults().boolForKey(SearchSettingsKeys.MovieIncludeYearReleased)
            let includeAdult = NSUserDefaults.standardUserDefaults().boolForKey(SearchSettingsKeys.MovieIncludeAdult)
            
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                MBProgressHUD.showHUDAddedTo(cell, animated: true)
            }
            try TMDBManager.sharedInstance.searchMovie(query, releaseYear: includeMovieYearReleased ? year : 0, includeAdult: includeAdult, completion: completion)
            
        } catch {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                MBProgressHUD.hideHUDForView(cell, animated: true)
            }
            self.moviesFetchRequest = nil
            self.tableView.reloadData()
        }
    }
    
    func searchTVShows(query: String) {
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            performUIUpdatesOnMain {
                if let error = error {
                    self.tvShowsFetchRequest = nil
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    
                } else {
                    self.tvShowsFetchRequest = NSFetchRequest(entityName: "TVShow")
                    self.tvShowsFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                    self.tvShowsFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", arrayIDs)
                    self.tvShowsFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "popularity", ascending: false),
                        NSSortDescriptor(key: "name", ascending: true)]
                }
            
            
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                    MBProgressHUD.hideHUDForView(cell, animated: true)
                }
                self.tableView.reloadData()
            }
        }
        
        do {
            let year = NSUserDefaults.standardUserDefaults().integerForKey(SearchSettingsKeys.TVShowFirstAirDate)
            let includeTVShowFirstAirDate = NSUserDefaults.standardUserDefaults().boolForKey(SearchSettingsKeys.TVShowIncludeFirstAirDate)
            
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                MBProgressHUD.showHUDAddedTo(cell, animated: true)
            }
            try TMDBManager.sharedInstance.searchTVShow(query, firstAirDate: includeTVShowFirstAirDate ? year : 0, completion: completion)
            
        } catch {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                MBProgressHUD.hideHUDForView(cell, animated: true)
            }
            self.tvShowsFetchRequest = nil
            self.tableView.reloadData()
        }
    }
    
    func searchPeople(query: String) {
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            performUIUpdatesOnMain {
                if let error = error {
                    self.peopleFetchRequest = nil
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    
                } else {
                    self.peopleFetchRequest = NSFetchRequest(entityName: "Person")
                    self.peopleFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                    self.peopleFetchRequest!.predicate = NSPredicate(format: "personID IN %@", arrayIDs)
                    self.peopleFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "popularity", ascending: false),
                        NSSortDescriptor(key: "name", ascending: true)]
                }
            
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                    MBProgressHUD.hideHUDForView(cell, animated: true)
                }
                self.tableView.reloadData()
            }
        }
        
        do {
            let includeAdult = NSUserDefaults.standardUserDefaults().boolForKey(SearchSettingsKeys.PeopleIncludeAdult)
            
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                MBProgressHUD.showHUDAddedTo(cell, animated: true)
            }
            try TMDBManager.sharedInstance.searchPeople(query, includeAdult: includeAdult, completion: completion)
            
        } catch {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                MBProgressHUD.hideHUDForView(cell, animated: true)
            }
            self.peopleFetchRequest = nil
            self.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSource
extension SearchViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ThumbnailTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Movies"
            cell.fetchRequest = moviesFetchRequest
            cell.displayType = .Poster
            cell.captionType = .Title
        case 1:
            cell.titleLabel.text = "TV Shows"
            cell.fetchRequest = tvShowsFetchRequest
            cell.displayType = .Poster
            cell.captionType = .Title
        case 2:
            cell.titleLabel.text = "People"
            cell.fetchRequest = peopleFetchRequest
            cell.displayType = .Profile
            cell.captionType = .Name
            cell.showCaption = true
        default:
            ()
        }
        
        cell.tag = indexPath.row
        cell.delegate = self
        cell.loadData()
        return cell
    }
}

// MARK: UITableViewDelegate
extension SearchViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.size.height / 3
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension SearchViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        performSegueWithIdentifier("showSeeAllFromSearch", sender: tag)
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable, path: NSIndexPath) {
        switch tag {
        case 0:
            performSegueWithIdentifier("showMovieDetailsFromSearch", sender: displayable)
        case 1:
            performSegueWithIdentifier("showTVShowDetailsFromSearch", sender: displayable)
        case 2:
            performSegueWithIdentifier("showPersonDetailsFromSearch", sender: displayable)
        default:
            ()
        }
    }
}

// MARK: UISearchBarDelegate
extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let text = searchBar.text {
            if !text.isEmpty {
                searchMovies(text)
                searchTVShows(text)
                searchPeople(text)
            }
        }
    }
}
