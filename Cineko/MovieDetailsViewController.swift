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

        loadDetails()
        loadPhotos()
    }

    // MARK: Custom Methods
    func loadDetails() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().managedObjectContext.objectWithID(movieID) as! Movie
            
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
            let movie = CoreDataManager.sharedInstance().managedObjectContext.objectWithID(movieID) as! Movie
            
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
                        self.tableView.reloadData()
                    }
                }
            }
            
            do {
                try TMDBManager.sharedInstance().moviesImages(movie.movieID!, completion: completion)
            } catch {}
        }
    }

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
                c.seeAllButton.hidden = true
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
