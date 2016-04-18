//
//  PersonDetailsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 19/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import JJJUtils
import MBProgressHUD

class PersonDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var personID:NSManagedObjectID?
    var photosFetchRequest:NSFetchRequest?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "photosTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "overviewTableViewCell")
        
        if let personID = personID {
            let person = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(personID) as! Person
            navigationItem.title = person.name
            
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadPhotos()
        loadDetails()
    }
    
    // MARK: Custom Methods
    func loadPhotos() {
        if let personID = personID {
            let person = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(personID) as! Person
            
            let completion = { (error: NSError?) in
                if let error = error {
                    performUIUpdatesOnMain {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                } else {
                    self.photosFetchRequest = NSFetchRequest(entityName: "Image")
                    self.photosFetchRequest!.predicate = NSPredicate(format: "personProfile = %@", person)
                    self.photosFetchRequest!.sortDescriptors = [
                        NSSortDescriptor(key: "voteAverage", ascending: false)]
                    
                    performUIUpdatesOnMain {
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? ThumbnailTableViewCell {
                            MBProgressHUD.hideHUDForView(cell, animated: true)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            
            do {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? ThumbnailTableViewCell {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                try TMDBManager.sharedInstance().personImages(person.personID!, completion: completion)
            } catch {}
        }
    }
    
    func loadDetails() {
        if let personID = personID {
            let person = CoreDataManager.sharedInstance().mainObjectContext.objectWithID(personID) as! Person
            
            let completion = { (error: NSError?) in
                if let error = error {
                    performUIUpdatesOnMain {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                } else {
//                    self.tvSeasonFetchRequest = NSFetchRequest(entityName: "TVSeason")
//                    self.tvSeasonFetchRequest!.predicate = NSPredicate(format: "tvShow = %@", tvShow)
//                    self.tvSeasonFetchRequest!.sortDescriptors = [
//                        NSSortDescriptor(key: "seasonNumber", ascending: false)]
                    
                    performUIUpdatesOnMain {
                        self.tableView.reloadData()
                    }
                }
            }
            
            do {
                try TMDBManager.sharedInstance().personDetails(person.personID!, completion: completion)
            } catch {}
        }
    }

    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            if let c = cell as? ThumbnailTableViewCell {
                c.tag = indexPath.row
                c.titleLabel.text = "Photos"
                c.seeAllButton.hidden = true
                c.fetchRequest = photosFetchRequest
                c.displayType = .Profile
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
extension PersonDetailsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("photosTableViewCell", forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("overviewTableViewCell", forIndexPath: indexPath)
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
        default:
            return UITableViewAutomaticDimension
        }
    }
}
