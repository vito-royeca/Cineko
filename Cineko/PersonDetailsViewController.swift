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

class PersonDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var personID:NSManagedObjectID?
    var homepage:String?
    var photosFetchRequest:NSFetchRequest?
    var moviesFetchRequest:NSFetchRequest?
    var tvShowsFetchRequest:NSFetchRequest?
    var movieCreditsFetchRequest:NSFetchRequest?
    var tvShowCreditsFetchRequest:NSFetchRequest?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "photosTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "homepageTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "moviesTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "tvShowsTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "movieCreditsTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "tvShowCreditsTableViewCell")
        
        if let personID = personID {
            let person = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(personID) as! Person
            navigationItem.title = person.name
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadPhotos()
        loadDetails()
        loadCombinedCredits()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
    
    // MARK: Custom Methods
    func loadPhotos() {
        if let personID = personID {
            let person = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(personID) as! Person
            
            let completion = { (error: NSError?) in
                if let error = error {
                    print("Error in: \(#function)... \(error)")
                }

                self.photosFetchRequest = NSFetchRequest(entityName: "Image")
                self.photosFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                self.photosFetchRequest!.predicate = NSPredicate(format: "personProfile.personID = %@", person.personID!)
                self.photosFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "voteAverage", ascending: false)]
                
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.tableView.reloadData()
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance().personImages(person.personID!, completion: completion)
            } catch {
                MBProgressHUD.hideHUDForView(view, animated: true)
                self.tableView.reloadData()
            }
        }
    }
    
    func loadDetails() {
        if let personID = personID {
            let person = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(personID) as! Person
            
            let completion = { (error: NSError?) in
                if let error = error {
                    print("Error in: \(#function)... \(error)")
                }
                
                if let homepage = person.homepage {
                    if !homepage.isEmpty {
                        self.homepage = homepage
                    }
                }
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
            
            do {
                try TMDBManager.sharedInstance().personDetails(person.personID!, completion: completion)
            } catch {}
        }
    }

    func loadCombinedCredits() {
        if let personID = personID {
            let person = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(personID) as! Person
            
            let completion = { (error: NSError?) in
                if let error = error {
                    print("Error in: \(#function)... \(error)")
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
                try TMDBManager.sharedInstance().personCredits(person.personID!, completion: completion)
            } catch {}
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
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
            if let c = cell as? DynamicHeightTableViewCell {
                if let personID = personID {
                    let person = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(personID) as! Person
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
        case 2+homepageCount:
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
        case 3+homepageCount:
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
        case 4+homepageCount:
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
        case 5+homepageCount:
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
            if let c = cell as? DynamicHeightTableViewCell {
                c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                c.dynamicLabel.text = homepage
                c.accessoryType = .DisclosureIndicator
                c.changeColor(UIColor.whiteColor(), fontColor: UIColor.blackColor())
            }
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
            
            for image in ObjectManager.sharedInstance().fetchObjects(photosFetchRequest) as! [Image] {
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
        var rows = 6
        
        if let _ = homepage {
            rows += 1
        }
        
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        var homepageCount = 0
        
        if let _ = homepage {
            homepageCount = 1
        }
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
        case 2+homepageCount:
            cell = tableView.dequeueReusableCellWithIdentifier("moviesTableViewCell", forIndexPath: indexPath)
        case 3+homepageCount:
            cell = tableView.dequeueReusableCellWithIdentifier("tvShowsTableViewCell", forIndexPath: indexPath)
        case 4+homepageCount:
            cell = tableView.dequeueReusableCellWithIdentifier("movieCreditsTableViewCell", forIndexPath: indexPath)
        case 5+homepageCount:
            cell = tableView.dequeueReusableCellWithIdentifier("tvShowCreditsTableViewCell", forIndexPath: indexPath)
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("homepageTableViewCell", forIndexPath: indexPath)
        }
        
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
}

// MARK: UITableViewDelegate
extension PersonDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var homepageCount = 0
        
        if let _ = homepage {
            homepageCount = 1
        }
        
        switch indexPath.row {
        case 0:
            return tableView.frame.size.height / 3
        case 1:
            return dynamicHeightForCell("overviewTableViewCell", indexPath: indexPath)
        case 2+homepageCount,
             3+homepageCount,
             4+homepageCount,
             5+homepageCount:
            return tableView.frame.size.height / 3
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        var homepageCount = 0
        
        if let _ = homepage {
            homepageCount = 1
        }
        
        switch indexPath.row {
        case 0,
             1,
             2+homepageCount,
             3+homepageCount,
             4+homepageCount,
             5+homepageCount:
            // return nil for the first row which is not selectable
            return nil
        default:
            return indexPath
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var homepageCount = 0
        
        if let _ = homepage {
            homepageCount = 1
        }
        
        switch indexPath.row {
        case 0,
             1,
             2+homepageCount,
             3+homepageCount,
             4+homepageCount,
             5+homepageCount:
            return
        default:
            if homepageCount > 0 {
                UIApplication.sharedApplication().openURL(NSURL(string: homepage!)!)
            }
        }
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension PersonDetailsViewController : ThumbnailDelegate {
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
            case 0:
                title = "Photos"
                fetchRequest = photosFetchRequest
                displayType = .Profile
            case 2+homepageCount:
                title = "Movie Appearances"
                fetchRequest = moviesFetchRequest
                displayType = .Poster
                captionType = .Role
                showCaption = true
            case 3+homepageCount:
                title = "TV Show Appearances"
                fetchRequest = tvShowsFetchRequest
                displayType = .Poster
                captionType = .Role
                showCaption = true
            case 4+homepageCount:
                title = "Movie Credits"
                fetchRequest = movieCreditsFetchRequest
                displayType = .Poster
                captionType = .Job
                showCaption = true
            case 5+homepageCount:
                title = "TV Show Credits"
                fetchRequest = tvShowCreditsFetchRequest
                displayType = .Poster
                captionType = .Job
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
        case 0:
            showProfilesBrowser(path)
        case 2+homepageCount,
             4+homepageCount:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MovieDetailsViewController") as? MovieDetailsViewController,
                let navigationController = navigationController {
                let credit = displayable as! Credit
                controller.movieID = credit.movie!.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        case 3+homepageCount,
             5+homepageCount:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TVShowDetailsViewController") as? TVShowDetailsViewController,
                let navigationController = navigationController {
                let credit = displayable as! Credit
                controller.tvShowID = credit.tvShow!.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        default:
            return
        }
    }
}
