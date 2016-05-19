//
//  MovieDetailsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 08/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import Colours
import CoreData
import IDMPhotoBrowser
import JJJUtils
import MBProgressHUD
import SafariServices
import SDWebImage
import TwitterKit

class MovieDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var watchlistButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var titleLabel: UILabel?
    var movieID:NSManagedObjectID?
    var movieReviews:NSSet?
    var homepage:String?
    var detailsAndTweetsSelection:DetailsAndTweetsSelection = .Details
    var backdropFetchRequest:NSFetchRequest?
    var castFetchRequest:NSFetchRequest?
    var crewFetchRequest:NSFetchRequest?
    var posterFetchRequest:NSFetchRequest?
    var isFavorite = false
    var isWatchlist = false
    private var averageColor:UIColor?
    private var contrastColor:UIColor?
    var tweets:[AnyObject]?
    
    // MARK: Actions
    @IBAction func favoriteAction(sender: UIBarButtonItem) {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.updateButtons()
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance.accountFavorite(movie.movieID!, mediaType: .Movie, favorite: !isFavorite, completion: completion)
            } catch {
                self.updateButtons()
            }
        }
    }
    
    @IBAction func watchlistAction(sender: UIBarButtonItem) {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.updateButtons()
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance.accountWatchlist(movie.movieID!, mediaType: .Movie, watchlist: !isWatchlist, completion: completion)
            } catch {
                self.updateButtons()
            }
        }
    }
    
    @IBAction func listAction(sender: UIBarButtonItem) {
        let message = "List Options"
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
        alertController.addAction(cancelAction)
        
        let addAction = UIAlertAction(title: "Add To List", style: .Default) { (action) in
            self.showAddToListDialog()
        }
        alertController.addAction(addAction)
        
        let removeAction = UIAlertAction(title: "Remove from List", style: .Destructive) { (action) in
            self.showRemoveFromListDialog()
        }
        alertController.addAction(removeAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func segmentedAction(sender: UISegmentedControl) {
        
    }
    
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "clearTableViewCell")
        tableView.registerNib(UINib(nibName: "DetailsAndTweetsTableViewCell", bundle: nil), forCellReuseIdentifier: "detailsAndTweetsTableViewCell")
        tableView.registerNib(UINib(nibName: "MediaInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "mediaInfoTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "homepageTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "reviewTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "photosTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "castTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "crewTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "postersTableViewCell")
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "tweetsTableViewCell")
        
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
        
        updateButtons()
        
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            if let posterPath = movie.posterPath {
                let url = NSURL(string: "\(TMDBConstants.ImageURL)/\(TMDBConstants.PosterSizes[4])\(posterPath)")
                let backgroundView = UIImageView()
                backgroundView.contentMode = .ScaleAspectFit
                tableView.backgroundView = backgroundView
                
                let comppleted = { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) in
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                        MBProgressHUD.hideHUDForView(cell, animated: true)
                    }
                    
                    if let image = image {
                        let color = image.averageColor()
                        self.averageColor = color.colorWithAlphaComponent(0.97)
                        self.contrastColor = color.blackOrWhiteContrastingColor()
                        self.titleLabel!.backgroundColor = self.averageColor
                        self.titleLabel!.textColor = self.contrastColor
                        if let inverseColor = self.contrastColor {
                            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: inverseColor]
                            self.navigationController!.navigationBar.tintColor = inverseColor
                        }
                        if let averageColor = self.averageColor {
                            self.navigationController!.navigationBar.barTintColor = averageColor
                            self.navigationController!.navigationBar.translucent = false
                        }
                        
                        // change also the button items
                        if let image = self.favoriteButton.image {
                            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
                            self.favoriteButton.image = tintedImage
                            self.favoriteButton.tintColor = self.contrastColor
                        }
                        if let image = self.watchlistButton.image {
                            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
                            self.watchlistButton.image = tintedImage
                            self.watchlistButton.tintColor = self.contrastColor
                        }
                        if let image = self.listButton.image {
                            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
                            self.listButton.image = tintedImage
                            self.listButton.tintColor = self.contrastColor
                        }
                        
                        backgroundView.backgroundColor = self.averageColor
                        self.tableView.reloadData()
                    }
                }
                
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                backgroundView.sd_setImageWithURL(url, completed: comppleted)
            }
            
            titleLabel!.text = movie.title
            titleLabel!.sizeToFit()
            // resize the frame to cover the whole width
            titleLabel!.frame = CGRectMake(titleLabel!.frame.origin.x, titleLabel!.frame.origin.y, view.frame.size.width, titleLabel!.frame.size.height)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // reset the navigation bar's colors look and feel
        navigationController!.navigationBar.titleTextAttributes = nil
        navigationController!.navigationBar.tintColor = nil
        navigationController!.navigationBar.barTintColor = nil
        navigationController!.navigationBar.translucent = true
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
    func updateButtons() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            if let favorite = movie.favorite {
                isFavorite = favorite.boolValue
            }
            favoriteButton.image = isFavorite ? UIImage(named: "heart-filled") : UIImage(named: "heart")
            
            if let watchlist = movie.watchlist {
                isWatchlist = watchlist.boolValue
            }
            watchlistButton.image = isWatchlist ? UIImage(named: "eye-filled") : UIImage(named: "eye")
        }
        
        let hasSession = TMDBManager.sharedInstance.hasSessionID()
        favoriteButton.enabled = hasSession
        watchlistButton.enabled = hasSession
        listButton.enabled = hasSession
    }

    func loadDetails() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                
                    self.movieReviews = movie.reviews
                    if let homepage = movie.homepage {
                        if !homepage.isEmpty {
                            self.homepage = homepage
                        }
                    }
                
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance.movieDetails(movie.movieID!, completion: completion)
            } catch {}
        }
    }
    
    func loadPhotos() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    self.backdropFetchRequest = NSFetchRequest(entityName: "Image")
                    self.backdropFetchRequest!.predicate = NSPredicate(format: "movieBackdrop.movieID = %@", movie.movieID!)
                    self.backdropFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "voteAverage", ascending: false)]
                    
                    self.posterFetchRequest = NSFetchRequest(entityName: "Image")
                    self.posterFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                    self.posterFetchRequest!.predicate = NSPredicate(format: "moviePoster.movieID = %@", movie.movieID!)
                    self.posterFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "voteAverage", ascending: false)]
                
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance.movieImages(movie.movieID!, completion: completion)
            } catch {}
        }
    }

    func loadCastAndCrew() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }

                    self.castFetchRequest = NSFetchRequest(entityName: "Credit")
                    self.castFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                    self.castFetchRequest!.predicate = NSPredicate(format: "movie.movieID = %@ AND creditType = %@", movie.movieID!, "cast")
                    self.castFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "order", ascending: true)]
                    
                    self.crewFetchRequest = NSFetchRequest(entityName: "Credit")
                    self.crewFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                    self.crewFetchRequest!.predicate = NSPredicate(format: "movie.movieID = %@ AND creditType = %@", movie.movieID!, "crew")
                    self.crewFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "job.department", ascending: true),
                        NSSortDescriptor(key: "job.name", ascending: true)]
                
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance.movieCredits(movie.movieID!, completion: completion)
            } catch {}
        }
    }
    
    func loadTweets() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (results: [AnyObject], error: NSError?) in
                performUIUpdatesOnMain {
                
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    } else {
                        self.tweets = TWTRTweet.tweetsWithJSONArray(results)
                    }
                
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) {
                        MBProgressHUD.hideHUDForView(cell, animated: true)
                        self.tableView.reloadData()
                    }
                }
            }
            
            do {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                try TwitterManager.sharedInstance.userSearch(movie.title!, completion: completion)
            } catch {}
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch detailsAndTweetsSelection {
        case .Details:
            var reviewCount = 0
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            if let movieReviews = movieReviews {
                reviewCount = movieReviews.allObjects.count
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
                if let c = cell as? DetailsAndTweetsTableViewCell {
                    c.changeColor(averageColor, fontColor: contrastColor)
                    c.delegate = self
                }
            case 2:
                if let c = cell as? MediaInfoTableViewCell {
                    if let movieID = movieID {
                        let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
                        
                        if let releaseDate = movie.releaseDate {
                            c.dateLabel.text = releaseDate
                        }
                        c.durationLabel.text = movie.runtimeToString()
                        if let voteAverage = movie.voteAverage {
                            c.ratingLabel.text = NSString(format: "%.1f", voteAverage.doubleValue) as String
                        }
                    }
                    c.changeColor(averageColor, fontColor: contrastColor)
                }
            case 3:
                if let c = cell as? DynamicHeightTableViewCell {
                    if let movieID = movieID {
                        let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
                        var text = String()
                        
                        // genre
                        if let genres = movie.genres {
                            var genreStrings = String()
                            
                            let objects = genres.allObjects as! [Genre]
                            let names = objects.map { $0.name! } as [String]
                            genreStrings = names.sort().joinWithSeparator(", ")
                            text += genreStrings
                        }
                        
                        // overview
                        if let overview = movie.overview {
                            text += "\n\n\(overview)"
                        }
                        
                        // production companies
                        if let productionCompanies = movie.productionCompanies {
                            var productionCompanyStrings = String()
                            let objects = productionCompanies.allObjects as! [Company]
                            let names = objects.map { $0.name! } as [String]
                            productionCompanyStrings = names.sort().joinWithSeparator(", ")
                            text += "\n\n\(productionCompanyStrings)"
                        }
                        
                        text += "\n"
                        
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                        c.dynamicLabel.text = text
                    }
                    c.changeColor(averageColor, fontColor: contrastColor)
                }
            case 4+homepageCount+reviewCount:
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
            case 5+homepageCount+reviewCount:
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
            case 6+homepageCount+reviewCount:
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
            case 7+homepageCount+reviewCount:
                if let c = cell as? ThumbnailTableViewCell {
                    c.tag = indexPath.row
                    c.titleLabel.text = "Posters"
                    c.titleLabel.textColor = UIColor.whiteColor()
                    c.seeAllButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    c.fetchRequest = posterFetchRequest
                    c.displayType = .Poster
                    c.changeColor(averageColor, fontColor: contrastColor)
                    c.delegate = self
                    c.loadData()
                }
            default:
                let rowPath = 4
                
                if homepageCount > 0 {
                    if indexPath.row == rowPath {
                        if let c = cell as? DynamicHeightTableViewCell {
                            c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                            c.dynamicLabel.text = homepage
                            c.accessoryType = .DisclosureIndicator
                            c.changeColor(averageColor, fontColor: contrastColor)
                        }
                    } else {
                        if reviewCount > 0 {
                            if let c = cell as? DynamicHeightTableViewCell,
                                let movieReviews = movieReviews {
                                
                                let movieReview = movieReviews.allObjects[indexPath.row-rowPath-homepageCount] as! Review
                                c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                                c.dynamicLabel.text = "\(movieReview.suggestedLinkText!) by \(movieReview.byline!)"
                                c.accessoryType = .DisclosureIndicator
                                c.changeColor(averageColor, fontColor: contrastColor)
                            }
                        }
                    }
                } else {
                    if reviewCount > 0 {
                        if let c = cell as? DynamicHeightTableViewCell,
                            let movieReviews = movieReviews {
                            
                            let movieReview = movieReviews.allObjects[indexPath.row-rowPath-homepageCount] as! Review
                            c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                            c.dynamicLabel.text = "\(movieReview.suggestedLinkText!) by \(movieReview.byline!)"
                            c.accessoryType = .DisclosureIndicator
                            c.changeColor(averageColor, fontColor: contrastColor)
                        }
                    }
                }
            }
            
        case .Tweets:
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
                            c.tweetView.showActionButtons = true
                        }
                    }
                }
            }
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
    
    func showPostersBrowser(path: NSIndexPath) {
        if let posterFetchRequest = posterFetchRequest {
            var photos = [IDMPhoto]()
            
            for image in ObjectManager.sharedInstance.fetchObjects(posterFetchRequest) as! [Image] {
                if let filePath = image.filePath {
                    let url = NSURL(string: "\(TMDBConstants.ImageURL)/\(TMDBConstants.PosterSizes[6])\(filePath)")
                    let photo = IDMPhoto(URL: url)
                    photos.append(photo)
                }
            }
            
            let browser = IDMPhotoBrowser(photos: photos)
            browser.setInitialPageIndex(UInt(path.row))
            presentViewController(browser, animated:true, completion:nil)
        }
    }
    
    func showAddToListDialog() {
        let callback = { (lists: [AnyObject]) in
            performUIUpdatesOnMain {
                if lists.count > 0 {
                    let alert = UIAlertController(title: "Add Movie To List", message: nil, preferredStyle: .ActionSheet)
                    
                    for list in lists {
                        let handler = {(alert: UIAlertAction!) in
                            self.addMovieToList(list as! List)
                        }
                        alert.addAction(UIAlertAction(title: list.name, style: UIAlertActionStyle.Default, handler: handler))
                    }
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                    
                    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                        if let popover = alert.popoverPresentationController {
                            popover.barButtonItem = self.listButton
                            popover.permittedArrowDirections = .Any
                            self.showDetailViewController(alert, sender:self.listButton)
                        }
                    } else {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    JJJUtil.alertWithTitle("Error", andMessage:"You have not created an List yet.")
                }
            }
        }
        
        findLists(callback)
    }
    
    func showRemoveFromListDialog() {
        let callback = { (lists: [AnyObject]) in
            performUIUpdatesOnMain {
                if lists.count > 0 {
                    let alert = UIAlertController(title: "Remove Movie From List", message: nil, preferredStyle: .ActionSheet)
                    
                    for list in lists {
                        let handler = {(alert: UIAlertAction!) in
                            self.removeMovieFromList(list as! List)
                        }
                        alert.addAction(UIAlertAction(title: list.name, style: UIAlertActionStyle.Default, handler: handler))
                    }
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                    
                    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                        if let popover = alert.popoverPresentationController {
                            popover.barButtonItem = self.listButton
                            popover.permittedArrowDirections = .Any
                            self.showDetailViewController(alert, sender:self.listButton)
                        }
                    } else {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    JJJUtil.alertWithTitle("Error", andMessage:"You have not created an List yet.")
                }
            }
        }
        
        findLists(callback)
    }
    
    func addMovieToList(list: List) {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance.addMovie(movie.movieID!, toList: list.listID!, completion: completion)
            } catch {
                JJJUtil.alertWithTitle("Error", andMessage:"Failed to add Movie to List.")
            }
        }
    }
    
    func removeMovieFromList(list: List) {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance.removeMovie(movie.movieID!, fromList: list.listID!, completion: completion)
            } catch {
                JJJUtil.alertWithTitle("Error", andMessage:"Failed to remove Movie from List.")
            }
        }
    }
    
    func findLists(callback: (lists: [AnyObject]) -> Void) {
        if TMDBManager.sharedInstance.needsRefresh(TMDBConstants.Device.Keys.Lists) {
            let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                if let error = error {
                    TMDBManager.sharedInstance.deleteRefreshData(TMDBConstants.Device.Keys.Lists)
                    performUIUpdatesOnMain {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                }
                
                let predicate = NSPredicate(format: "listID IN %@", arrayIDs)
                let lists = ObjectManager.sharedInstance.findObjects("List", predicate: predicate, sorters: [NSSortDescriptor(key: "name", ascending: true)])
                callback(lists: lists)
            }
            
            do {
                try TMDBManager.sharedInstance.lists(completion)
            } catch {
                let predicate = NSPredicate(format: "createdBy = %@", TMDBManager.sharedInstance.account!)
                let lists = ObjectManager.sharedInstance.findObjects("List", predicate: predicate, sorters: [NSSortDescriptor(key: "name", ascending: true)])
                callback(lists: lists)
            }
            
        } else {
            let predicate = NSPredicate(format: "createdBy = %@", TMDBManager.sharedInstance.account!)
            let lists = ObjectManager.sharedInstance.findObjects("List", predicate: predicate, sorters: [NSSortDescriptor(key: "name", ascending: true)])
            callback(lists: lists)
        }
    }
}

