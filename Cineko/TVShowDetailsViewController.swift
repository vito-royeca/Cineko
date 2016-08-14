//
//  TVShowDetailsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 15/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import Colours
import CoreData
import IDMPhotoBrowser
import JJJUtils
import MBProgressHUD
import MMDrawerController
import SDWebImage
import TwitterKit

class TVShowDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: Variables
    var titleLabel:UILabel?
    var tvShowID:NSManagedObjectID?
    var homepage:String?
    var backdropFetchRequest:NSFetchRequest?
    var castFetchRequest:NSFetchRequest?
    var crewFetchRequest:NSFetchRequest?
    var tvSeasonFetchRequest:NSFetchRequest?
    private var averageColor:UIColor?
    private var contrastColor:UIColor?
    var tweets:[AnyObject]?
    
    // MARK: Actions
    @IBAction func segmentedAction(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            loadDetails()
            loadPhotos()
            loadCastAndCrew()
        case 1:
            loadTweets()
        default:
            ()
        }
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "clearTableViewCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "segmentedTableViewCell")
        tableView.registerNib(UINib(nibName: "MediaInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "mediaInfoTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "homepageTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "photosTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "castTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "crewTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "seasonsTableViewCell")
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "tweetsTableViewCell")
        
        initDrawerButton()
        
        // manually setup the floating title header
        titleLabel = UILabel(frame: CGRectMake(0, 0, view.frame.size.width, 44))
        titleLabel!.backgroundColor = UIColor.whiteColor()
        titleLabel!.textAlignment = .Center
        titleLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        titleLabel!.numberOfLines = 0
        titleLabel!.lineBreakMode = .ByWordWrapping
        titleLabel!.preferredMaxLayoutWidth = view.frame.size.width
        tableView.addSubview(titleLabel!)
        
        loadDetails()
        loadPhotos()
        loadCastAndCrew()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateBackground()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // reset the navigation bar's colors look and feel
        if let navigationController = navigationController {
            navigationController.navigationBar.titleTextAttributes = nil
            navigationController.navigationBar.tintColor = nil
            navigationController.navigationBar.barTintColor = nil
            navigationController.navigationBar.translucent = true
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // push the titleLabel when scrolling up
        var rect = titleLabel!.frame
        rect.origin.y = min(0, tableView.contentOffset.y)
        titleLabel!.frame = rect
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        titleLabel!.frame = CGRectMake(0, 0, size.width, 44)
        tableView.reloadData()
    }
    
    // MARK: Custom Methods
    func updateBackground() {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(tvShowID) as! TVShow
            
            if let posterPath = tvShow.posterPath {
                let url = NSURL(string: "\(TMDBConstants.ImageURL)/\(TMDBConstants.PosterSizes[4])\(posterPath)")
                let backgroundView = UIImageView()
                backgroundView.contentMode = .ScaleAspectFit
                tableView.backgroundView = backgroundView
                
                let completed = { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) in
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                        MBProgressHUD.hideHUDForView(cell, animated: true)
                    }
                    
                    if let image = image {
                        let color = image.averageColor()
                        self.averageColor = color.colorWithAlphaComponent(0.97)
                        self.contrastColor = color.blackOrWhiteContrastingColor()
                        self.titleLabel!.backgroundColor = self.averageColor
                        self.titleLabel!.textColor = self.contrastColor
                        if let inverseColor = self.contrastColor,
                            let navigationController = self.navigationController{
                            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: inverseColor]
                            navigationController.navigationBar.tintColor = inverseColor
                        }
                        if let averageColor = self.averageColor,
                            let navigationController = self.navigationController {
                            navigationController.navigationBar.barTintColor = averageColor
                            navigationController.navigationBar.translucent = false
                        }
                        
                        // change also the button items
                        if let button = self.navigationItem.rightBarButtonItem {
                            if let image = button.image {
                                let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
                                button.image = tintedImage
                                button.tintColor = self.contrastColor
                            }
                        }
                        
                        backgroundView.backgroundColor = self.averageColor
                        self.tableView.reloadData()
                    }
                }
                
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                backgroundView.sd_setImageWithURL(url, completed: completed)
            }
            
            titleLabel!.text = tvShow.name
            titleLabel!.sizeToFit()
            // resize the frame to cover the whole width
            titleLabel!.frame = CGRectMake(titleLabel!.frame.origin.x, titleLabel!.frame.origin.y, view.frame.size.width, titleLabel!.frame.size.height)
        }
    }

    func loadDetails() {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(tvShowID) as! TVShow
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    self.tvSeasonFetchRequest = NSFetchRequest(entityName: "TVSeason")
                    self.tvSeasonFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                    self.tvSeasonFetchRequest!.predicate = NSPredicate(format: "tvShow.tvShowID = %@", tvShow.tvShowID!)
                    self.tvSeasonFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "seasonNumber", ascending: false)]
                    
                    if let homepage = tvShow.homepage {
                        if !homepage.isEmpty {
                            self.homepage = homepage
                        }
                    }
                
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance.tvShowDetails(tvShow.tvShowID!, completion: completion)
            } catch {}
        }
    }
    
    func loadPhotos() {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(tvShowID) as! TVShow
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    self.backdropFetchRequest = NSFetchRequest(entityName: "Image")
                    self.backdropFetchRequest!.predicate = NSPredicate(format: "tvShowBackdrop.tvShowID = %@", tvShow.tvShowID!)
                    self.backdropFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "voteAverage", ascending: false)]
                
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance.tvShowImages(tvShow.tvShowID!, completion: completion)
            } catch {}
        }
    }
    
    func loadCastAndCrew() {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(tvShowID) as! TVShow
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    self.castFetchRequest = NSFetchRequest(entityName: "Credit")
                    self.castFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                    self.castFetchRequest!.predicate = NSPredicate(format: "tvShow.tvShowID = %@ AND creditType = %@", tvShow.tvShowID!, "cast")
                    self.castFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "order", ascending: true)]
                    
                    self.crewFetchRequest = NSFetchRequest(entityName: "Credit")
                    self.crewFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                    self.crewFetchRequest!.predicate = NSPredicate(format: "tvShow.tvShowID = %@ AND creditType = %@", tvShow.tvShowID!, "crew")
                    self.crewFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "job.department", ascending: true),
                        NSSortDescriptor(key: "job.name", ascending: true)]
                
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance.tvShowCredits(tvShow.tvShowID!, completion: completion)
            } catch {}
        }
    }
    
    func loadTweets() {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(tvShowID) as! TVShow
            
            let completion = { (results: [AnyObject], error: NSError?) in
                performUIUpdatesOnMain {
                    
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    } else {
                        self.tweets = TWTRTweet.tweetsWithJSONArray(results)
                    }
                    
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                        MBProgressHUD.hideHUDForView(cell, animated: true)
                        self.tableView.reloadData()
                    }
                }
            }
            
            do {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                try TwitterManager.sharedInstance.userSearch("\"\(tvShow.name!)\"", completion: completion)
            } catch {}
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            // reset the accessory button
            cell.accessoryType = .None
            cell.selectionStyle = .None

            switch indexPath.row {
            case 0:
                cell.contentView.backgroundColor = UIColor.clearColor()
                if let backgroundView = cell.backgroundView {
                    backgroundView.backgroundColor = UIColor.clearColor()
                }
                cell.backgroundColor = UIColor.clearColor()
            case 1:
                segmentedView.removeFromSuperview()
                segmentedView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: segmentedView.frame.size.height)
                segmentedView.backgroundColor = averageColor
                if let contrastColor = contrastColor {
                    segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: contrastColor], forState: .Normal)
                    segmentedControl.tintColor = contrastColor
                }
                cell.backgroundColor = UIColor.clearColor()
                cell.contentView.addSubview(segmentedView)
            case 2:
                if let c = cell as? MediaInfoTableViewCell {
                    if let tvShowID = tvShowID {
                        let tvShow = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(tvShowID) as! TVShow
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
                    c.changeColor(averageColor, fontColor: contrastColor)
                }
            case 3:
                if let c = cell as? DynamicHeightTableViewCell {
                    if let tvShowID = tvShowID {
                        let tvShow = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(tvShowID) as! TVShow
                        var text = String()
                        
                        // genre
                        if let genres = tvShow.genres {
                            var genreStrings = String()
                            let objects = genres.allObjects as! [Genre]
                            let names = objects.map { $0.name! } as [String]
                            genreStrings = names.sort().joinWithSeparator(", ")
                            text += genreStrings
                        }
                        
                        // overview
                        if let overview = tvShow.overview {
                            text += "\n\n\(overview)"
                        }

                        // production companies
                        if let productionCompanies = tvShow.productionCompanies {
                            var productionCompanyStrings = String()
                            let objects = productionCompanies.allObjects as! [Company]
                            let names = objects.map { $0.name! } as [String]
                            productionCompanyStrings = names.sort().joinWithSeparator("\n")
                            text += "\n\n\(productionCompanyStrings)"
                        }
                        
                        text += "\n"
                        
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                        c.dynamicLabel.text = text
                    }
                    c.changeColor(averageColor, fontColor: contrastColor)
                }
            case 4+homepageCount:
                if let c = cell as? ThumbnailTableViewCell {
                    c.tag = indexPath.row
                    c.titleLabel.text = "Photos"
                    c.titleLabel.textColor = UIColor.whiteColor()
                    c.showSeeAllButton = false
                    c.fetchRequest = backdropFetchRequest
                    c.displayType = .Backdrop
                    c.changeColor(averageColor, fontColor: contrastColor)
                    c.delegate = self
                    c.loadData()
                }
            case 5+homepageCount:
                if let c = cell as? ThumbnailTableViewCell {
                    c.tag = indexPath.row
                    c.titleLabel.text = "Cast"
                    c.titleLabel.textColor = UIColor.whiteColor()
                    c.seeAllButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    c.fetchRequest = castFetchRequest
                    c.displayType = .Profile
                    c.captionType = .NameAndRole
                    c.showCaption = true
                    c.changeColor(averageColor, fontColor: contrastColor)
                    c.delegate = self
                    c.loadData()
                }
            case 6+homepageCount:
                if let c = cell as? ThumbnailTableViewCell {
                    c.tag = indexPath.row
                    c.titleLabel.text = "Crew"
                    c.titleLabel.textColor = UIColor.whiteColor()
                    c.seeAllButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    c.fetchRequest = crewFetchRequest
                    c.displayType = .Profile
                    c.captionType = .NameAndJob
                    c.showCaption = true
                    c.changeColor(averageColor, fontColor: contrastColor)
                    c.delegate = self
                    c.loadData()
                }
            case 7+homepageCount:
                if let c = cell as? ThumbnailTableViewCell {
                    c.tag = indexPath.row
                    c.titleLabel.text = "Seasons"
                    c.titleLabel.textColor = UIColor.whiteColor()
                    c.seeAllButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    c.fetchRequest = tvSeasonFetchRequest
                    c.displayType = .Poster
                    c.captionType = .Title
                    c.showCaption = true
                    c.changeColor(averageColor, fontColor: contrastColor)
                    c.delegate = self
                    c.loadData()
                }
            default:
                let rowPath = 4
                
                if homepageCount > 0 {
                    if indexPath.row == rowPath {
                        cell.accessoryType = .DisclosureIndicator
                        cell.textLabel?.text = homepage
                        cell.textLabel?.textColor = contrastColor
                        cell.textLabel?.backgroundColor = averageColor
                        cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                        cell.backgroundColor = averageColor
                        cell.accessoryView?.tintColor = contrastColor
                        if let image = UIImage(named: "link"),
                            let imageView = cell.imageView {
                            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
                            imageView.image = tintedImage
                            imageView.tintColor = contrastColor
                        }
                        if let image = UIImage(named: "forward") {
                            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
                            let imageView = UIImageView(image: tintedImage)
                            imageView.tintColor = contrastColor
                            cell.accessoryView = imageView
                        }
                    }
                }
            }
            
        case 1:
            switch indexPath.row {
            case 0,
                 1:
                return
            default:
                if let c = cell as? TWTRTweetTableViewCell,
                    tweets = tweets {
                    if tweets.count > 0 {
                        if let tweet = tweets[indexPath.row-2] as? TWTRTweet {
                            
                            c.configureWithTweet(tweet)
                            c.backgroundColor = UIColor.clearColor()
                            c.tweetView.backgroundColor = averageColor!
                            c.tweetView.primaryTextColor = contrastColor!
                            c.tweetView.linkTextColor = contrastColor!
                            c.tweetView.showActionButtons = true
                            c.tweetView.delegate = self
                        }
                    }
                }
            }
            
        default:
            ()
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
    
    func showBackdropsBrowser(path: NSIndexPath) {
        if let backdropFetchRequest = backdropFetchRequest {
            var photos = [IDMPhoto]()
            
            for image in ObjectManager.sharedInstance.fetchObjects(backdropFetchRequest) as! [Image] {
                if let filePath = image.filePath {
                    let url = NSURL(string: "\(TMDBConstants.ImageURL)/\(TMDBConstants.BackdropSizes[3])\(filePath)")
                    let photo = IDMPhoto(URL: url)
                    photos.append(photo)
                }
            }
            
            let browser = IDMPhotoBrowser(photos: photos)
            browser.setInitialPageIndex(UInt(path.row))
            presentViewController(browser, animated:true, completion:nil)
        }
    }
    
    // MARK: MMDrawer methods
    func initDrawerButton() {
        setupRightMenuButton()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"kCloseOpenDrawersNotif",  object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SearchViewController.closeDrawers), name: "kCloseOpenDrawersNotif", object:nil)
    }
    
    func setupRightMenuButton() {
        let rightDrawerButton = MMDrawerBarButtonItem(target:self, action:#selector(SearchViewController.rightDrawerButtonPress(_:)))
        navigationItem.setRightBarButtonItem(rightDrawerButton, animated:true)
    }
    
    func closeDrawers() {
        mm_drawerController.closeDrawerAnimated(false, completion:nil)
    }
    
    func rightDrawerButtonPress(sender: AnyObject) {
        if let navigationVC = mm_drawerController.rightDrawerViewController as? UINavigationController {
            var tvShowSettings:TVShowSettingsViewController?
            
            for drawer in navigationVC.viewControllers {
                if drawer is TVShowSettingsViewController {
                    tvShowSettings = drawer as? TVShowSettingsViewController
                }
            }
            if tvShowSettings == nil {
                tvShowSettings = TVShowSettingsViewController()
                navigationVC.addChildViewController(tvShowSettings!)
            }

            tvShowSettings!.tvShowID = tvShowID
            navigationVC.popToViewController(tvShowSettings!, animated: true)
        }
        mm_drawerController.toggleDrawerSide(.Right, animated:true, completion:nil)
    }
}

