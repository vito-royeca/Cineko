//
//  MovieSettingsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 20/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import Eureka
import JJJUtils
import MBProgressHUD

class MovieSettingsViewController: FormViewController {

    // MARK: Variables
    var movieID:NSManagedObjectID?
    var lists:[List]?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Movie Settings"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
     
        composeForm()
        
        if TMDBManager.sharedInstance.hasSessionID() {
            loadLists()
        }
    }
    
    // MARK: Custom Methods
    func setFavorite(isFavorite: Bool) {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance.accountFavorite(movie.movieID!, mediaType: .Movie, favorite: isFavorite, completion: completion)
            } catch {
                
            }
        }
    }

    func setWatchlist(isWatchlist: Bool) {
        if let movieID = movieID {
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    if let error = error {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance.accountWatchlist(movie.movieID!, mediaType: .Movie, watchlist: isWatchlist, completion: completion)
            } catch {

            }
        }
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
    
    func loadLists() {
        if TMDBManager.sharedInstance.needsRefresh(TMDBConstants.Device.Keys.Lists) {
            let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                if let error = error {
                    TMDBManager.sharedInstance.deleteRefreshData(TMDBConstants.Device.Keys.Lists)
                    performUIUpdatesOnMain {
                        JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                    }
                }
                
                let predicate = NSPredicate(format: "listID IN %@", arrayIDs)
                if let lists = ObjectManager.sharedInstance.findObjects("List", predicate: predicate, sorters: [NSSortDescriptor(key: "name", ascending: true)]) as? [List] {
                    
                    self.lists = lists
                    performUIUpdatesOnMain {
                        self.composeForm()
                        self.addListsToForm()
                    }
                }
            }
            
            do {
                try TMDBManager.sharedInstance.lists(completion)
            } catch {
                let predicate = NSPredicate(format: "createdBy = %@", TMDBManager.sharedInstance.account!)
                if let lists = ObjectManager.sharedInstance.findObjects("List", predicate: predicate, sorters: [NSSortDescriptor(key: "name", ascending: true)]) as? [List] {
                    
                    self.lists = lists
                    composeForm()
                    addListsToForm()
                }
            }
            
        } else {
            let predicate = NSPredicate(format: "createdBy = %@", TMDBManager.sharedInstance.account!)
            if let lists = ObjectManager.sharedInstance.findObjects("List", predicate: predicate, sorters: [NSSortDescriptor(key: "name", ascending: true)]) as? [List] {
                
                self.lists = lists
                composeForm()
                addListsToForm()
            }
        }
    }
    
    func composeForm() {
        let hasSession = TMDBManager.sharedInstance.hasSessionID()
        var movie:Movie?
        
        if let movieID = movieID {
            movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as? Movie
        }
        
        form =
            Section("")
            <<< SwitchRow() {
                    $0.title = "Favorite"
                    $0.tag =  "Favorite"
                if let favorite = movie!.favorite {
                    $0.value = favorite.boolValue
                } else {
                    $0.value = false
                }}.onChange { row in
                    if let value = row.value {
                        self.setFavorite(value as Bool)
                    }
                }

            <<< SwitchRow() {
                    $0.title = "Watchlist"
                    $0.tag = "Watchlist"
                if let watchlist = movie!.watchlist {
                    $0.value = watchlist.boolValue
                } else {
                    $0.value = false
                }}.onChange { row in
                    if let value = row.value {
                        self.setWatchlist(value as Bool)
                    }
                }
        
//        if hasSession {
            +++ Section(header: "Lists", footer: "Tap a List to Add or Remove this movie.")
//        }
    }

    func addListsToForm() {
        if let lists = lists,
           let movieID = movieID {
            
            let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
            
            for list in lists {
                var checked = false
                
                if let movies = list.movies {
                    for mov in movies.allObjects {
                        let m = mov as! Movie
                        if movie.movieID == m.movieID {
                            checked = true
                            break
                        }
                    }
                }
                
                self.form.last!
                    <<< CheckRow() {
                            $0.title = list.name
                            $0.tag = list.listID
                            $0.value = checked
                        }.onChange { row in
                            if let value = row.value {
                                let mark = value as Bool
                                
                                if mark {
                                    self.addMovieToList(list)
                                } else {
                                    self.removeMovieFromList(list)
                                }
                            }
                        }
            }
        }
    }
}
