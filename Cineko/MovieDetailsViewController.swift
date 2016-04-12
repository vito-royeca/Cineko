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
    var sharedContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.dataStack.mainContext
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.registerNib(UINib(nibName: "ActionTableViewCell", bundle: nil), forCellReuseIdentifier: "actionTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "titleTableViewCell")
        tableView.registerNib(UINib(nibName: "MediaInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "mediaInfoTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        
        if let movieID = movieID {
            let movie = sharedContext.objectWithID(movieID) as! Movie
            
            if let posterPath = movie.posterPath {
                let urlString = "\(Constants.TMDB.ImageURL)/\(Constants.TMDB.PosterSizes[4])\(posterPath)"
                let backgroundView = UIImageView(frame: tableView.frame)
                backgroundView.contentMode = .ScaleAspectFit
                tableView.backgroundView = backgroundView
                backgroundView.sd_setImageWithURL(NSURL(string: urlString))
                
//                let completed = { (image: UIImage!, data: NSData!, error: NSError!, finished: Bool) in
//                    performUIUpdatesOnMain {
//                        let backgroundView = UIImageView(image: image)
//                        backgroundView.contentMode = .ScaleAspectFit
//                        backgroundView.frame = self.tableView.frame
//                        self.tableView.backgroundView = backgroundView
//                    }
//                }
//                
//                let downloader = SDWebImageDownloader.sharedDownloader()
//                downloader.downloadImageWithURL(url, options: .LowPriority, progress: nil, completed: completed)
            }
            
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
            
            TMDBManager.sharedInstance().moviesID(movie.movieID!, success: success, failure: failure)
        }
    }

    // MARK: Custom Methods
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            if let _ = cell as? ActionTableViewCell {
            // do something
            }
            
        case 1:
            cell.backgroundColor = UIColor.clearColor()
            
        case 2:
            if let c = cell as? DynamicHeightTableViewCell {
                if let movieID = movieID {
                    let movie = sharedContext.objectWithID(movieID) as! Movie
                    
                    if let title = movie.title {
                        c.dynamicLabel.text = title
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
                    }
                }
            }
        case 3:
            if let c = cell as? MediaInfoTableViewCell {
                if let movieID = movieID {
                    let movie = sharedContext.objectWithID(movieID) as! Movie
                    
                    if let releaseDate = movie.releaseDate {
                        c.releaseDateLabel.text = releaseDate
                    }
                    c.durationLabel.text = movie.runtimeToString()
                    if let voteAverage = movie.voteAverage {
                        c.ratingLabel.text = NSString(format: "%.1f", voteAverage.doubleValue) as String
                    }

                }
            }
        case 4:
            if let c = cell as? DynamicHeightTableViewCell {
                if let movieID = movieID {
                    let movie = sharedContext.objectWithID(movieID) as! Movie
                    
                    if let overview = movie.overview {
                        c.dynamicLabel.text = overview
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                    }
                }
            }
            
        default:
            return
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
            cell = tableView.dequeueReusableCellWithIdentifier("actionTableViewCell", forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("titleTableViewCell", forIndexPath: indexPath)
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("mediaInfoTableViewCell", forIndexPath: indexPath)
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
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
        case 1:
            return CGFloat(180)
        case 2:
            if let cell = tableView.dequeueReusableCellWithIdentifier("titleTableViewCell") {
                configureCell(cell, indexPath: indexPath)
                cell.layoutIfNeeded()
                let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                return size.height
            } else {
                return UITableViewAutomaticDimension
            }
        case 4:
            if let cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell") {
                configureCell(cell, indexPath: indexPath)
                cell.layoutIfNeeded()
                let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                return size.height
            } else {
                return UITableViewAutomaticDimension
            }
        default:
            return UITableViewAutomaticDimension
        }
    }
}
