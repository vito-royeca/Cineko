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
import SDWebImage

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

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "posterTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "nameTableViewCell")
        tableView.registerNib(UINib(nibName: "DynamicHeightTableViewCell", bundle: nil), forCellReuseIdentifier: "descriptionTableViewCell")
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "moviesTableViewCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        loadMovies()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMovieDetailsFromListDetails" {
            if let detailsVC = segue.destinationViewController as? MovieDetailsViewController {
                let movie = sender as! Movie
                detailsVC.movieOID = movie.objectID
            }
        }  else if segue.identifier == "showSeeAllFromListDetails" {
            if let detailsVC = segue.destinationViewController as? SeeAllViewController,
                let listOID = listOID {
                
                let list = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(listOID) as! List
                
                detailsVC.navigationItem.title = list.name
                detailsVC.fetchRequest = moviesFetchRequest
                detailsVC.displayType = .Poster
                detailsVC.captionType = .Title
                detailsVC.showCaption = false
                detailsVC.view.tag = sender as! Int
                detailsVC.delegate = self
            }
        }
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
        var list:List?
        if let listOID = listOID {
            list = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(listOID) as? List
        }
        
        // reset the accessory button
        cell.accessoryType = .None
        cell.selectionStyle = .None
        
        switch indexPath.section {
        case 0:
            for v in cell.contentView.subviews {
                v.removeFromSuperview()
            }
            
            let imageView = UIImageView()
            imageView.contentMode = .ScaleToFill
            
            if let posterPath = list!.posterPath {
                let url = NSURL(string: "\(TMDBConstants.ImageURL)/\(TMDBConstants.BackdropSizes[1])\(posterPath)")
                imageView.sd_setImageWithURL(url)
            } else {
                imageView.image = UIImage(named: "noImage")
            }
            
            cell.contentView.addSubview(imageView)
        case 1:
            if let c = cell as? DynamicHeightTableViewCell {
                c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                c.dynamicLabel.text = list!.name
                c.changeColor(UIColor.whiteColor(), fontColor: UIColor.blackColor())
            }
        case 2:
            if let c = cell as? DynamicHeightTableViewCell {
                c.dynamicLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                c.dynamicLabel.text = list!.description_
                c.changeColor(UIColor.whiteColor(), fontColor: UIColor.blackColor())
            }
        case 3:
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
}

// MARK: UITableViewDataSource
extension ListDetailsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Name"
        case 2:
            return "Description"
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("posterTableViewCell", forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("nameTableViewCell", forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("descriptionTableViewCell", forIndexPath: indexPath)
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("moviesTableViewCell", forIndexPath: indexPath)
        default:
            ()
        }
        
        configureCell(cell!, indexPath: indexPath)
        return cell!
    }
}

// MARK: UITableViewDelegate
extension ListDetailsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return dynamicHeightForCell("descriptionTableViewCell", indexPath: indexPath)
        default:
            return tableView.frame.size.height / 3
        }
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension ListDetailsViewController : ThumbnailDelegate {
    func seeAllAction(tag: Int) {
        performSegueWithIdentifier("showSeeAllFromListDetails", sender: tag)
    }
    
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable, path: NSIndexPath) {
        performSegueWithIdentifier("showMovieDetailsFromListDetails", sender: displayable)
    }
}
