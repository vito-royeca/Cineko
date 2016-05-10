//
//  AccountViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import JJJUtils
import MBProgressHUD

class AccountViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    private var _listsFetchRequest:NSFetchRequest? = nil
    var listsFetchRequest:NSFetchRequest? {
        get {
            return _listsFetchRequest
        }
        set (aNewValue) {
            if (_listsFetchRequest != aNewValue) {
                _listsFetchRequest = aNewValue
                
                // force reset the fetchedResultsController
                if let _listsFetchRequest = _listsFetchRequest {
                    _listsFetchRequest.sortDescriptors = [
                        NSSortDescriptor(key: "name", ascending: true)]
                    let context = CoreDataManager.sharedInstance().mainObjectContext
//                    let context = CoreDataManager.sharedInstance().privateContext
                    fetchedResultsController = NSFetchedResultsController(fetchRequest: _listsFetchRequest,
                                                                          managedObjectContext: context,
                                                                          sectionNameKeyPath: nil,
                                                                          cacheName: nil)
                }
            }
        }
    }
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let context = CoreDataManager.sharedInstance().mainObjectContext
//        let context = CoreDataManager.sharedInstance().privateContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: self.listsFetchRequest!,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
    }()
    
    // MARK: Actions
    @IBAction func loginAction(sender: UIBarButtonItem) {
        if let _ = TMDBManager.sharedInstance().account {
            TMDBManager.sharedInstance().logout()
            loginButton.title = "Login"
            loadLists()
            
        } else {
            do {
                if let requestToken = try TMDBManager.sharedInstance().getAvailableRequestToken() {
                    let urlString = "\(TMDBConstants.AuthenticateURL)/\(requestToken)"
                    self.presentLoginViewController(urlString)
                    
                } else {
                    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    
                    let success = { (results: AnyObject!) in
                        if let dict = results as? [String: AnyObject] {
                            if let requestToken = dict[TMDBConstants.Authentication.TokenNew.Keys.RequestToken] as? String {
                                
                                do {
                                    try TMDBManager.sharedInstance().saveRequestToken(requestToken)
                                } catch {}
                                
                                performUIUpdatesOnMain {
                                    let urlString = "\(TMDBConstants.AuthenticateURL)/\(requestToken)"
                                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                                    self.presentLoginViewController(urlString)
                                }
                            }
                        }
                    }
                    
                    let failure = { (error: NSError?) in
                        performUIUpdatesOnMain {
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey]!)")
                            
                        }
                    }
                    
                    do {
                        try TMDBManager.sharedInstance().authenticationTokenNew(success, failure: failure)
                    } catch {}
                }
            } catch {}
        }
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = TMDBManager.sharedInstance().account {
            loginButton.title = "Logout"
            addButton.enabled = true
        } else {
            loginButton.title = "Login"
            addButton.enabled = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadLists()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addListSegue" {
            let vc = segue.destinationViewController as! UINavigationController
            if let editor = vc.viewControllers.first as? ListEditorViewController {
                editor.navigationItem.title = "New List"
                editor.delegate = self
            }
        }
    }
    
     // MARK: Custom Methods
    func presentLoginViewController(authenticateURLString: String) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
            controller.authenticationURLString = authenticateURLString
            controller.delegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func loadLists() {
        listsFetchRequest = NSFetchRequest(entityName: "List")
        
        if TMDBManager.sharedInstance().needsRefresh(TMDBConstants.Device.Keys.Lists) {
            if TMDBManager.sharedInstance().hasSessionID() {
                let completion = { (arrayIDs: [AnyObject], error: NSError?) in
                    if let error = error {
                        print("Error in: \(#function)... \(error)")
                    }
                    
                    self.listsFetchRequest!.predicate = NSPredicate(format: "listID IN %@", arrayIDs)
                    self.doFetch()
                }
                
                do {
                    try TMDBManager.sharedInstance().lists(completion)
                } catch {
                    listsFetchRequest!.predicate = NSPredicate(format: "createdBy = nil")
                    doFetch()
                }
            } else {
                listsFetchRequest!.predicate = NSPredicate(format: "createdBy = nil")
                doFetch()
            }
            
        } else {
            if TMDBManager.sharedInstance().hasSessionID() {
                listsFetchRequest!.predicate = NSPredicate(format: "createdBy = %@", TMDBManager.sharedInstance().account!)
            } else {
                listsFetchRequest!.predicate = NSPredicate(format: "createdBy = nil")
            }
            doFetch()
        }
    }
    
    func doFetch() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        self.fetchedResultsController.delegate = self
        
        performUIUpdatesOnMain {
            self.tableView.reloadData()
        }
    }
    
    func configureCell(cell: UITableViewCell, list: List) {
        if let posterPath = list.posterPath {
            cell.imageView!.sd_setImageWithURL(NSURL(string: posterPath), placeholderImage: UIImage(named: "account.png"))
        }
        cell.textLabel!.text = list.name
        cell.detailTextLabel!.text = list.description_
        cell.accessoryType = .DisclosureIndicator
    }
    
    func deleteList(list: List) {
        let completion = { (error: NSError?) in
            
            performUIUpdatesOnMain {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let error = error {
                    print("Error in: \(#function)... \(error)")
                }
            }
        }
        
        do {
            MBProgressHUD.showHUDAddedTo(view, animated: true)
            try TMDBManager.sharedInstance().deleteList(list.listID!, completion: completion)
        } catch {
            MBProgressHUD.hideHUDForView(view, animated: true)
        }
    }
}

