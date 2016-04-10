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
    var movieData:[[String: AnyObject]]?
    var tvData:[[String: AnyObject]]?
    var peopleData:[[String: AnyObject]]?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // TLYShyNavBar
//        var insets = tableView.contentInset
//        insets.bottom = 0
        shyNavBarManager.scrollView = tableView
        
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
                            let fetchRequest = NSFetchRequest(entityName: "Movie")
                            fetchRequest.predicate = NSPredicate(format: "movieID IN %@", movieIDs)
                            fetchRequest.fetchLimit = ThumbnailTableViewCell.MaxItems
                            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: true),
                                NSSortDescriptor(key: "title", ascending: true)]
                            
                            do {
                                self.movieData = [[String: AnyObject]]()
                                let movies = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Movie]
                                
                                for movie in movies {
                                    var data = [String: AnyObject]()
                                    data[ThumbnailTableViewCell.Keys.ID] = movie.movieID! as Int
                                    
                                    if let posterPath = movie.posterPath {
                                        let url = "\(Constants.TMDB.ImageURL)/\(Constants.TMDB.PosterSizes[0])\(posterPath)"
                                        data[ThumbnailTableViewCell.Keys.URL] = url
                                    }
                                    
                                    self.movieData!.append(data)
                                }
                                self.tableView.reloadData()
                            } catch let error as NSError {
                                print("\(error.userInfo)")
                            }
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
        
        TMDBManager.sharedInstance().moviesNowPlaying(success, failure: failure)
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
                            let fetchRequest = NSFetchRequest(entityName: "TVShow")
                            fetchRequest.predicate = NSPredicate(format: "tvShowID IN %@", tvIDs)
                            fetchRequest.fetchLimit = ThumbnailTableViewCell.MaxItems
                            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                            
                            do {
                                self.tvData = [[String: AnyObject]]()
                                let tvShows = try self.sharedContext.executeFetchRequest(fetchRequest) as! [TVShow]
                                
                                for tvShow in tvShows {
                                    var data = [String: AnyObject]()
                                    data[ThumbnailTableViewCell.Keys.ID] = tvShow.tvShowID! as Int
                                    
                                    if let posterPath = tvShow.posterPath {
                                        let url = "\(Constants.TMDB.ImageURL)/\(Constants.TMDB.PosterSizes[0])\(posterPath)"
                                        data[ThumbnailTableViewCell.Keys.URL] = url
                                    }
                                    
                                    self.tvData!.append(data)
                                }
                                self.tableView.reloadData()
                            } catch let error as NSError {
                                print("\(error.userInfo)")
                            }
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
        
        TMDBManager.sharedInstance().tvShowsAiringToday(success, failure: failure)
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
                            let fetchRequest = NSFetchRequest(entityName: "Person")
                            fetchRequest.predicate = NSPredicate(format: "personID IN %@", peopleIDs)
                            fetchRequest.fetchLimit = ThumbnailTableViewCell.MaxItems
                            fetchRequest.sortDescriptors = [
                                NSSortDescriptor(key: "popularity", ascending: false),
                                NSSortDescriptor(key: "name", ascending: true)]
                            
                            do {
                                self.peopleData = [[String: AnyObject]]()
                                let people = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Person]
                                
                                for person in people {
                                    var data = [String: AnyObject]()
                                    data[ThumbnailTableViewCell.Keys.ID] = person.personID! as Int
                                    
                                    if let profilePath = person.profilePath {
                                        let url = "\(Constants.TMDB.ImageURL)/\(Constants.TMDB.ProfileSizes[1])\(profilePath)"
                                        data[ThumbnailTableViewCell.Keys.URL] = url
                                    }
                                    
                                    self.peopleData!.append(data)
                                }
                                self.tableView.reloadData()
                            } catch let error as NSError {
                                print("\(error.userInfo)")
                            }
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
        
        TMDBManager.sharedInstance().peoplePopular(success, failure: failure)
    }
    
    var sharedContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.dataStack.mainContext
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
                cell.thumbnailType = .InTheaters
                cell.titleLabel.text = "In Theaters"
                cell.data = movieData
            case 1:
                cell.thumbnailType = .OnTV
                cell.titleLabel.text = "On TV"
                cell.data = tvData
            case 2:
                cell.thumbnailType = .PopularPeople
                cell.titleLabel.text = "Popular People"
                cell.data = peopleData
            default:
                break
        }
        
        cell.collectionView.reloadData()
        cell.delegate = self
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
    func seeAllAction(type: ThumbnailType) {
        print("type = \(type)")
    }
    
    func didSelectItem(type: ThumbnailType, dict: [String: AnyObject]) {
        print("tag = \(type); \(dict)")
    }
}