//
//  ListDetailsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 10/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import JJJUtils
import MBProgressHUD

class ListDetailsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: Variables
    var listOID:NSManagedObjectID?
    var moviesFetchRequest:NSFetchRequest?
    
    // MARK: Actions
    @IBAction func deleteAction(sender: UIBarButtonItem) {
        let message = "Delete this List?"
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
        alertController.addAction(cancelAction)
        
        let overwriteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            if let listID = self.listOID {
                let list = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(listID) as! List
                self.deleteList(list)
            }
        }
        alertController.addAction(overwriteAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "nameTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "descriptionTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "moviesTableViewCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        loadMovies()
    }
    
    // MARK: Custom Methods
    func loadMovies() {
        if let listOID = listOID {
            let list = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(listOID) as! List
            
            moviesFetchRequest = NSFetchRequest(entityName: "Movie")
            moviesFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
            moviesFetchRequest!.sortDescriptors = [
                NSSortDescriptor(key: "releaseDate", ascending: true),
                NSSortDescriptor(key: "title", ascending: true)]
            
            let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    self.moviesFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", arrayIDs)
                
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) as? ThumbnailTableViewCell {
                        MBProgressHUD.hideHUDForView(cell, animated: true)
                    }
                    self.tableView.reloadData()
                }
            }
        
            do {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) as? ThumbnailTableViewCell {
                    MBProgressHUD.showHUDAddedTo(cell, animated: true)
                }
                
                try TMDBManager.sharedInstance.listDetails(list.listIDInt!, completion: completion)
            } catch {}
        }
    }
    
    func deleteList(list: List) {
        let completion = { (error: NSError?) in
            
            performUIUpdatesOnMain {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let error = error {
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                }
                
                if let navigationController = self.navigationController {
                    navigationController.popToRootViewControllerAnimated(true)
                }
            }
        }
        
        do {
            MBProgressHUD.showHUDAddedTo(view, animated: true)
            try TMDBManager.sharedInstance.deleteList(list.listIDInt!, completion: completion)
        } catch {
            MBProgressHUD.hideHUDForView(view, animated: true)
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        // reset the accessory button
        cell.accessoryType = .None
        cell.selectionStyle = .None
        
        switch indexPath.section {
        case 0:
            if let c = cell as? DynamicHeightTableViewCell {
                if let listOID = listOID {
                    let list = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(listOID) as! List
                    
                    c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                    c.dynamicLabel.text = list.name
                }
                c.changeColor(UIColor.whiteColor(), fontColor: UIColor.blackColor())
            }
        case 1:
            if let c = cell as? DynamicHeightTableViewCell {
                if let listOID = listOID {
                    let list = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(listOID) as! List
                    
                    c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                    c.dynamicLabel.text = list.description_
                }
                c.changeColor(UIColor.whiteColor(), fontColor: UIColor.blackColor())
            }
        case 2:
            if let c = cell as? ThumbnailTableViewCell {
                c.titleLabel.text = "Movies"
                c.fetchRequest = moviesFetchRequest
                c.displayType = .Poster
                c.captionType = .Title
                c.tag = indexPath.row
                c.delegate = self
                c.loadData()
            }
        default:
            break
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
extension ListDetailsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Name"
        case 1:
            return "Description"
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("nameTableViewCell", forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("descriptionTableViewCell", forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("moviesTableViewCell", forIndexPath: indexPath)
        default:
            break
        }
        
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
}

// MARK: UITableViewDelegate
extension ListDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableViewAutomaticDimension
        case 1:
            return dynamicHeightForCell("descriptionTableViewCell", indexPath: indexPath)
        default:
            return tableView.frame.size.height / 3
        }
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension ListDetailsViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SeeAllViewController") as? SeeAllViewController,
            let navigationController = navigationController {
            
            controller.navigationItem.title = "Movies"
            controller.fetchRequest = moviesFetchRequest
            controller.displayType = .Poster
            controller.captionType = .Title
            controller.showCaption = false
            controller.view.tag = tag
            controller.delegate = self
            navigationController.pushViewController(controller, animated: true)
        }
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable, path: NSIndexPath) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MovieDetailsViewController") as? MovieDetailsViewController,
            let navigationController = navigationController {
            let movie = displayable as! Movie
            controller.movieOID = movie.objectID
            navigationController.pushViewController(controller, animated: true)
        }
    }
}