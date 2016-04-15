//
//  TVShowDetailsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 15/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import JJJUtils
import MBProgressHUD
import SDWebImage

class TVShowDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var watchlistButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var rateButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Variables
    var tvShowID:NSManagedObjectID?
    var backdropFetchRequest:NSFetchRequest?
    var tvSeasonFetchRequest:NSFetchRequest?
    
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

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.registerNib(UINib(nibName: "ActionTableViewCell", bundle: nil), forCellReuseIdentifier: "actionTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "titleTableViewCell")
        tableView.registerNib(UINib(nibName: "MediaInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "mediaInfoTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "photosTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "seasonsTableViewCell")
        
        if TMDBManager.sharedInstance().hasSessionID() {
            watchlistButton.enabled = true
            favoriteButton.enabled = true
            rateButton.enabled = true
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadDetails()
        loadBackdrops()
    }

    // MARK: Custom Methods
    func loadDetails() {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
            
            let completion = { (error: NSError?) in
                if let error = error {
                    performUIUpdatesOnMain {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                } else {
                    self.tvSeasonFetchRequest = NSFetchRequest(entityName: "TVSeason")
                    self.tvSeasonFetchRequest!.predicate = NSPredicate(format: "tvShow = %@", tvShow)
                    self.tvSeasonFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "seasonNumber", ascending: false)]
                    
                    performUIUpdatesOnMain {
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as? ThumbnailTableViewCell {
                            MBProgressHUD.hideHUDForView(cell, animated: true)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            
            do {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as? ThumbnailTableViewCell {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                try TMDBManager.sharedInstance().tvShowDetails(tvShow.tvShowID!, completion: completion)
            } catch {}
        }
    }
    
    func loadBackdrops() {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
            
            let completion = { (error: NSError?) in
                if let error = error {
                    performUIUpdatesOnMain {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                } else {
                    self.backdropFetchRequest = NSFetchRequest(entityName: "Image")
                    self.backdropFetchRequest!.predicate = NSPredicate(format: "tvShowBackdrop = %@", tvShow)
                    self.backdropFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "voteAverage", ascending: false)]
                    
                    performUIUpdatesOnMain {
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? ThumbnailTableViewCell {
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
                try TMDBManager.sharedInstance().tvShowImages(tvShow.tvShowID!, completion: completion)
            } catch {}
        }
    }
    
//    func loadSeasons() {
//        if let tvShowID = tvShowID {
//            let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
//            
//            let completion = { (error: NSError?) in
//                if let error = error {
//                    performUIUpdatesOnMain {
//                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
//                    }
//                    
//                } else {
//                    self.tvSeasonFetchRequest = NSFetchRequest(entityName: "TVSeason")
//                    self.tvSeasonFetchRequest!.predicate = NSPredicate(format: "tvShow = %@", tvShow)
//                    self.tvSeasonFetchRequest!.sortDescriptors = [
//                        NSSortDescriptor(key: "seasonNumber", ascending: false)]
//                    
//                    performUIUpdatesOnMain {
//                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as? ThumbnailTableViewCell {
//                            MBProgressHUD.hideHUDForView(cell, animated: true)
//                        }
//                        self.tableView.reloadData()
//                    }
//                }
//            }
//            
//            do {
//                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as? ThumbnailTableViewCell {
//                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
//                }
//                try TMDBManager.sharedInstance().tvShowImages(tvShow.tvShowID!, completion: completion)
//            } catch {}
//        }
//    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            if let c = cell as? DynamicHeightTableViewCell {
                if let tvShowID = tvShowID {
                    let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
                    
                    if let name = tvShow.name {
                        c.dynamicLabel.text = name
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
                if let tvShowID = tvShowID {
                    let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
                    var dateText = String()
                    
                    if let firstAirDate = tvShow.firstAirDate {
                        dateText = firstAirDate.componentsSeparatedByString("-").first!
                    }
                    if let inProduction = tvShow.inProduction {
                        if inProduction.boolValue {
                            dateText += "-present"
                        }
                    } else {
                        if let lastAirDate = tvShow.lastAirDate {
                            dateText += "-\(lastAirDate.componentsSeparatedByString("-").first!)"
                        }
                    }
                    c.dateLabel.text = dateText
                    
                    c.durationIcon.hidden = true
                    c.durationLabel.text = nil
                    if let voteAverage = tvShow.voteAverage {
                        c.ratingLabel.text = NSString(format: "%.1f", voteAverage.doubleValue) as String
                    }
                }
            }
        case 3:
            if let c = cell as? DynamicHeightTableViewCell {
                if let tvShowID = tvShowID {
                    let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
                    
                    if let overview = tvShow.overview {
                        c.dynamicLabel.text = overview
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                    }
                }
            }
            
        case 4:
            if let c = cell as? ThumbnailTableViewCell {
                var seasons = 0
                if let tvShowID = tvShowID {
                    let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
                    
                    if let numberOfSeasons = tvShow.numberOfSeasons {
                        seasons = numberOfSeasons.integerValue
                    }
                }
                c.tag = 4
                c.titleLabel.text = "Seasons (\(seasons))"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.hidden = true
                c.fetchRequest = tvSeasonFetchRequest
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

extension TVShowDetailsViewController : UITableViewDataSource {
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
            cell = tableView.dequeueReusableCellWithIdentifier("seasonsTableViewCell", forIndexPath: indexPath)
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
        
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
}

extension TVShowDetailsViewController : UITableViewDelegate {
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
