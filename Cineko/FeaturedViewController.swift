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
import DATAStack
import Sync

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
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]],
                    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {

                    // save the movieIDs
                    var movieIDs = [NSNumber]()
                    for movie in json {
                        for (key,value) in movie {
                            if key == "id" {
                                movieIDs.append(value as! NSNumber)
                            }
                        }
                    }
                    
                    let completion = { (error: NSError?) in
                        if error == nil {
                            self.nowShowingFetchRequest = NSFetchRequest(entityName: "Movie")
                            self.nowShowingFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", movieIDs)
                            self.nowShowingFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                            self.nowShowingFetchRequest!.sortDescriptors = [
                                NSSortDescriptor(key: "releaseDate", ascending: true),
                                NSSortDescriptor(key: "title", ascending: true)]
                            self.tableView.reloadData()
                            
                        }
                    }
                    
                    Sync.changes(json, inEntityNamed: "Movie", dataStack: appDelegate.dataStack, completion: completion)
                }
            }
        }
        
        let failure = { (error: NSError?) in
            performUIUpdatesOnMain {
                JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
            }
        }
        
        do {
            try TMDBManager.sharedInstance().moviesNowPlaying(success, failure: failure)
        } catch {}
    }
    
    func loadFeaturedTVShows() {
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]],
                    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    
                    // save the tvIDs
                    var tvIDs = [NSNumber]()
                    for tvShow in json {
                        for (key,value) in tvShow {
                            if key == "id" {
                                tvIDs.append(value as! NSNumber)
                            }
                        }
                    }
                    
                    let completion = { (error: NSError?) in
                        if error == nil {
                            self.airingTodayFetchRequest = NSFetchRequest(entityName: "TVShow")
                            self.airingTodayFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", tvIDs)
                            self.airingTodayFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                            self.airingTodayFetchRequest!.sortDescriptors = [
                                NSSortDescriptor(key: "name", ascending: true)]
                            self.tableView.reloadData()
                        }
                    }
                    
                    Sync.changes(json, inEntityNamed: "TVShow", dataStack: appDelegate.dataStack, completion: completion)
                }
            }
        }
        
        let failure = { (error: NSError?) in
            performUIUpdatesOnMain {
                JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
            }
        }
        
        do {
            try TMDBManager.sharedInstance().tvShowsAiringToday(success, failure: failure)
        } catch {}
    }
    
    func loadFeaturedPeople() {
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]],
                    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    
                    // save the tvIDs
                    var peopleIDs = [NSNumber]()
                    for people in json {
                        for (key,value) in people {
                            if key == "id" {
                                peopleIDs.append(value as! NSNumber)
                            }
                        }
                    }
                    
                    let completion = { (error: NSError?) in
                        if error == nil {
                            self.popularPeopleFetchRequest = NSFetchRequest(entityName: "Person")
                            self.popularPeopleFetchRequest!.predicate = NSPredicate(format: "personID IN %@", peopleIDs)
                            self.popularPeopleFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                            self.popularPeopleFetchRequest!.sortDescriptors = [
                                NSSortDescriptor(key: "popularity", ascending: false),
                                NSSortDescriptor(key: "name", ascending: true)]
                            self.tableView.reloadData()
                            
//                            do {
//                                self.peopleData = [[String: AnyObject]]()
//                                let people = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Person]
//                                
//                                for person in people {
//                                    var data = [String: AnyObject]()
//                                    data[ThumbnailTableViewCell.Keys.ID] = person.personID! as Int
//                                    data[ThumbnailTableViewCell.Keys.OID] = person.objectID
//                                    data[ThumbnailTableViewCell.Keys.Caption] = person.name
//                                    
//                                    if let profilePath = person.profilePath {
//                                        let url = "\(TMDBConstants.ImageURL)/\(TMDBConstants.ProfileSizes[1])\(profilePath)"
//                                        data[ThumbnailTableViewCell.Keys.URL] = url
//                                    }
//                                    
//                                    self.peopleData!.append(data)
//                                }
//                                self.tableView.reloadData()
//                            } catch let error as NSError {
//                                print("\(error.userInfo)")
//                            }
                        }
                    }
                    
                    Sync.changes(json, inEntityNamed: "Person", dataStack: appDelegate.dataStack, completion: completion)
                }
            }
        }
        
        let failure = { (error: NSError?) in
            performUIUpdatesOnMain {
                JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
            }
        }
        
        do {
            try TMDBManager.sharedInstance().peoplePopular(success, failure: failure)
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