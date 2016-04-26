//
//  SearchViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 26/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

class SearchViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var moviesFetchRequest:NSFetchRequest?
    var tvShowsFetchRequest:NSFetchRequest?
    var peopleFetchRequest:NSFetchRequest?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        tableView.registerNib(UINib(nibName: "ThumbnailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let tableView = tableView {
            tableView.reloadData()
        }
    }
    
    // MARK: Custom Methods
    func loadSearchResults() {
        let completion = { (results: [MediaType: [AnyObject]], error: NSError?) in
            if let error = error {
                print("Error in: \(#function)... \(error)")
            }
            
            if let movieIDs = results[MediaType.Movie] as? [NSNumber] {
                self.moviesFetchRequest = NSFetchRequest(entityName: "Movie")
                self.moviesFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                self.moviesFetchRequest!.predicate = NSPredicate(format: "movieID IN %@", movieIDs)
                self.moviesFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "popularity", ascending: false),
                    NSSortDescriptor(key: "title", ascending: true)]
            } else {
                self.moviesFetchRequest = nil
            }
            
            if let tvShowIDs = results[MediaType.TVShow] as? [NSNumber] {
                self.tvShowsFetchRequest = NSFetchRequest(entityName: "TVShow")
                self.tvShowsFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                self.tvShowsFetchRequest!.predicate = NSPredicate(format: "tvShowID IN %@", tvShowIDs)
                self.tvShowsFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "popularity", ascending: false),
                    NSSortDescriptor(key: "name", ascending: true)]
            } else {
                self.tvShowsFetchRequest = nil
            }
            
            if let personIDs = results[MediaType.Person] as? [NSNumber] {
                self.peopleFetchRequest = NSFetchRequest(entityName: "Person")
                self.peopleFetchRequest!.fetchLimit = ThumbnailTableViewCell.MaxItems
                self.peopleFetchRequest!.predicate = NSPredicate(format: "personID IN %@", personIDs)
                self.peopleFetchRequest!.sortDescriptors = [
                    NSSortDescriptor(key: "popularity", ascending: false),
                    NSSortDescriptor(key: "name", ascending: true)]
            } else {
                self.peopleFetchRequest = nil
            }
            
            performUIUpdatesOnMain {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.tableView.reloadData()
            }
        }
        
        if let text = searchBar.text {
            if !text.isEmpty {
                do {
                    MBProgressHUD.showHUDAddedTo(view, animated: true)
                    try TMDBManager.sharedInstance().searchMulti(text, completion: completion)
                } catch {}
            }
        }
    }
}

// MARK: UITableViewDataSource
extension SearchViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ThumbnailTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Movies"
            cell.fetchRequest = moviesFetchRequest
            cell.displayType = .Poster
            cell.captionType = .Title
        case 1:
            cell.titleLabel.text = "TV Shows"
            cell.fetchRequest = tvShowsFetchRequest
            cell.displayType = .Poster
            cell.captionType = .Title
        case 2:
            cell.titleLabel.text = "People"
            cell.fetchRequest = peopleFetchRequest
            cell.displayType = .Profile
            cell.captionType = .Name
            cell.showCaption = true
        default:
            break
        }
        
        cell.tag = indexPath.row
        cell.delegate = self
        cell.loadData()
        return cell
    }
}

// MARK: UITableViewDelegate
extension SearchViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ThumbnailTableViewCell.Height
    }
}

// MARK: ThumbnailTableViewCellDelegate
extension SearchViewController : ThumbnailDelegate {
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
                title = "Movies"
                fetchRequest = moviesFetchRequest
                displayType = .Poster
            case 1:
                title = "TV Shows"
                fetchRequest = tvShowsFetchRequest
                displayType = .Poster
            case 2:
                title = "People"
                fetchRequest = peopleFetchRequest
                displayType = .Profile
                captionType = .Name
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
    
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable) {
        switch tag {
        case 0:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MovieDetailsViewController") as? MovieDetailsViewController,
                let navigationController = navigationController {
                let movie = displayable as! Movie
                controller.movieID = movie.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        case 1:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TVShowDetailsViewController") as? TVShowDetailsViewController,
                let navigationController = navigationController {
                let tvShow = displayable as! TVShow
                controller.tvShowID = tvShow.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        case 2:
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PersonDetailsViewController") as? PersonDetailsViewController,
                let navigationController = navigationController {
                let person = displayable as! Person
                controller.personID = person.objectID
                navigationController.pushViewController(controller, animated: true)
            }
        default:
            return
        }
    }
}

// MARK: UISearchBarDelegate
extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        loadSearchResults()
    }
}