// MARK: UITableViewDataSource
extension AccountViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if listsFetchRequest != nil,
               let sections = fetchedResultsController.sections {
                let sectionInfo = sections[section-1]
                return sectionInfo.numberOfObjects
                
            } else {
                return 0
            }
        default:
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Lists"
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        cell.accessoryType = .None
        
        switch indexPath.section {
        case 0:
            if let account = TMDBManager.sharedInstance().account {
                cell.textLabel!.text = account.name
                cell.detailTextLabel!.text = account.username
                
                if let url = account.imageURL() {
                    cell.imageView!.sd_setImageWithURL(url, placeholderImage: UIImage(named: "account.png"))
                }
                
            } else {
                cell.textLabel!.text = "Name"
                cell.detailTextLabel!.text = "Username"
                cell.imageView!.image = UIImage(named: "account.png")
            }
        case 1:
            if let list = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: indexPath.section-1)) as? List {
                configureCell(cell, list: list)
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let message = "Delete this List?"
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
        alertController.addAction(cancelAction)
        
        let overwriteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            if let list = self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: indexPath.section-1)) as? List {
                
                self.deleteList(list)
            }
        }
        alertController.addAction(overwriteAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: UITableViewDelegate
extension AccountViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 90
        default:
            return UITableViewAutomaticDimension
        }
    }
}

// MARK: LoginViewControllerDelegate
extension AccountViewController : LoginViewControllerDelegate {
    func loginSuccess(viewController: UIViewController) {
        let completion = { (error: NSError?) in
            performUIUpdatesOnMain {
                viewController.dismissViewControllerAnimated(true, completion: nil)
                self.loginButton.title = "Logout"
                self.loadLists()
            }
        }
        
        do {
            try TMDBManager.sharedInstance().downloadInitialData(completion)
        } catch {}
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension AccountViewController : NSFetchedResultsControllerDelegate {
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex+1), withRowAnimation: .Automatic)
            
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex+1), withRowAnimation: .Automatic)
            
        case .Update:
            tableView.reloadSections(NSIndexSet(index: sectionIndex+1), withRowAnimation: .Automatic)
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath!.row, inSection: newIndexPath!.section+1)], withRowAnimation: .Automatic)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath!.row, inSection: indexPath!.section+1)], withRowAnimation: .Automatic)
            
        case .Update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)) {
                    
                    if let list = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: indexPath.section-1)) as? List {
                        self.configureCell(cell, list: list)
                    }
                }
            }
            
        case .Move:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}

// MARK: ListEditorViewControllerDelegate
extension AccountViewController : ListEditorViewControllerDelegate {
    func success(editor: ListEditorViewController) {
        editor.dismissViewControllerAnimated(true, completion: nil)
        loadLists()
    }
    
    func failure(editor: ListEditorViewController, error: NSError?) {
        JJJUtil.alertWithTitle("Error", andMessage:"\(error!.userInfo[NSLocalizedDescriptionKey])")
    }
}