// MARK: UITableViewDataSource
extension MovieDetailsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch detailsAndTweetsSelection {
        case .Details:
            rows = 8
            
            if let _ = homepage {
                rows += 1
            }
            
            if let movieReviews = movieReviews {
                rows += movieReviews.allObjects.count
            }
        case .Tweets:
            if let tweets = tweets {
                rows = tweets.count+2
            }
        }
        
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch detailsAndTweetsSelection {
        case .Details:
            
            var reviewCount = 0
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            if let movieReviews = movieReviews {
                reviewCount = movieReviews.allObjects.count
            }
            
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("clearTableViewCell", forIndexPath: indexPath)
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("detailsAndTweetsTableViewCell", forIndexPath: indexPath)
            case 2:
                cell = tableView.dequeueReusableCellWithIdentifier("mediaInfoTableViewCell", forIndexPath: indexPath)
            case 3:
                cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
            case 4+homepageCount+reviewCount:
                cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
            case 5+homepageCount+reviewCount:
                cell = tableView.dequeueReusableCellWithIdentifier("castTableViewCell", forIndexPath: indexPath)
            case 6+homepageCount+reviewCount:
                cell = tableView.dequeueReusableCellWithIdentifier("crewTableViewCell", forIndexPath: indexPath)
            case 7+homepageCount+reviewCount:
                cell = tableView.dequeueReusableCellWithIdentifier("postersTableViewCell", forIndexPath: indexPath)
            default:
                let rowPath = 4
                
                if homepageCount > 0 {
                    if indexPath.row == rowPath {
                        cell = tableView.dequeueReusableCellWithIdentifier("homepageTableViewCell", forIndexPath: indexPath)
                    } else {
                        if reviewCount > 0 {
                            cell = tableView.dequeueReusableCellWithIdentifier("reviewTableViewCell", forIndexPath: indexPath)
                        }
                    }
                } else {
                    if reviewCount > 0 {
                        cell = tableView.dequeueReusableCellWithIdentifier("reviewTableViewCell", forIndexPath: indexPath)
                    }
                }
            }
            
        case .Tweets:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("clearTableViewCell", forIndexPath: indexPath)
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("detailsAndTweetsTableViewCell", forIndexPath: indexPath)
            default:
                cell = tableView.dequeueReusableCellWithIdentifier("tweetsTableViewCell", forIndexPath: indexPath)
            }
        }
        
        configureCell(cell!, indexPath: indexPath)
        
        return cell!
    }
}