// MARK: UITableViewDataSource
extension TVShowDetailsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            rows = 8
            
            if let _ = homepage {
                rows += 1
            }
            
        case 1:
            if let tweets = tweets {
                rows = tweets.count+2
            } else {
                rows = 2
            }
            
        default:
            ()
        }
        
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("clearTableViewCell", forIndexPath: indexPath)
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("segmentedTableViewCell", forIndexPath: indexPath)
            case 2:
                cell = tableView.dequeueReusableCellWithIdentifier("mediaInfoTableViewCell", forIndexPath: indexPath)
            case 3:
                cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
            case 4+homepageCount:
                cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
            case 5+homepageCount:
                cell = tableView.dequeueReusableCellWithIdentifier("castTableViewCell", forIndexPath: indexPath)
            case 6+homepageCount:
                cell = tableView.dequeueReusableCellWithIdentifier("crewTableViewCell", forIndexPath: indexPath)
            case 7+homepageCount:
                cell = tableView.dequeueReusableCellWithIdentifier("seasonsTableViewCell", forIndexPath: indexPath)
            default:
                let rowPath = 4
                
                if homepageCount > 0 {
                    if indexPath.row == rowPath {
                        cell = tableView.dequeueReusableCellWithIdentifier("homepageTableViewCell", forIndexPath: indexPath)
                    }
                }
            }
            
        case 1:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("clearTableViewCell", forIndexPath: indexPath)
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("segmentedTableViewCell", forIndexPath: indexPath)
            default:
                cell = tableView.dequeueReusableCellWithIdentifier("tweetsTableViewCell", forIndexPath: indexPath)
            }
            
        default:
            ()
        }
        
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
}

