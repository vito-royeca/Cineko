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
import MBProgressHUD
import SDWebImage

class MovieDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var watchlistButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var rateButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var movieID:NSManagedObjectID?
    var backdropFetchRequest:NSFetchRequest?
    var posterFetchRequest:NSFetchRequest?
    
    // MARK: Actions
    @IBAction func watchlistAction(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func favoriteAction(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func rateAction(sender: UIBarButtonItem) {
        
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "titleTableViewCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "clearTableViewCell")
        tableView.registerNib(UINib(nibName: "MediaInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "mediaInfoTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "photosTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "postersTableViewCell")
        
        if TMDBManager.sharedInstance().hasSessionID() {
            watchlistButton.enabled = true
            favoriteButton.enabled = true
            rateButton.enabled = true
        }
        
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
            let url = NSURL(string: "\(TMDBConstants.ImageURL)/\(TMDBConstants.PosterSizes[3])\(movie.posterPath!)")
            let backgroundView = UIImageView()
            tableView.backgroundView = backgroundView
            backgroundView.sd_setImageWithURL(url)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadDetails()
        loadPhotos()
    }

    // MARK: Custom Methods
    func loadDetails() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                if let error = error {
                    performUIUpdatesOnMain {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                } else {
                    performUIUpdatesOnMain {
                        self.tableView.reloadData()
                    }
                }
            }
            
            do {
                try TMDBManager.sharedInstance().movieDetails(movie.movieID!, completion: completion)
            } catch {}
        }
    }
    
    func loadPhotos() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                if let error = error {
                    performUIUpdatesOnMain {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                } else {
                    self.backdropFetchRequest = NSFetchRequest(entityName: "Image")
                    self.backdropFetchRequest!.predicate = NSPredicate(format: "movieBackdrop = %@", movie)
                    self.backdropFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "voteAverage", ascending: false)]
                    
                    self.posterFetchRequest = NSFetchRequest(entityName: "Image")
                    self.posterFetchRequest!.predicate = NSPredicate(format: "moviePoster = %@", movie)
                    self.posterFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "voteAverage", ascending: false)]
                    
                    performUIUpdatesOnMain {
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? ThumbnailTableViewCell {
                            MBProgressHUD.hideHUDForView(cell, animated: true)
                        }
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as? ThumbnailTableViewCell {
                            MBProgressHUD.hideHUDForView(cell, animated: true)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            
            do {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? ThumbnailTableViewCell {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as? ThumbnailTableViewCell {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                try TMDBManager.sharedInstance().movieImages(movie.movieID!, completion: completion)
            } catch {}
        }
    }

    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            if let c = cell as? DynamicHeightTableViewCell {
                if let movieID = movieID {
                    let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
                    
                    if let title = movie.title {
                        c.dynamicLabel.text = title
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
                    }
                }
            }
        case 1:
            cell.contentView.backgroundColor = UIColor.clearColor()
            if let backgroundView = cell.backgroundView {
                backgroundView.backgroundColor = UIColor.clearColor()
            }
            cell.backgroundColor = UIColor.clearColor()
        case 2:
            if let c = cell as? MediaInfoTableViewCell {
                if let movieID = movieID {
                    let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
                    
                    if let releaseDate = movie.releaseDate {
                        c.dateLabel.text = releaseDate
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
                    let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
                    
                    if let overview = movie.overview {
                        c.dynamicLabel.text = overview
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                    }
                }
            }
        case 4:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = 0
                c.titleLabel.text = "Photos"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.hidden = true
                c.fetchRequest = backdropFetchRequest
                c.displayType = .Backdrop
                c.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.95)
                c.loadData()
            }
        case 5:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = 4
                c.titleLabel.text = "Posters"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.hidden = true
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
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("titleTableViewCell", forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("clearTableViewCell", forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("mediaInfoTableViewCell", forIndexPath: indexPath)
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
        case 5:
            cell = tableView.dequeueReusableCellWithIdentifier("postersTableViewCell", forIndexPath: indexPath)
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
        
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
            return movie.title
        }
        return nil
    }
}

extension MovieDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return dynamicHeightForCell("titleTableViewCell", indexPath: indexPath)
        case 1:
            return 180
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return dynamicHeightForCell("overviewTableViewCell", indexPath: indexPath)
        case 4:
            return ThumbnailTableViewCell.Height
        case 5:
            return ThumbnailTableViewCell.Height
        default:
            return UITableViewAutomaticDimension
        }
    }
}
