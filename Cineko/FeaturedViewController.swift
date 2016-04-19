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
    private var dataHasBeenLoaded = false
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !dataHasBeenLoaded {
            loadFeaturedMovies()
            loadFeaturedTVShows()
            loadFeaturedPeople()
            dataHasBeenLoaded = true
        }
    }
    
    // MARK: Custom Methods
    func loadFeaturedMovies() {
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.nowShowingFetchRequest = NSFetchRequest(entityName: "Movie")
            self.nowShowingFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
            self.nowShowingFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
            self.nowShowingFetchRequest!.sortDescriptors = [
                NSSortDescriptor(key: "releaseDate", ascending: true),
                NSSortDescriptor(key: "title", ascending: true)]
            
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
            
            try TMDBManager.sharedInstance().moviesNowPlaying(completion)
        } catch {}
    }
    
    func loadFeaturedTVShows() {
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.airingTodayFetchRequest = NSFetchRequest(entityName: "TVShow")
            self.airingTodayFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", arrayIDs)
            self.airingTodayFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
            self.airingTodayFetchRequest!.sortDescriptors = [
                NSSortDescriptor(key: "name", ascending: true)]
            
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
            try TMDBManager.sharedInstance().tvShowsAiringToday(completion)
        } catch {}
    }
    
    func loadFeaturedPeople() {
        let completion = { (arrayIDs: [AnyObject], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            self.popularPeopleFetchRequest = NSFetchRequest(entityName: "Person")
            self.popularPeopleFetchRequest!.predicate = NSPredicate(format: "personID IN %@", arrayIDs)
            self.popularPeopleFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
            self.popularPeopleFetchRequest!.sortDescriptors = [
                NSSortDescriptor(key: "popularity", ascending: false),
                NSSortDescriptor(key: "name", ascending: true)]
            
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
            try TMDBManager.sharedInstance().peoplePopular(completion)
        } catch {}
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
                cell.tag = indexPath.row
                cell.titleLabel.text = "Now Showing"
                cell.fetchRequest = nowShowingFetchRequest
                cell.displayType = .Poster
            case 1:
                cell.tag = indexPath.row
                cell.titleLabel.text = "Airing Today"
                cell.fetchRequest = airingTodayFetchRequest
                cell.displayType = .Poster
            case 2:
                cell.tag = indexPath.row
                cell.titleLabel.text = "Popular People"
                cell.fetchRequest = popularPeopleFetchRequest
                cell.displayType = .Profile
                cell.showCaption = true
            default:
                break
        }
        
        cell.delegate = self
        cell.loadData()
        return cell
    }
}

// MARK: UITableViewDelegate
extension FeaturedViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return tableView.frame.size.height / 3
        return ThumbnailTableViewCell.Height
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension FeaturedViewController : ThumbnailTableViewCellDelegate {
    func seeAllAction(tag: Int) {
        print("type = \(tag)")
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailTableViewCellDisplayable) {
        switch tag {
        case 0:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MovieDetailsViewController") as? MovieDetailsViewController,
                let navigationController = navigationController {
                let movie = displayable as! Movie
                controller.movieID = movie.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        case 1:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TVShowDetailsViewController") as? TVShowDetailsViewController,
                let navigationController = navigationController {
                let tvShow = displayable as! TVShow
                controller.tvShowID = tvShow.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        case 2:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PersonDetailsViewController") as? PersonDetailsViewController,
                let navigationController = navigationController {
                let person = displayable as! Person
                controller.personID = person.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        default:
            return
        }
    }
}