// MARK: UITableViewDelegate
extension TVShowDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            switch indexPath.row {
            case 0:
                return (tableView.frame.size.height / 2) + titleLabel!.frame.size.height
            case 1,
                 2:
                return UITableViewAutomaticDimension
            case 3:
                return dynamicHeightForCell("overviewTableViewCell", indexPath: indexPath)
            case 4+homepageCount,
                 5+homepageCount,
                 6+homepageCount,
                 7+homepageCount:
                return tableView.frame.size.height / 3
            default:
                return UITableViewAutomaticDimension
            }
            
        case 1:
            switch indexPath.row {
            case 0:
                return (tableView.frame.size.height / 2) + titleLabel!.frame.size.height
            case 1:
                return UITableViewAutomaticDimension
            default:
                if let tweets = tweets {
                    if tweets.count > 0 {
                        if let tweet = tweets[indexPath.row-2] as? TWTRTweet {
                            return TWTRTweetTableViewCell.heightForTweet(tweet, style: .Compact, width: tableView.frame.size.width, showingActions: true)
                        }
                    }
                }
            }
            
        default:
            ()
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            switch indexPath.row {
            case 0,
                 1,
                 2,
                 3,
                 4+homepageCount,
                 5+homepageCount,
                 6+homepageCount,
                 7+homepageCount:
                // return nil for the first row which is not selectable
                return nil
            default:
                return indexPath
            }
        
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            switch indexPath.row {
            case 0,
                 1,
                 2,
                 3,
                 4+homepageCount,
                 5+homepageCount,
                 6+homepageCount,
                 7+homepageCount:
                return
            default:
                let rowPath = 4
                
                if homepageCount > 0 {
                    if indexPath.row == rowPath {
                        UIApplication.sharedApplication().openURL(NSURL(string: homepage!)!)
                    }
                }
            }
            
        default:
            return
        }
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension TVShowDetailsViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SeeAllViewController") as? SeeAllViewController,
            let navigationController = navigationController {
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            var title:String?
            var fetchRequest:NSFetchRequest?
            var displayType:DisplayType?
            var captionType:CaptionType?
            var showCaption = false
            
            switch tag {
            case 5+homepageCount:
                title = "Cast"
                fetchRequest = castFetchRequest
                displayType = .Profile
                captionType = .NameAndRole
                showCaption = true
            case 6+homepageCount:
                title = "Crew"
                fetchRequest = crewFetchRequest
                displayType = .Profile
                captionType = .NameAndJob
                showCaption = true
            case 7+homepageCount:
                title = "Seasons"
                fetchRequest = tvSeasonFetchRequest
                displayType = .Poster
                captionType = .Title
                showCaption = true
            default:
                return
            }
            
            controller.navigationItem.title = title
            controller.fetchRequest = fetchRequest
            controller.displayType = displayType
            controller.captionType = captionType
            controller.showCaption = showCaption
            controller.view.tag = tag
            controller.delegate = self
            navigationController.pushViewController(controller, animated: true)
        }
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable, path: NSIndexPath) {
        var homepageCount = 0
        
        if let _ = homepage {
            homepageCount = 1
        }
        
        switch tag {
        case 4+homepageCount:
            showBackdropsBrowser(path)
        case 5+homepageCount,
             6+homepageCount:
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

// MARK: TWTRTweetViewDelegate
extension TVShowDetailsViewController : TWTRTweetViewDelegate {
    func tweetView(tweetView: TWTRTweetView, shouldDisplayDetailViewController controller: TWTRTweetDetailViewController) -> Bool {
        return false
    }
}