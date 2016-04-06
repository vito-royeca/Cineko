//
//  FeaturedViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

import JJJUtils

class FeaturedViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ScrollingTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // TLYShyNavBar
        shyNavBarManager.scrollView = tableView
    }
    
    // MARK: Custom Methods
    func loadFeaturedMovies() {
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let sessionID = dict[Constants.TMDB.Authentication.SessionNew.Keys.SessionID] as? String {
                    TMDBManager.sharedInstance().saveSessionID(sessionID)
                    
                    performUIUpdatesOnMain {
                        
                    }
                }
            }
        }
        
        let failure = { (error: NSError?) in
            performUIUpdatesOnMain {
                JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
            }
        }
        
        TMDBManager.sharedInstance().authenticationSessionNew(success, failure: failure)
    }
}

// MARK: UITableViewDataSource
extension FeaturedViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ScrollingTableViewCell
        
        switch indexPath.row {
            case 0:
                cell.titleLabel.text = "In Theaters"
            case 1:
                cell.titleLabel.text = "On TV"
            case 2:
                cell.titleLabel.text = "Lists"
            case 3:
                cell.titleLabel.text = "People"
            default:
                break
        }
        
        cell.tag = indexPath.row
        cell.delegate = self
        return cell
    }
}

// MARK: UITableViewDelegate
extension FeaturedViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ScrollingTableViewCell.Height
    }
}

// MARK: ScrollingTableViewCellDelegate
extension FeaturedViewController : ScrollingTableViewCellDelegate {
    func seeAllAction(tag: Int) {
        print("tag = \(tag)")
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}