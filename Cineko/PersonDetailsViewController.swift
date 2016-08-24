//
//  PersonDetailsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 19/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import IDMPhotoBrowser
import JJJUtils
import MBProgressHUD
import TwitterKit

class PersonDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: Variables
    var personOID:NSManagedObjectID?
    var homepage:String?
    var photosFetchRequest:NSFetchRequest?
    var moviesFetchRequest:NSFetchRequest?
    var tvShowsFetchRequest:NSFetchRequest?
    var movieCreditsFetchRequest:NSFetchRequest?
    var tvShowCreditsFetchRequest:NSFetchRequest?
    var tweets:[AnyObject]?
    
    // MARK: Actions
    @IBAction func segmentedAction(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            loadDetails()
            loadPhotos()
            loadCombinedCredits()
        case 1:
            loadTweets()
        default:
            ()
        }
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "photosTableViewCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "segmentedTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "homepageTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "moviesTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "tvShowsTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "movieCreditsTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "tvShowCreditsTableViewCell")
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "tweetsTableViewCell")
        
        if let personOID = personOID {
            let person = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(personOID) as! Person
            navigationItem.title = person.name
        }
        
        loadPhotos()
        loadDetails()
        loadCombinedCredits()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMovieDetailsFromPersonDetails" {
            if let detailsVC = segue.destinationViewController as? MovieDetailsViewController {
                let credit = sender as! Credit
                detailsVC.movieOID = credit.movie!.objectID
            }
            
        } else if segue.identifier == "showTVShowDetailsFromPersonDetails" {
            if let detailsVC = segue.destinationViewController as? TVShowDetailsViewController {
                let credit = sender as! Credit
                detailsVC.tvShowOID = credit.tvShow!.objectID
            }
            
        } else if segue.identifier == "showSeeAllFromPersonDetails" {
            if let detailsVC = segue.destinationViewController as? SeeAllViewController {
                var homepageCount = 0
                
                if let _ = homepage {
                    homepageCount = 1
                }
                
                var title:String?
                var fetchRequest:NSFetchRequest?
                var displayType:DisplayType?
                var captionType:CaptionType?
                var showCaption = false
                
                switch sender as! Int {
                case 0:
                    title = "Photos"
                    fetchRequest = photosFetchRequest
                    displayType = .Profile
                case 3+homepageCount:
                    title = "Movie Appearances"
                    fetchRequest = moviesFetchRequest
                    displayType = .Poster
                    captionType = .Role
                    showCaption = true
                case 4+homepageCount:
                    title = "TV Show Appearances"
                    fetchRequest = tvShowsFetchRequest
                    displayType = .Poster
                    captionType = .Role
                    showCaption = true
                case 5+homepageCount:
                    title = "Movie Credits"
                    fetchRequest = movieCreditsFetchRequest
                    displayType = .Poster
                    captionType = .Job
                    showCaption = true
                case 6+homepageCount:
                    title = "TV Show Credits"
                    fetchRequest = tvShowCreditsFetchRequest
                    displayType = .Poster
                    captionType = .Job
                    showCaption = true
                default:
                    ()
                }
                
                detailsVC.navigationItem.title = title
                detailsVC.fetchRequest = fetchRequest
                detailsVC.displayType = displayType
                detailsVC.captionType = captionType
                detailsVC.showCaption = showCaption
                detailsVC.view.tag = sender as! Int
                detailsVC.delegate = self
            }
        }
    }
    
    // MARK: Custom Methods
    func loadPhotos() {
        if let personOID = personOID {
            let person = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(personOID) as! Person
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }

                    self.photosFetchRequest = NSFetchRequest(entityName: "Image")
                    self.photosFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                    self.photosFetchRequest!.predicate = NSPredicate(format: "personProfile.personID = %@", person.personID!)
                    self.photosFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "voteAverage", ascending: false)]
                
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.tableView.reloadData()
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance.personImages(person.personID!, completion: completion)
            } catch {
                MBProgressHUD.hideHUDForView(view, animated: true)
                self.tableView.reloadData()
            }
        }
    }
    
    func loadDetails() {
        if let personOID = personOID {
            let person = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(personOID) as! Person
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    if let homepage = person.homepage {
                        if !homepage.isEmpty {
                            self.homepage = homepage
                        }
                    }
                
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance.personDetails(person.personID!, completion: completion)
            } catch {}
        }
    }

    func loadCombinedCredits() {
        if let personOID = personOID {
            let person = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(personOID) as! Person
            
            let completion = { (error: NSError?) in
                if let error = error {
                    performUIUpdatesOnMain {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                }
                
                var movieIDs = [NSNumber]()
                var tvShowIDs = [NSNumber]()
                var movieCreditIDs = [NSNumber]()
                var tvShowCreditIDs = [NSNumber]()
                
                for credit in person.credits!.allObjects {
                    let c = credit as! Credit
                    
                    if let creditType = c.creditType {
                        if creditType == "cast" {
                            if c.job == nil && c.tvShow == nil && c.movie != nil {
                                movieIDs.append(c.movie!.movieID!)
                            }
                            if c.job == nil && c.tvShow != nil && c.movie == nil {
                                tvShowIDs.append(c.tvShow!.tvShowID!)
                            }
                        } else if creditType == "crew" {
                            if c.job != nil && c.tvShow == nil && c.movie != nil {
                                movieCreditIDs.append(c.movie!.movieID!)
                            }
                            if c.job != nil && c.tvShow != nil && c.movie == nil {
                                tvShowCreditIDs.append(c.tvShow!.tvShowID!)
                            }
                        }
                    }
                }
                
                self.moviesFetchRequest = NSFetchRequest(entityName: "Credit")
                self.moviesFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                self.moviesFetchRequest!.predicate = NSPredicate(format: "movie.movieID IN %@ AND person.personID = %@ AND creditType = %@", movieIDs, person.personID!, "cast")
                self.moviesFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "movie.releaseDate", ascending: false)]
                
                self.tvShowsFetchRequest = NSFetchRequest(entityName: "Credit")
                self.tvShowsFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                self.tvShowsFetchRequest!.predicate = NSPredicate(format: "tvShow.tvShowID IN %@ AND person.personID = %@ AND creditType = %@", tvShowIDs, person.personID!, "cast")
                self.tvShowsFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "tvShow.firstAirDate", ascending: false)]

                self.movieCreditsFetchRequest = NSFetchRequest(entityName: "Credit")
                self.movieCreditsFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                self.movieCreditsFetchRequest!.predicate = NSPredicate(format: "movie.movieID IN %@ AND person.personID = %@ AND creditType = %@", movieCreditIDs, person.personID!, "crew")
                self.movieCreditsFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "movie.releaseDate", ascending: false)]
                
                self.tvShowCreditsFetchRequest = NSFetchRequest(entityName: "Credit")
                self.tvShowCreditsFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                self.tvShowCreditsFetchRequest!.predicate = NSPredicate(format: "tvShow.tvShowID IN %@ AND person.personID = %@ AND creditType = %@", tvShowCreditIDs, person.personID!, "crew")
                self.tvShowCreditsFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "tvShow.firstAirDate", ascending: false)]
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance.personCredits(person.personID!, completion: completion)
            } catch {}
        }
    }
    
    func loadTweets() {
        if let personOID = personOID {
            let person = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(personOID) as! Person
            
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
                try TwitterManager.sharedInstance.userSearch("\"\(person.name!)\"", completion: completion)
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
                if let c = cell as? ThumbnailTableViewCell {
                    c.tag = indexPath.row
                    c.titleLabel.text = "Photos"
                    c.fetchRequest = photosFetchRequest
                    c.displayType = .Profile
                    c.delegate = self
                    c.loadData()
                }
            case 1:
                segmentedView.removeFromSuperview()
                segmentedView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: segmentedView.frame.size.height)
                cell.backgroundColor = UIColor.clearColor()
                cell.contentView.addSubview(segmentedView)
            case 2:
                if let c = cell as? DynamicHeightTableViewCell {
                    if let personOID = personOID {
                        let person = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(personOID) as! Person
                        var text = String()
                        
                        if let alsoKnownAs = person.alsoKnownAs {
                            var akaString = String()
                            let array = NSKeyedUnarchiver.unarchiveObjectWithData(alsoKnownAs) as! [String]
                            akaString = array.sort().joinWithSeparator(", ")
                            text += "Also Known As: \(akaString)\n"
                        }
                        
                        text += "Date of Birth: \(person.birthday != nil ? person.birthday! : "")"
                        text += "\nPlace of Birth: \(person.placeOfBirth != nil ? person.placeOfBirth! : "")"
                        
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        
                        if let deathday = person.deathday {
                            if !deathday.isEmpty {
                                text += "\nDate of Death: \(deathday)"
                                if let birthdate = person.birthday {
                                    let startDate = formatter.dateFromString(birthdate)
                                    let endDate = formatter.dateFromString(deathday)
                                    text += "\nAge at Time of Death: \(ageInYears(endDate!, startDate: startDate!))"
                                }
                            } else {
                                if let birthdate = person.birthday {
                                    if !birthdate.isEmpty {
                                        let startDate = formatter.dateFromString(birthdate)
                                        let endDate = NSDate()
                                        text += "\nAge: \(ageInYears(endDate, startDate: startDate!))"
                                    }
                                }
                            }
                            
                        } else {
                            if let birthdate = person.birthday {
                                if !birthdate.isEmpty {
                                    let startDate = formatter.dateFromString(birthdate)
                                    let endDate = NSDate()
                                    text += "\nAge: \(ageInYears(endDate, startDate: startDate!))"
                                }
                            }
                        }
                        
                        if let biography = person.biography {
                            text += "\n\n\(biography)"
                        }
                        
                        text += "\n"
                        
                        c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                        c.dynamicLabel.text = text
                        c.changeColor(UIColor.whiteColor(), fontColor: UIColor.blackColor())
                    }
                }
            case 3+homepageCount:
                if let c = cell as? ThumbnailTableViewCell {
                    c.tag = indexPath.row
                    c.titleLabel.text = "Movie Appearances"
                    c.fetchRequest = moviesFetchRequest
                    c.displayType = .Poster
                    c.captionType = .Role
                    c.showCaption = true
                    c.delegate = self
                    c.loadData()
                }
            case 4+homepageCount:
                if let c = cell as? ThumbnailTableViewCell {
                    c.tag = indexPath.row
                    c.titleLabel.text = "TV Show Appearances"
                    c.fetchRequest = tvShowsFetchRequest
                    c.displayType = .Poster
                    c.captionType = .Role
                    c.showCaption = true
                    c.delegate = self
                    c.loadData()
                }
            case 5+homepageCount:
                if let c = cell as? ThumbnailTableViewCell {
                    c.tag = indexPath.row
                    c.titleLabel.text = "Movie Credits"
                    c.fetchRequest = movieCreditsFetchRequest
                    c.displayType = .Poster
                    c.captionType = .Job
                    c.showCaption = true
                    c.delegate = self
                    c.loadData()
                }
            case 6+homepageCount:
                if let c = cell as? ThumbnailTableViewCell {
                    c.tag = indexPath.row
                    c.titleLabel.text = "TV Show Credits"
                    c.fetchRequest = tvShowCreditsFetchRequest
                    c.displayType = .Poster
                    c.captionType = .Job
                    c.showCaption = true
                    c.delegate = self
                    c.loadData()
                }
            default:
                let rowPath = 3
                
                if homepageCount > 0 {
                    if indexPath.row == rowPath {
                        cell.accessoryType = .DisclosureIndicator
                        cell.textLabel?.text = homepage
                        cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                        if let image = UIImage(named: "link"),
                            let imageView = cell.imageView {
                            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
                            imageView.image = tintedImage
                        }
                        if let image = UIImage(named: "forward") {
                            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
                            let imageView = UIImageView(image: tintedImage)
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
    
    func ageInYears(endDate: NSDate, startDate: NSDate) -> Int {
        let components = NSCalendar.currentCalendar().components(.Year, fromDate:startDate, toDate:endDate, options:.WrapComponents)
        
        return components.year
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
    
    func showProfilesBrowser(path: NSIndexPath) {
        if let photosFetchRequest = photosFetchRequest {
            var photos = [IDMPhoto]()
            
            for image in ObjectManager.sharedInstance.fetchObjects(photosFetchRequest) as! [Image] {
                if let filePath = image.filePath {
                    let url = NSURL(string: "\(TMDBConstants.ImageURL)/\(TMDBConstants.ProfileSizes[4])\(filePath)")
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
extension PersonDetailsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            rows = 7
            
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
                cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("segmentedTableViewCell", forIndexPath: indexPath)
            case 2:
                cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
            case 3+homepageCount:
                cell = tableView.dequeueReusableCellWithIdentifier("moviesTableViewCell", forIndexPath: indexPath)
            case 4+homepageCount:
                cell = tableView.dequeueReusableCellWithIdentifier("tvShowsTableViewCell", forIndexPath: indexPath)
            case 5+homepageCount:
                cell = tableView.dequeueReusableCellWithIdentifier("movieCreditsTableViewCell", forIndexPath: indexPath)
            case 6+homepageCount:
                cell = tableView.dequeueReusableCellWithIdentifier("tvShowCreditsTableViewCell", forIndexPath: indexPath)
            default:
                let rowPath = 3
                
                if homepageCount > 0 {
                    if indexPath.row == rowPath {
                        cell = tableView.dequeueReusableCellWithIdentifier("homepageTableViewCell", forIndexPath: indexPath)
                    }
                }
            }
        
        case 1:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
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
extension PersonDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            var homepageCount = 0
            
            if let _ = homepage {
                homepageCount = 1
            }
            
            switch indexPath.row {
            case 0:
                return tableView.frame.size.height / 3
            case 1:
                return UITableViewAutomaticDimension
            case 2:
                return dynamicHeightForCell("overviewTableViewCell", indexPath: indexPath)
            case 3+homepageCount,
                 4+homepageCount,
                 5+homepageCount,
                 6+homepageCount:
                return tableView.frame.size.height / 3
            default:
                return UITableViewAutomaticDimension
            }
        case 1:
            switch indexPath.row {
            case 0:
                return tableView.frame.size.height / 3
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
                 3+homepageCount,
                 4+homepageCount,
                 5+homepageCount,
                 6+homepageCount:
                // return nil for the rows which are not selectable
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
                 3+homepageCount,
                 4+homepageCount,
                 5+homepageCount,
                 6+homepageCount:
                return
            default:
                let rowPath = 3
                
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
extension PersonDetailsViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        performSegueWithIdentifier("showSeeAllFromPersonDetails", sender: tag)
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable, path: NSIndexPath) {
        var homepageCount = 0
        
        if let _ = homepage {
            homepageCount = 1
        }
        
        switch tag {
        case 0:
            showProfilesBrowser(path)
        case 3+homepageCount,
             5+homepageCount:
            performSegueWithIdentifier("showMovieDetailsFromPersonDetails", sender: displayable)
        case 4+homepageCount,
             6+homepageCount:
            performSegueWithIdentifier("showTVShowDetailsFromPersonDetails", sender: displayable)
        default:
            return
        }
    }
}

// MARK: TWTRTweetViewDelegate
extension PersonDetailsViewController : TWTRTweetViewDelegate {
    func tweetView(tweetView: TWTRTweetView, shouldDisplayDetailViewController controller: TWTRTweetDetailViewController) -> Bool {
        return false
    }
}
