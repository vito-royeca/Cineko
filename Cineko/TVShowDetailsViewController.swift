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
    var titleLabel:UILabel?
    var tvShowID:NSManagedObjectID?
    var backdropFetchRequest:NSFetchRequest?
    var castFetchRequest:NSFetchRequest?
    var crewFetchRequest:NSFetchRequest?
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

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "clearTableViewCell")
        tableView.registerNib(UINib(nibName: "MediaInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "mediaInfoTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "photosTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "castTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "crewTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "seasonsTableViewCell")
        
        if TMDBManager.sharedInstance().hasSessionID() {
            watchlistButton.enabled = true
            favoriteButton.enabled = true
            rateButton.enabled = true
        }
        
        // manually setup the floating title header
        titleLabel = UILabel(frame: CGRectMake(0, 0, view.frame.size.width, 44))
        titleLabel!.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.95)
        titleLabel!.textColor = UIColor.whiteColor()
        titleLabel!.textAlignment = .Center
        titleLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        titleLabel!.numberOfLines = 0
        titleLabel!.lineBreakMode = .ByWordWrapping
        titleLabel!.preferredMaxLayoutWidth = view.frame.size.width
        tableView.addSubview(titleLabel!)
        
        
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
            if let posterPath = tvShow.posterPath {
                let url = NSURL(string: "\(TMDBConstants.ImageURL)/\(TMDBConstants.PosterSizes[3])\(posterPath)")
                let backgroundView = UIImageView()
                tableView.backgroundView = backgroundView
                backgroundView.sd_setImageWithURL(url)
            }
            
            titleLabel!.text = tvShow.name
            titleLabel!.sizeToFit()
            // resize the frame to cover the whole width
            titleLabel!.frame = CGRectMake(titleLabel!.frame.origin.x, titleLabel!.frame.origin.y, view.frame.size.width, titleLabel!.frame.size.height)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadDetails()
        loadPhotos()
        loadCastAndCrew()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        var rect = titleLabel!.frame
        rect.origin.y = min(0, tableView.contentOffset.y)
        titleLabel!.frame = rect
    }
    
    // MARK: Custom Methods
    func loadDetails() {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
            
            let completion = { (error: NSError?) in
                if let error = error {
                    print("Error in: \(#function)... \(error)")
                }
                
                self.tvSeasonFetchRequest = NSFetchRequest(entityName: "TVSeason")
                self.tvSeasonFetchRequest!.predicate = NSPredicate(format: "tvShow.tvShowID = %@", tvShow.tvShowID!)
                self.tvSeasonFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "seasonNumber", ascending: false)]
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance().tvShowDetails(tvShow.tvShowID!, completion: completion)
            } catch {}
        }
    }
    
    func loadPhotos() {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
            
            let completion = { (error: NSError?) in
                if let error = error {
                    print("Error in: \(#function)... \(error)")
                }
                
                self.backdropFetchRequest = NSFetchRequest(entityName: "Image")
                self.backdropFetchRequest!.predicate = NSPredicate(format: "tvShowBackdrop.tvShowID = %@", tvShow.tvShowID!)
                self.backdropFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "voteAverage", ascending: false)]
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance().tvShowImages(tvShow.tvShowID!, completion: completion)
            } catch {}
        }
    }
    
    func loadCastAndCrew() {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
            
            let completion = { (error: NSError?) in
                if let error = error {
                    print("Error in: \(#function)... \(error)")
                }
                
                self.castFetchRequest = NSFetchRequest(entityName: "Credit")
                self.castFetchRequest!.predicate = NSPredicate(format: "tvShow.tvShowID = %@ AND creditType = %@", tvShow.tvShowID!, "cast")
                self.castFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "order", ascending: true)]
                
                self.crewFetchRequest = NSFetchRequest(entityName: "Credit")
                self.crewFetchRequest!.predicate = NSPredicate(format: "tvShow.tvShowID = %@ AND creditType = %@", tvShow.tvShowID!, "crew")
                self.crewFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "job.department", ascending: true),
                    NSSortDescriptor(key: "job.name", ascending: true)]
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance().tvShowCredits(tvShow.tvShowID!, completion: completion)
            } catch {}
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            cell.contentView.backgroundColor = UIColor.clearColor()
            if let backgroundView = cell.backgroundView {
                backgroundView.backgroundColor = UIColor.clearColor()
            }
            cell.backgroundColor = UIColor.clearColor()
        case 1:
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
        case 2:
            if let c = cell as? DynamicHeightTableViewCell {
                if let tvShowID = tvShowID {
                    let tvShow = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(tvShowID) as! TVShow
                    c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                    c.dynamicLabel.text = tvShow.overview
                }
            }
        case 3:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = indexPath.row
                c.titleLabel.text = "Photos"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.hidden = true
                c.fetchRequest = backdropFetchRequest
                c.displayType = .Backdrop
                c.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.95)
                c.loadData()
            }
        case 4:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = indexPath.row
                c.titleLabel.text = "Cast"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.hidden = true
                c.fetchRequest = castFetchRequest
                c.displayType = .Profile
                c.showCaption = true
                c.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.95)
                c.delegate = self
                c.loadData()
            }
        case 5:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = indexPath.row
                c.titleLabel.text = "Crew"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.hidden = true
                c.fetchRequest = crewFetchRequest
                c.displayType = .Profile
                c.showCaption = true
                c.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.95)
                c.delegate = self
                c.loadData()
            }
        case 6:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = indexPath.row
                c.titleLabel.text = "Seasons"
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

// MARK: UITableViewDataSource
extension TVShowDetailsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("clearTableViewCell", forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("mediaInfoTableViewCell", forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier("castTableViewCell", forIndexPath: indexPath)
        case 5:
            cell = tableView.dequeueReusableCellWithIdentifier("crewTableViewCell", forIndexPath: indexPath)
        case 6:
            cell = tableView.dequeueReusableCellWithIdentifier("seasonsTableViewCell", forIndexPath: indexPath)
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
        
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
}

// MARK: UITableViewDelegate
extension TVShowDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 180 + titleLabel!.frame.size.height
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return dynamicHeightForCell("overviewTableViewCell", indexPath: indexPath)
        case 3, 4, 5, 6:
            return ThumbnailTableViewCell.Height
        default:
            return UITableViewAutomaticDimension
        }
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension TVShowDetailsViewController : ThumbnailTableViewCellDelegate {
    func seeAllAction(tag: Int) {
        print("type = \(tag)")
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailTableViewCellDisplayable) {
        switch tag {
        case 4, 5:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PersonDetailsViewController") as? PersonDetailsViewController,
                let navigationController = navigationController {
                let credit = displayable as! Credit
                controller.personID = credit.person!.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        default:
            return
        }
        
    }
}
