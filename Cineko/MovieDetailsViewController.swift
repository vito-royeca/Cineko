//
//  MovieDetailsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 08/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import JJJUtils
import SDWebImage
import Sync


class MovieDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var movieID:NSManagedObjectID?
    var backdropFetchRequest:NSFetchRequest?
    var posterFetchRequest:NSFetchRequest?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.registerNib(UINib(nibName: "ActionTableViewCell", bundle: nil), forCellReuseIdentifier: "actionTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "titleTableViewCell")
        tableView.registerNib(UINib(nibName: "MediaInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "mediaInfoTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "photosTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "postersTableViewCell")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MovieDetailsViewController.changeNotification(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: CoreDataManager.sharedInstance().managedObjectContext)
        
        loadDetails()
        loadPhotos()
    }

    // MARK: Custom Methods
    func changeNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let deletedObjects   = userInfo[NSDeletedObjectsKey]
            let insertedObjects  = userInfo[NSInsertedObjectsKey]
            let updatedObjects  = userInfo[NSUpdatedObjectsKey]
            
            print("inserted: \(insertedObjects)")
            print("deleted: \(deletedObjects)")
            print("updated: \(updatedObjects)")
        }
    }

    
    func loadDetails() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().managedObjectContext.objectWithID(movieID) as! Movie
            let success = { (results: AnyObject!) in
                if let dict = results as? [String: AnyObject] {
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    let completion = { (error: NSError?) in
                        self.tableView.reloadData()
                    }
                    let predicate = NSPredicate(format: "movieID=%@", movie.movieID!)
                    
                    Sync.changes([dict], inEntityNamed: "Movie", predicate: predicate, dataStack: appDelegate.dataStack, completion: completion)
                }
            }
            
            let failure = { (error: NSError?) in
                performUIUpdatesOnMain {
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
                }
            }
            
            do {
                try TMDBManager.sharedInstance().moviesID(movie.movieID!, success: success, failure: failure)
            } catch {}
        }
    }
    
    func loadPhotos() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().managedObjectContext.objectWithID(movieID) as! Movie
            
            let success = { (results: AnyObject!) in
                if let dict = results as? [String: AnyObject] {
                    var backdrops = [[String: AnyObject]]()
                    var posters = [[String: AnyObject]]()
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    if let json = dict["backdrops"] as? [[String: AnyObject]] {
                        backdrops = json
                    }
                    if let json = dict["posters"] as? [[String: AnyObject]] {
                        posters = json
                    }
                    
                    let completion = { (error: NSError?) in
                        if error == nil {
                            self.backdropFetchRequest = NSFetchRequest(entityName: "Image")
                            self.backdropFetchRequest!.predicate = NSPredicate(format: "movieBackdrop = %@", movie)
                            self.backdropFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                            self.backdropFetchRequest!.sortDescriptors = [
                                NSSortDescriptor(key: "voteAverage", ascending: false)]
                            
                            self.posterFetchRequest = NSFetchRequest(entityName: "Image")
                            self.posterFetchRequest!.predicate = NSPredicate(format: "moviePoster = %@", movie)
                            self.posterFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                            self.posterFetchRequest!.sortDescriptors = [
                                NSSortDescriptor(key: "voteAverage", ascending: false)]
                            
                            self.tableView.reloadData()
                        }
                    }
                    
                    var syncData = [[String: AnyObject]]()
                    syncData.append(["id": movie.movieID!.integerValue,
                                 "backdrops": backdrops,
                                 "posters": posters])
                    let predicate = NSPredicate(format: "movieID=%@ ", movie.movieID!)
                    Sync.changes(syncData, inEntityNamed: "Movie", predicate: predicate, dataStack: appDelegate.dataStack, completion: completion)
                    
//                    syncData = [[String: AnyObject]]()
//                    syncData.append(["id": movie.movieID!.integerValue,
//                        "posters": posters])
//                    Sync.changes(syncData, inEntityNamed: "Movie", predicate: predicate, dataStack: appDelegate.dataStack, completion: completion)
                }
            }
            
            let failure = { (error: NSError?) in
                performUIUpdatesOnMain {
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
                }
            }
            
            do {
                try TMDBManager.sharedInstance().moviesImages(movie.movieID!, success: success, failure: failure)
            } catch {}
        }
    }

