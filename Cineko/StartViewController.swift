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
    
    // MARK: Variable
    var requestToken:String?
    var requestTokenDate:NSDate?
    
    // MARK: Actions
    @IBAction func loginAction(sender: UIButton) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let requestToken = dict[Constants.TMDBRequestToken.RequestToken] as? String {
                    let authenticateURLString = "\(Constants.TMDB.AuthenticateURL)/\(requestToken)"
                    performUIUpdatesOnMain {
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                        controller.authenticationURLString = authenticateURLString
                        self.presentViewController(controller, animated: true, completion: nil)
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
        
        TMDBManager.sharedInstance().requestToken(success, failure: failure);
    }
    
    @IBAction func skipLoginAction(sender: UIButton) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: Actions
    override func viewDidLoad() {
        
        
        // TODO: get persisted request token
//        if let requestToken = NSUserDefaults.standardUserDefaults().valueForKey(Constants.TMDB.RequestTokenKey) as? String {
//            
//            if let date = NSUserDefaults.standardUserDefaults().valueForKey(Constants.TMDB.RequestTokenKey) as? NSDate {
//                
//                let interval = date.timeIntervalSinceNow
//                let secondsInAnHour:Double = 3600
//                let elapsedTime:Int = abs(Int(interval) / secondsInAnHour)
//                
//            }
//        }
    }
}
