//
//  FeaturedViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

import CoreData
import JJJUtils
import MBProgressHUD

class FeaturedViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var nowShowingFetchRequest:NSFetchRequest?
    var airingTodayFetchRequest:NSFetchRequest?
    var popularPeopleFetchRequest:NSFetchRequest?
    private var dataDict = [String: [AnyObject]]()
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        let completion = { (error: NSError?) in
            if let error = error {
                performUIUpdatesOnMain {
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                }
            }
        }
        
        do {
            try TMDBManager.sharedInstance.downloadInitialData(completion)
        } catch {}
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadFeaturedMovies()
        loadFeaturedTVShows()
        loadFeaturedPeople()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMovieDetailsFromFeatured" {
            if let detailsVC = segue.destinationViewController as? MovieDetailsViewController {
                let movie = sender as! Movie
                detailsVC.movieID = movie.objectID
            }
        } else if segue.identifier == "showTVShowDetailsFromFeatured" {
            if let detailsVC = segue.destinationViewController as? TVShowDetailsViewController {
                let tvShow = sender as! TVShow
                detailsVC.tvShowID = tvShow.objectID
            }
        } else if segue.identifier == "showPersonDetailsFromFeatured" {
            if let detailsVC = segue.destinationViewController as? PersonDetailsViewController {
                let person = sender as! Person
                detailsVC.personID = person.objectID
            }
        } else if segue.identifier == "showSeeAllFromFeatured" {
            if let detailsVC = segue.destinationViewController as? SeeAllViewController {
                var title:String?
                var fetchRequest:NSFetchRequest?
                var displayType:DisplayType?
                var captionType:CaptionType?
                var showCaption = false
                
                switch sender as! Int {
                case 0:
                    title = "Now Showing"
                    fetchRequest = nowShowingFetchRequest
                    displayType = .Poster
                    captionType = .Title
                case 1:
                    title = "Airing Today"
                    fetchRequest = airingTodayFetchRequest
                    displayType = .Poster
                    captionType = .Title
                case 2:
                    title = "Popular People"
                    fetchRequest = popularPeopleFetchRequest
                    displayType = .Profile
                    captionType = .Name
                    showCaption = true
                default:
                    return
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
    func loadFeaturedMovies() {
        nowShowingFetchRequest = NSFetchRequest(entityName: "Movie")
        nowShowingFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        nowShowingFetchRequest!.sortDescriptors = [
            NSSortDescriptor(key: "releaseDate", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)]
        
        if TMDBManager.sharedInstance.needsRefresh(TMDBConstants.Device.Keys.MoviesNowShowing) {
            let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        TMDBManager.sharedInstance.deleteRefreshData(TMDBConstants.Device.Keys.MoviesNowShowing)
                            JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    self.dataDict[TMDBConstants.Device.Keys.MoviesNowShowing] = arrayIDs
                    self.nowShowingFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
                
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
                try TMDBManager.sharedInstance.movies(TMDBConstants.Movies.NowPlaying.Path, completion: completion)
                
            } catch {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                nowShowingFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", dataDict[TMDBConstants.Device.Keys.MoviesNowShowing] as! [NSNumber])
                tableView.reloadData()
            }
        
        } else {
            nowShowingFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", dataDict[TMDBConstants.Device.Keys.MoviesNowShowing] as! [NSNumber])
            tableView.reloadData()
        }
    }
    
    func loadFeaturedTVShows() {
        airingTodayFetchRequest = NSFetchRequest(entityName: "TVShow")
        airingTodayFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        airingTodayFetchRequest!.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)]
        
        if TMDBManager.sharedInstance.needsRefresh(TMDBConstants.Device.Keys.TVShowsAiringToday) {
            let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        TMDBManager.sharedInstance.deleteRefreshData(TMDBConstants.Device.Keys.TVShowsAiringToday)
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    self.dataDict[TMDBConstants.Device.Keys.TVShowsAiringToday] = arrayIDs
                    self.airingTodayFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", arrayIDs)
                
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
                try TMDBManager.sharedInstance.tvShows(TMDBConstants.TVShows.AiringToday.Path, completion: completion)
                
            } catch {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                
                airingTodayFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", dataDict[TMDBConstants.Device.Keys.TVShowsAiringToday] as! [NSNumber])
                tableView.reloadData()
            }
        
        } else {
            airingTodayFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", dataDict[TMDBConstants.Device.Keys.TVShowsAiringToday] as! [NSNumber])
            tableView.reloadData()
        }
    }
    
    func loadFeaturedPeople() {
        popularPeopleFetchRequest = NSFetchRequest(entityName: "Person")
        popularPeopleFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
        popularPeopleFetchRequest!.sortDescriptors = [
            NSSortDescriptor(key: "popularity", ascending: false),
            NSSortDescriptor(key: "name", ascending: true)]
        
        if TMDBManager.sharedInstance.needsRefresh(TMDBConstants.Device.Keys.PeoplePopular) {
            let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        TMDBManager.sharedInstance.deleteRefreshData(TMDBConstants.Device.Keys.PeoplePopular)
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    self.dataDict[TMDBConstants.Device.Keys.PeoplePopular] = arrayIDs
                    self.popularPeopleFetchRequest!.predicate = NSPredicate(format: "personID IN %@", arrayIDs)
                
                
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
                try TMDBManager.sharedInstance.peoplePopular(completion)
                
            } catch {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                popularPeopleFetchRequest!.predicate = NSPredicate(format: "personID IN %@", dataDict[TMDBConstants.Device.Keys.PeoplePopular] as! [NSNumber])
                tableView.reloadData()
            }
            
        } else {
            popularPeopleFetchRequest!.predicate = NSPredicate(format: "personID IN %@", dataDict[TMDBConstants.Device.Keys.PeoplePopular] as! [NSNumber])
            tableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSource
extension FeaturedViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ThumbnailTableViewCell
        
        switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Now Showing"
                cell.fetchRequest = nowShowingFetchRequest
                cell.displayType = .Poster
                cell.captionType = .Title
            case 1:
                cell.titleLabel.text = "Airing Today"
                cell.fetchRequest = airingTodayFetchRequest
                cell.displayType = .Poster
                cell.captionType = .Title
            case 2:
                cell.titleLabel.text = "Popular People"
                cell.fetchRequest = popularPeopleFetchRequest
                cell.displayType = .Profile
                cell.captionType = .Name
                cell.showCaption = true
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
extension FeaturedViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.size.height / 3
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension FeaturedViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        performSegueWithIdentifier("showSeeAllFromFeatured", sender: tag)
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable, path: NSIndexPath) {
        switch tag {
        case 0:
            performSegueWithIdentifier("showMovieDetailsFromFeatured", sender: displayable)
        case 1:
            performSegueWithIdentifier("showTVShowDetailsFromFeatured", sender: displayable)
        case 2:
            performSegueWithIdentifier("showPersonDetailsFromFeatured", sender: displayable)
        default:
            ()
        }
    }
}