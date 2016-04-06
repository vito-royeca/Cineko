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
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ScrollingTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // TLYShyNavBar
        shyNavBarManager.scrollView = tableView
        
        loadFeaturedMovies()
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
                                fetchRequest.fetchLimit = ScrollingTableViewCell.MaxItems
                                do {
                                    self.movieData = [[String: AnyObject]]()
                                    
                                    let movies = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Movie]
                                    for movie in movies {
                                        let url = "\(Constants.TMDB.ImageURL)/\(Constants.TMDB.PosterSizes[0])/\(movie.posterPath!)"
                                        var data = [String: AnyObject]()
                                        data[ScrollingTableViewCell.Keys.ID] = movie.movieID! as Int
                                        data[ScrollingTableViewCell.Keys.URL] = url
                                        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ScrollingTableViewCell
        
        switch indexPath.row {
            case 0:
                cell.titleLabel.text = "In Theaters"
                cell.data = movieData
                cell.collectionView.reloadData()
            case 1:
                cell.titleLabel.text = "On TV"
            case 2:
                cell.titleLabel.text = "Lists"
            case 3:
                cell.titleLabel.text = "People"
            default:
                break
        }
        
        cell.tag = indexPath.row
        cell.delegate = self
        return cell
    }
}

// MARK: UITableViewDelegate
extension FeaturedViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ScrollingTableViewCell.Height
    }
}

// MARK: ScrollingTableViewCellDelegate
extension FeaturedViewController : ScrollingTableViewCellDelegate {
    func seeAllAction(tag: Int) {
        print("tag = \(tag)")
    }
    
    func didSelectItem(tag: Int, dict: [String: AnyObject]) {
        print("tag = \(tag); \(dict)")
    }
}