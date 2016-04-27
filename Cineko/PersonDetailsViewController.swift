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
                    c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                    c.dynamicLabel.text = person.biography
                    c.dynamicLabel.textColor = UIColor.blackColor()
                    c.backgroundColor = UIColor.whiteColor()
                }
            }
        case 2:
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
        case 3:
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
        case 4:
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
        case 5:
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
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("moviesTableViewCell", forIndexPath: indexPath)
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("tvShowsTableViewCell", forIndexPath: indexPath)
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier("movieCreditsTableViewCell", forIndexPath: indexPath)
        case 5:
            cell = tableView.dequeueReusableCellWithIdentifier("tvShowCreditsTableViewCell", forIndexPath: indexPath)
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
        
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
}

// MARK: UITableViewDelegate
extension PersonDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return ThumbnailTableViewCell.Height
        case 1:
            return dynamicHeightForCell("overviewTableViewCell", indexPath: indexPath)
        case 2, 3, 4, 5:
            return ThumbnailTableViewCell.Height
        default:
            return UITableViewAutomaticDimension
        }
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension PersonDetailsViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SeeAllViewController") as? SeeAllViewController,
            let navigationController = navigationController {
            
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
            case 2:
                title = "Movie Appearances"
                fetchRequest = moviesFetchRequest
                displayType = .Poster
                captionType = .Role
                showCaption = true
            case 3:
                title = "TV Show Appearances"
                fetchRequest = tvShowsFetchRequest
                displayType = .Poster
                captionType = .Role
                showCaption = true
            case 4:
                title = "Movie Credits"
                fetchRequest = movieCreditsFetchRequest
                displayType = .Poster
                captionType = .Job
                showCaption = true
            case 5:
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
        switch tag {
        case 0:
            showProfilesBrowser(path)
        case 2, 4:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MovieDetailsViewController") as? MovieDetailsViewController,
                let navigationController = navigationController {
                let credit = displayable as! Credit
                controller.movieID = credit.movie!.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        case 3, 5:
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
