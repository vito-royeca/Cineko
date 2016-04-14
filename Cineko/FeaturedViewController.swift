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

class FeaturedViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var nowShowingFetchRequest:NSFetchRequest?
    var airingTodayFetchRequest:NSFetchRequest?
    var popularPeopleFetchRequest:NSFetchRequest?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        loadFeaturedMovies()
        loadFeaturedTVShows()
        loadFeaturedPeople()
    }
    
    // MARK: Custom Methods
    func loadFeaturedMovies() {
        let completion = { (arrayIDs: [AnyObject]?, error: NSError?) in
            if let error = error {
                performUIUpdatesOnMain {
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                }
                
            } else {
                self.nowShowingFetchRequest = NSFetchRequest(entityName: "Movie")
                self.nowShowingFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs!)
                self.nowShowingFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                self.nowShowingFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "releaseDate", ascending: true),
                    NSSortDescriptor(key: "title", ascending: true)]
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
        }
        
        do {
            try TMDBManager.sharedInstance().moviesNowPlaying(completion)
        } catch {}
    }
    
    func loadFeaturedTVShows() {
//        let completion = { (arrayIDs: [AnyObject]?, error: NSError?) in
//            if let error = error {
//                performUIUpdatesOnMain {
//                    JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
//                }
//                
//            } else {
//                self.airingTodayFetchRequest = NSFetchRequest(entityName: "TVShow")
//                self.airingTodayFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", arrayIDs!)
//                self.airingTodayFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
//                self.airingTodayFetchRequest!.sortDescriptors = [
//                    NSSortDescriptor(key: "name", ascending: true)]
//            performUIUpdatesOnMain {
//                self.tableView.reloadData()
//            }
//            }
//        }
//        
//        do {
//            try TMDBManager.sharedInstance().tvShowsNowAiring(completion)
//        } catch {}
    }
    
    func loadFeaturedPeople() {
//        let completion = { (arrayIDs: [AnyObject]?, error: NSError?) in
//            if let error = error {
//                performUIUpdatesOnMain {
//                    JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
//                }
//                
//            } else {
//                self.popularPeopleFetchRequest = NSFetchRequest(entityName: "Person")
//                self.popularPeopleFetchRequest!.predicate = NSPredicate(format: "personID IN %@", arrayIDs!)
//                self.popularPeopleFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
//                self.popularPeopleFetchRequest!.sortDescriptors = [
//                    NSSortDescriptor(key: "popularity", ascending: false),
//                    NSSortDescriptor(key: "name", ascending: true)]
//            performUIUpdatesOnMain {
//                self.tableView.reloadData()
//            }
//
//            }
//        }
//        
//        do {
//            try TMDBManager.sharedInstance().peoplePopular(completion)
//        } catch {}
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
                cell.tag = 0
                cell.titleLabel.text = "Now Showing"
                cell.fetchRequest = nowShowingFetchRequest
                cell.displayType = .Poster
            case 1:
                cell.tag = 1
                cell.titleLabel.text = "Airing Today"
                cell.fetchRequest = airingTodayFetchRequest
                cell.displayType = .Poster
            case 2:
                cell.tag = 2
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
            print("\(tag)")
        case 2:
            print("\(tag)")
        default:
            print("\(tag)")
        }
        
    }
}