//    func getImages(predicate: NSPredicate) -> [[String: AnyObject]] {
//        let fetchRequest = NSFetchRequest(entityName: "Image")
//        fetchRequest.predicate = predicate
//        fetchRequest.fetchLimit = ThumbnailTableViewCell.MaxItems
//        var returnData = [[String: AnyObject]]()
//        
//        do {
//            let images = try CoreDataManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest) as! [Image]
//            
//            for image in images {
//                var data = [String: AnyObject]()
//                data[ThumbnailTableViewCell.Keys.ID] = image.filePath as String!
//                data[ThumbnailTableViewCell.Keys.OID] = image.objectID
//                
//                if let filePath = image.filePath {
//                    let url = "\(TMDBConstants.ImageURL)/\(TMDBConstants.BackdropSizes[0])\(filePath)"
//                    data[ThumbnailTableViewCell.Keys.URL] = url
//                }
//                
//                returnData.append(data)
//            }
//            self.tableView.reloadData()
//        } catch let error as NSError {
//            print("\(error.userInfo)")
//        }
//        
//        return returnData
//    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            if let c = cell as? DynamicHeightTableViewCell {
                if let movieID = movieID {
                    let movie = CoreDataManager.sharedInstance().managedObjectContext.objectWithID(movieID) as! Movie
                    
                    if let title = movie.title {
                        c.dynamicLabel.text = title
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
                    }
                }
            }
        case 1:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = 0
                c.titleLabel.text = "Photos"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                c.fetchRequest = backdropFetchRequest
                c.displayType = .Backdrop
                c.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.95)
                c.loadData()
            }
        case 2:
            if let c = cell as? MediaInfoTableViewCell {
                if let movieID = movieID {
                    let movie = CoreDataManager.sharedInstance().managedObjectContext.objectWithID(movieID) as! Movie
                    
                    if let releaseDate = movie.releaseDate {
                        c.releaseDateLabel.text = releaseDate
                    }
                    c.durationLabel.text = movie.runtimeToString()
                    if let voteAverage = movie.voteAverage {
                        c.ratingLabel.text = NSString(format: "%.1f", voteAverage.doubleValue) as String
                    }

                }
            }
        case 3:
            if let c = cell as? DynamicHeightTableViewCell {
                if let movieID = movieID {
                    let movie = CoreDataManager.sharedInstance().managedObjectContext.objectWithID(movieID) as! Movie
                    
                    if let overview = movie.overview {
                        c.dynamicLabel.text = overview
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                    }
                }
            }
        
        case 4:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = 4
                c.titleLabel.text = "Posters"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                c.fetchRequest = posterFetchRequest
                c.displayType = .Poster
                c.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.95)
                c.loadData()
            }
        default:
            return
        }
    }
    
    func dynamicHeightForCell(identifier: String, indexPath: NSIndexPath) -> CGFloat {
        if let cell = tableView.dequeueReusableCellWithIdentifier(identifier) {
            configureCell(cell, indexPath: indexPath)
            cell.layoutIfNeeded()
            let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            return size.height
        } else {
            return UITableViewAutomaticDimension
        }
    }
}

extension MovieDetailsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("titleTableViewCell", forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("mediaInfoTableViewCell", forIndexPath: indexPath)
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier("postersTableViewCell", forIndexPath: indexPath)
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
        
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
}

extension MovieDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return dynamicHeightForCell("titleTableViewCell", indexPath: indexPath)
        case 1:
            return ThumbnailTableViewCell.Height
        case 3:
            return dynamicHeightForCell("overviewTableViewCell", indexPath: indexPath)
        case 4:
            return ThumbnailTableViewCell.Height
        default:
            return UITableViewAutomaticDimension
        }
    }
}
