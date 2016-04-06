//
//  LoginViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 04/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

import JJJUtils
import MBProgressHUD

class StartViewController: UIViewController {
    
    // MARK: Actions
    @IBAction func loginAction(sender: UIButton) {
        if let requestToken = TMDBManager.sharedInstance().getAvailableRequestToken() {
                let urlString = "\(Constants.TMDB.AuthenticateURL)/\(requestToken)"
                self.presentLoginViewController(urlString)
        
        } else {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            let success = { (results: AnyObject!) in
                if let dict = results as? [String: AnyObject] {
                    if let requestToken = dict[Constants.TMDBRequestToken.RequestToken] as? String {
                        
                        TMDBManager.sharedInstance().saveRequestToken(requestToken)
                        
                        performUIUpdatesOnMain {
                            let urlString = "\(Constants.TMDB.AuthenticateURL)/\(requestToken)"
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
            
            TMDBManager.sharedInstance().requestToken(success, failure: failure)
        }
    }
    
    @IBAction func skipLoginAction(sender: UIButton) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as? UITabBarController {
            presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: Utility methods
    func presentLoginViewController(authenticateURLString: String) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
            controller.authenticationURLString = authenticateURLString
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
}