// MARK: UITableViewDelegate
extension MovieDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch detailsAndTweetsSelection {
        case .Details:
            var homepageCount = 0
            var reviewCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            if let movieReviews = movieReviews {
                reviewCount = movieReviews.allObjects.count
            }
            
            switch indexPath.row {
            case 0:
                return (tableView.frame.size.height / 2) + titleLabel!.frame.size.height
            case 1,
                 2:
                return UITableViewAutomaticDimension
            case 3:
                return dynamicHeightForCell("overviewTableViewCell", indexPath: indexPath)
            case 4+homepageCount+reviewCount,
                 5+homepageCount+reviewCount,
                 6+homepageCount+reviewCount,
                 7+homepageCount+reviewCount:
                return tableView.frame.size.height / 3
            default:
                return UITableViewAutomaticDimension
            }
            
        case .Tweets:
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
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch detailsAndTweetsSelection {
        case .Details:
            var reviewCount = 0
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            if let movieReviews = movieReviews {
                reviewCount = movieReviews.allObjects.count
            }
            
            switch indexPath.row {
            case 0,
                 1,
                 2,
                 3,
                 4+homepageCount+reviewCount,
                 5+homepageCount+reviewCount,
                 6+homepageCount+reviewCount,
                 7+homepageCount+reviewCount:
                // return nil for the first row which is not selectable
                return nil
            default:
                return indexPath
            }
        
        case .Tweets:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch detailsAndTweetsSelection {
        case .Details:
            
            var reviewCount = 0
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            if let movieReviews = movieReviews {
                reviewCount = movieReviews.allObjects.count
            }
            
            switch indexPath.row {
            case 0,
                 1,
                 2,
                 3,
                 4+homepageCount+reviewCount,
                 5+homepageCount+reviewCount,
                 6+homepageCount+reviewCount,
                 7+homepageCount+reviewCount:
                return
            default:
                let rowPath = 4
                
                if homepageCount > 0 {
                    if indexPath.row == rowPath {
                        UIApplication.sharedApplication().openURL(NSURL(string: homepage!)!)
                    } else {
                        if reviewCount > 0 {
                            if let movieReviews = movieReviews,
                                let navigationController = navigationController {
                                let moviewReview = movieReviews.allObjects[indexPath.row-rowPath-homepageCount] as! Review
                                let URL = NSURL(string: moviewReview.link!)
                                
                                let svc = SFSafariViewController(URL: URL!, entersReaderIfAvailable: true)
                                svc.delegate = self
                                navigationController.presentViewController(svc, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    if reviewCount > 0 {
                        if let movieReviews = movieReviews,
                            let navigationController = navigationController {
                            let moviewReview = movieReviews.allObjects[indexPath.row-rowPath-homepageCount] as! Review
                            let URL = NSURL(string: moviewReview.link!)
                            
                            let svc = SFSafariViewController(URL: URL!, entersReaderIfAvailable: true)
                            svc.delegate = self
                            navigationController.presentViewController(svc, animated: true, completion: nil)
                        }
                    }
                }
            }
            
        case .Tweets:
            return
        }
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension MovieDetailsViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SeeAllViewController") as? SeeAllViewController,
            let navigationController = navigationController {
            var reviewCount = 0
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            if let movieReviews = movieReviews {
                reviewCount = movieReviews.allObjects.count
            }
            
            var title:String?
            var fetchRequest:NSFetchRequest?
            var displayType:DisplayType?
            var captionType:CaptionType?
            var showCaption = false
            
            switch tag {
            case 5+homepageCount+reviewCount:
                title = "Cast"
                fetchRequest = castFetchRequest
                displayType = .Profile
                captionType = .NameAndRole
                showCaption = true
            case 6+homepageCount+reviewCount:
                title = "Crew"
                fetchRequest = crewFetchRequest
                displayType = .Profile
                captionType = .NameAndJob
                showCaption = true
            case 7+homepageCount+reviewCount:
                title = "Posters"
                fetchRequest = posterFetchRequest
                displayType = .Poster
            default:
                return
            }
            
            controller.navigationItem.title = title
            controller.fetchRequest = fetchRequest
            controller.displayType = displayType
            controller.captionType = captionType
            controller.showCaption = showCaption
            controller.view.tag = tag+reviewCount
            controller.delegate = self
            navigationController.pushViewController(controller, animated: true)
        }
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable, path: NSIndexPath) {
        var reviewCount = 0
        var homepageCount = 0
        
        if let _ = homepage {
            homepageCount = 1
        }
        
        if let movieReviews = movieReviews {
            reviewCount = movieReviews.allObjects.count
        }
        
        switch tag {
        case 4+homepageCount+reviewCount:
            showBackdropsBrowser(path)
        case 5+homepageCount+reviewCount,
             6+homepageCount+reviewCount:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PersonDetailsViewController") as? PersonDetailsViewController,
                let navigationController = navigationController {
                let credit = displayable as! Credit
                controller.personID = credit.person!.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        case 7+homepageCount+reviewCount:
            showPostersBrowser(path)
        default:
            return
        }
    }
}

// MARK: SFSafariViewControllerDelegate
extension MovieDetailsViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: DetailsAndTweets
extension MovieDetailsViewController : DetailsAndTweetsTableViewCellDelegate {
    func selectionChanged(selection: DetailsAndTweetsSelection) {
        detailsAndTweetsSelection = selection
        
        switch selection {
        case .Details:
            loadDetails()
            loadPhotos()
            loadCastAndCrew()
        case .Tweets:
            loadTweets()
        }
    }
}
