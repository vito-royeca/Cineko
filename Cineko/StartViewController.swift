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

//protocol StartViewControllerDelegate : NSObjectProtocol {
//    func loadMainInterface()
//}

class StartViewController: UIViewController {
    // MARK: Variables
    var requestToken:String?
    var requestTokenDate:NSDate?
    
    // MARK: Actions
    @IBAction func loginAction(sender: UIButton) {
        if let requestToken = TMDBManager.sharedInstance().keychain[Constants.TMDB.RequestTokenKey],
            let requestTokenDate = NSUserDefaults.standardUserDefaults().valueForKey(Constants.TMDB.RequestTokenDate) as? NSDate {
            
            // let's calculate the age of the request token
            let interval = requestTokenDate.timeIntervalSinceNow
            let secondsInAnHour:Double = 3600
            let elapsedTime = abs(interval / secondsInAnHour)
            
            // request token's expiration is 1 hour
            if elapsedTime <= 60 {
                let urlString = "\(Constants.TMDB.AuthenticateURL)/\(requestToken)"
                self.presentLoginViewController(urlString)
            }
            
        } else {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            let success = { (results: AnyObject!) in
                if let dict = results as? [String: AnyObject] {
                    if let requestToken = dict[Constants.TMDBRequestToken.RequestToken] as? String {
                        
                        // let's store the request token in the Keychain
                        // and the token's timestamp in NSUserDefaults
                        TMDBManager.sharedInstance().keychain[Constants.TMDB.RequestTokenKey] = requestToken
                        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: Constants.TMDB.RequestTokenDate)
                        
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
