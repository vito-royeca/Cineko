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
                    
                    Sync.changes(json, inEntityNamed: "Movie", dataStack: appDelegate.dataStack,
                        completion: { (error: NSError?) in
                            if error == nil {
                                let fetchRequest = NSFetchRequest(entityName: "Movie")
                                fetchRequest.predicate = NSPredicate(format: "movieID IN %@", movieIDs)
                                fetchRequest.fetchLimit = ThumbnailTableViewCell.MaxItems
                                do {
                                    self.movieData = [[String: AnyObject]]()
                                    
                                    let movies = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Movie]
                                    for movie in movies {
                                        let url = "\(Constants.TMDB.ImageURL)/\(Constants.TMDB.PosterSizes[0])\(movie.posterPath!)"
                                        var data = [String: AnyObject]()
                                        data[ThumbnailTableViewCell.Keys.ID] = movie.movieID! as Int
                                        data[ThumbnailTableViewCell.Keys.URL] = url
                                        
                                        self.movieData!.append(data)
                                    }
                                    self.tableView.reloadData()
                                } catch let error as NSError {
                                    print("\(error.userInfo)")
                                }
                            }
                        }
                    )
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
                    
                    Sync.changes(json, inEntityNamed: "TVShow", dataStack: appDelegate.dataStack,
                                 completion: { (error: NSError?) in
                                    if error == nil {
                                        let fetchRequest = NSFetchRequest(entityName: "TVShow")
                                        fetchRequest.predicate = NSPredicate(format: "tvShowID IN %@", tvIDs)
                                        fetchRequest.fetchLimit = ThumbnailTableViewCell.MaxItems
                                        do {
                                            self.tvData = [[String: AnyObject]]()
                                            
                                            let tvShows = try self.sharedContext.executeFetchRequest(fetchRequest) as! [TVShow]
                                            for tvShow in tvShows {
                                                let url = "\(Constants.TMDB.ImageURL)/\(Constants.TMDB.PosterSizes[0])\(tvShow.posterPath!)"
                                                var data = [String: AnyObject]()
                                                data[ThumbnailTableViewCell.Keys.ID] = tvShow.tvShowID! as Int
                                                data[ThumbnailTableViewCell.Keys.URL] = url
                                                
                                                self.tvData!.append(data)
                                            }
                                            self.tableView.reloadData()
                                        } catch let error as NSError {
                                            print("\(error.userInfo)")
                                        }
                                    }
                        }
                    )
                }
            }
        }
        
        let failure = { (error: NSError?) in
            performUIUpdatesOnMain {
                JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
            }
        }
        
        TMDBManager.sharedInstance().tvShowsNowPlaying(success, failure: failure)
    }
    
    var sharedContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.dataStack.mainContext
    }
}

// MARK: UITableViewDataSource
extension FeaturedViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
                cell.thumbnailType = .Lists
                cell.titleLabel.text = "Lists"
            case 3:
                cell.thumbnailType = .People
                cell.titleLabel.text = "People"
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