//
//  AccountViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import JJJUtils
import MBProgressHUD

class AccountViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func loginAction(sender: UIBarButtonItem) {
        if let _ = TMDBManager.sharedInstance().account {
            TMDBManager.sharedInstance().logout()
            loginButton.title = "Login"
            tableView.reloadData()
            
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
//        tableView.registerNib(UINib(nibName: "UITableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = TMDBManager.sharedInstance().account {
            loginButton.title = "Logout"
        } else {
            loginButton.title = "Login"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
     // MARK: Custom Methods
    func presentLoginViewController(authenticateURLString: String) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
            controller.authenticationURLString = authenticateURLString
            controller.delegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
//    func loadPhotos() {
//        if let account = TMDBManager.sharedInstance().account {
//            let completion = { (error: NSError?) in
//                if let error = error {
//                    print("Error in: \(#function)... \(error)")
//                }
//                
//                performUIUpdatesOnMain {
//                    self.tableView.reloadData()
//                }
//            }
//            
//            do {
//                try TMDBManager.sharedInstance().accountImages(movie.movieID!, completion: completion)
//            } catch {}
//        }
//    }
}

// MARK: UITableViewDataSource
extension AccountViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        
        switch indexPath.row {
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
        default:
            break
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension AccountViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
}

// MARK: LoginViewControllerDelegate
extension AccountViewController : LoginViewControllerDelegate {
    func loginSuccess(viewController: UIViewController) {
        let completion = { (error: NSError?) in
            performUIUpdatesOnMain {
                viewController.dismissViewControllerAnimated(true, completion: nil)
                self.loginButton.title = "Logout"
                self.tableView.reloadData()
            }
        }
        
        do {
            try TMDBManager.sharedInstance().downloadInitialData(completion)
        } catch {}
    }
}