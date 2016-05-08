//
//  MovieDetailsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 08/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import IDMPhotoBrowser
import JJJUtils
import MBProgressHUD
import SafariServices
import SDWebImage

class MovieDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var watchlistButton: UIBarButtonItem!
    @IBOutlet weak var addToListButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var titleLabel: UILabel?
    var movieID:NSManagedObjectID?
    var movieReviews:NSSet?
    var homepage:String?
    var backdropFetchRequest:NSFetchRequest?
    var castFetchRequest:NSFetchRequest?
    var crewFetchRequest:NSFetchRequest?
    var posterFetchRequest:NSFetchRequest?
    var isFavorite = false
    var isWatchlist = false
    private var averageColor:UIColor?
    private var inverseColor:UIColor?
    
    // MARK: Actions
    @IBAction func favoriteAction(sender: UIBarButtonItem) {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                if let error = error {
                    print("Error in: \(#function)... \(error)")
                }
                
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.updateButtons()
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance().accountFavorite(movie.movieID!, mediaType: .Movie, favorite: !isFavorite, completion: completion)
            } catch {
                self.updateButtons()
            }
        }
    }
    
    @IBAction func watchlistAction(sender: UIBarButtonItem) {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                if let error = error {
                    print("Error in: \(#function)... \(error)")
                }
                
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.updateButtons()
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance().accountWatchlist(movie.movieID!, mediaType: .Movie, watchlist: !isWatchlist, completion: completion)
            } catch {
                self.updateButtons()
            }
        }
    }
    
    @IBAction func addToListAction(sender: UIBarButtonItem) {
        
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "clearTableViewCell")
        tableView.registerNib(UINib(nibName: "MediaInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "mediaInfoTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "homepageTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "reviewTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "photosTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "castTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "crewTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "postersTableViewCell")
        
        titleLabel = UILabel(frame: CGRectMake(0, 0, view.frame.size.width, 44))
        titleLabel!.backgroundColor = UIColor.whiteColor()
        titleLabel!.textAlignment = .Center
        titleLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        titleLabel!.numberOfLines = 0
        titleLabel!.lineBreakMode = .ByWordWrapping
        titleLabel!.preferredMaxLayoutWidth = view.frame.size.width
        tableView.addSubview(titleLabel!)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateButtons()
        
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
            
            if let posterPath = movie.posterPath {
                let url = NSURL(string: "\(TMDBConstants.ImageURL)/\(TMDBConstants.PosterSizes[4])\(posterPath)")
                let backgroundView = UIImageView()
                backgroundView.contentMode = .ScaleAspectFit
                tableView.backgroundView = backgroundView
                
                let comppleted = { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) in
                    if let image = image {
                        self.averageColor = image.averageColor().colorWithAlphaComponent(0.95)
                        self.inverseColor = image.inverseColor(self.averageColor)
                        self.titleLabel!.backgroundColor = self.averageColor
                        self.titleLabel!.textColor = self.inverseColor
                        backgroundView.backgroundColor = self.averageColor
                        self.tableView.reloadData()
                    }
                }
                backgroundView.sd_setImageWithURL(url, completed: comppleted)
            }
            
            titleLabel!.text = movie.title
            titleLabel!.sizeToFit()
            // resize the frame to cover the whole width
            titleLabel!.frame = CGRectMake(titleLabel!.frame.origin.x, titleLabel!.frame.origin.y, view.frame.size.width, titleLabel!.frame.size.height)
        }

        loadDetails()
        loadPhotos()
        loadCastAndCrew()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
            let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
            
            if let favorite = movie.favorite {
                isFavorite = favorite.boolValue
            }
            favoriteButton.image = isFavorite ? UIImage(named: "heart-filled") : UIImage(named: "heart")
            
            if let watchlist = movie.watchlist {
                isWatchlist = watchlist.boolValue
            }
            watchlistButton.image = isWatchlist ? UIImage(named: "eye-filled") : UIImage(named: "eye")
        }
        
        let hasSession = TMDBManager.sharedInstance().hasSessionID()
        favoriteButton.enabled = hasSession
        watchlistButton.enabled = hasSession
        addToListButton.enabled = hasSession
    }

    func loadDetails() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                if let error = error {
                    print("Error in: \(#function)... \(error)")
                }
            
                self.movieReviews = movie.reviews
                if let homepage = movie.homepage {
                    if !homepage.isEmpty {
                        self.homepage = homepage
                    }
                }
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
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
                    print("Error in: \(#function)... \(error)")
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
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance().movieImages(movie.movieID!, completion: completion)
            } catch {}
        }
    }

    func loadCastAndCrew() {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                if let error = error {
                    print("Error in: \(#function)... \(error)")
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
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance().movieCredits(movie.movieID!, completion: completion)
            } catch {}
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
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
                c.changeColor(averageColor, fontColor: inverseColor)
            }
        case 2:
            if let c = cell as? DynamicHeightTableViewCell {
                if let movieID = movieID {
                    let movie = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(movieID) as! Movie
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
                        text += "\n\n\(productionCompanyStrings)\n"
                    }
                    
                    c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                    c.dynamicLabel.text = text
                }
                c.changeColor(averageColor, fontColor: inverseColor)
            }
        case 3+homepageCount+reviewCount:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = indexPath.row
                c.titleLabel.text = "Photos"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.showSeeAllButton = false
                c.fetchRequest = backdropFetchRequest
                c.displayType = .Backdrop
                c.changeColor(averageColor, fontColor: inverseColor)
                c.delegate = self
                c.loadData()
            }
        case 4+homepageCount+reviewCount:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = indexPath.row
                c.titleLabel.text = "Cast"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                c.fetchRequest = castFetchRequest
                c.displayType = .Profile
                c.captionType = .NameAndRole
                c.showCaption = true
                c.changeColor(averageColor, fontColor: inverseColor)
                c.delegate = self
                c.loadData()
            }
        case 5+homepageCount+reviewCount:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = indexPath.row
                c.titleLabel.text = "Crew"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                c.fetchRequest = crewFetchRequest
                c.displayType = .Profile
                c.captionType = .NameAndJob
                c.showCaption = true
                c.changeColor(averageColor, fontColor: inverseColor)
                c.delegate = self
                c.loadData()
            }
        case 6+homepageCount+reviewCount:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = indexPath.row
                c.titleLabel.text = "Posters"
                c.titleLabel.textColor = UIColor.whiteColor()
                c.seeAllButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                c.fetchRequest = posterFetchRequest
                c.displayType = .Poster
                c.changeColor(averageColor, fontColor: inverseColor)
                c.delegate = self
                c.loadData()
            }
        default:
            if homepageCount > 0 {
                if indexPath.row == 3 {
                    if let c = cell as? DynamicHeightTableViewCell {
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                        c.dynamicLabel.text = homepage
                        c.accessoryType = .DisclosureIndicator
                        c.changeColor(averageColor, fontColor: inverseColor)
                    }
                } else {
                    if reviewCount > 0 {
                        if let c = cell as? DynamicHeightTableViewCell,
                            let movieReviews = movieReviews {
                            
                            let movieReview = movieReviews.allObjects[indexPath.row-homepageCount-reviewCount] as! Review
                            c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                            c.dynamicLabel.text = "\(movieReview.suggestedLinkText!) by \(movieReview.byline!)"
                            c.accessoryType = .DisclosureIndicator
                            c.changeColor(averageColor, fontColor: inverseColor)
                        }
                    }
                }
            } else {
                if reviewCount > 0 {
                    if let c = cell as? DynamicHeightTableViewCell,
                        let movieReviews = movieReviews {
                        
                        let movieReview = movieReviews.allObjects[indexPath.row-homepageCount-reviewCount] as! Review
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                        c.dynamicLabel.text = "\(movieReview.suggestedLinkText!) by \(movieReview.byline!)"
                        c.accessoryType = .DisclosureIndicator
                        c.changeColor(averageColor, fontColor: inverseColor)
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
            
            for image in ObjectManager.sharedInstance().fetchObjects(backdropFetchRequest) as! [Image] {
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
            
            for image in ObjectManager.sharedInstance().fetchObjects(posterFetchRequest) as! [Image] {
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
}

// MARK: UITableViewDataSource
extension MovieDetailsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 7
        
        if let _ = homepage {
            rows += 1
        }
        
        if let movieReviews = movieReviews {
            rows += movieReviews.allObjects.count
        }
        
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
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
            cell = tableView.dequeueReusableCellWithIdentifier("mediaInfoTableViewCell", forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
        case 3+homepageCount+reviewCount:
            cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
        case 4+homepageCount+reviewCount:
            cell = tableView.dequeueReusableCellWithIdentifier("castTableViewCell", forIndexPath: indexPath)
        case 5+homepageCount+reviewCount:
            cell = tableView.dequeueReusableCellWithIdentifier("crewTableViewCell", forIndexPath: indexPath)
        case 6+homepageCount+reviewCount:
            cell = tableView.dequeueReusableCellWithIdentifier("postersTableViewCell", forIndexPath: indexPath)
        default:
            if homepageCount > 0 {
                if indexPath.row == 3 {
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
    
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
}

// MARK: UITableViewDelegate
extension MovieDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return dynamicHeightForCell("overviewTableViewCell", indexPath: indexPath)
        case 3+homepageCount+reviewCount,
             4+homepageCount+reviewCount,
             5+homepageCount+reviewCount,
             6+homepageCount+reviewCount:
            return tableView.frame.size.height / 3
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
             3+homepageCount+reviewCount,
             4+homepageCount+reviewCount,
             5+homepageCount+reviewCount,
             6+homepageCount+reviewCount:
            return
        default:
            if homepageCount > 0 {
                if indexPath.row == 3 {
                    UIApplication.sharedApplication().openURL(NSURL(string: homepage!)!)
                } else {
                    if reviewCount > 0 {
                        if let movieReviews = movieReviews,
                            let navigationController = navigationController {
                            let moviewReview = movieReviews.allObjects[indexPath.row-homepageCount-reviewCount] as! Review
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
                        let moviewReview = movieReviews.allObjects[indexPath.row-homepageCount-reviewCount] as! Review
                        let URL = NSURL(string: moviewReview.link!)
                        
                        let svc = SFSafariViewController(URL: URL!, entersReaderIfAvailable: true)
                        svc.delegate = self
                        navigationController.presentViewController(svc, animated: true, completion: nil)
                    }
                }
            }
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
            case 4+homepageCount+reviewCount:
                title = "Cast"
                fetchRequest = castFetchRequest
                displayType = .Profile
                captionType = .NameAndRole
                showCaption = true
            case 5+homepageCount+reviewCount:
                title = "Crew"
                fetchRequest = crewFetchRequest
                displayType = .Profile
                captionType = .NameAndJob
                showCaption = true
            case 6+homepageCount+reviewCount:
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
        case 3+homepageCount+reviewCount:
            showBackdropsBrowser(path)
        case 4+homepageCount+reviewCount,
             5+homepageCount+reviewCount:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PersonDetailsViewController") as? PersonDetailsViewController,
                let navigationController = navigationController {
                let credit = displayable as! Credit
                controller.personID = credit.person!.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        case 6+homepageCount+reviewCount:
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