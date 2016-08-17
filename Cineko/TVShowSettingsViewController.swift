//
//  TVShowSettingsViewController.swift
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

class TVShowSettingsViewController: FormViewController {

    // MARK: Variables
    var tvShowID:NSManagedObjectID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "TV Show Settings"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        composeForm()
    }
    
    func setFavorite(isFavorite: Bool) {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(tvShowID) as! TVShow
            
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
                try TMDBManager.sharedInstance.accountFavorite(tvShow.tvShowID!, mediaType: .TVShow, favorite: isFavorite, completion: completion)
            } catch {
                
            }
        }
    }
    
    func setWatchlist(isWatchlist: Bool) {
        if let tvShowID = tvShowID {
            let tvShow = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(tvShowID) as! TVShow
            
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
                try TMDBManager.sharedInstance.accountWatchlist(tvShow.tvShowID!, mediaType: .TVShow, watchlist: isWatchlist, completion: completion)
            } catch {

            }
        }
    }
    
    func composeForm() {
        let hasSession = TMDBManager.sharedInstance.hasSessionID()
        let header = hasSession ? "" : "You may need to login to enable editing"
        var tvShow:TVShow?
        
        if let tvShowID = tvShowID {
            tvShow = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(tvShowID) as? TVShow
        }
        
        form =
            Section(header)
            <<< SwitchRow() {
                $0.title = "Favorite"
                $0.tag =  "Favorite"
                $0.disabled = hasSession ? false : true
                if let favorite = tvShow!.favorite {
                    $0.value = favorite.boolValue && hasSession
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
                $0.disabled = hasSession ? false : true
                if let watchlist = tvShow!.watchlist {
                    $0.value = watchlist.boolValue && hasSession
                } else {
                    $0.value = false
                }}.onChange { row in
                    if let value = row.value {
                        self.setWatchlist(value as Bool)
                    }
                }
        
            +++ Section("")
    }
}
