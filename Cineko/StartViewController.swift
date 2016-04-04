//
//  LoginViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 04/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    
    // MARK: Actions
    @IBAction func loginAction(sender: UIButton) {
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let requestToken = dict[Constants.TMDBRequestToken.RequestToken] as? String {
                    let authenticateURLString = "\(Constants.TMDB.AuthenticateURL)/\(requestToken)?redirect_to=XX"
                    
                    
                }
            }
        }
        
        let failure = { (error: NSError?) in
            print("Login Errror... \(error)")
        }
        
        TMDBManager.sharedInstance().requestToken(success, failure: failure);
    }
    
    
    @IBAction func signupAction(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: Constants.TMDB.SignupURL)!)
    }
    
    
    @IBAction func skipLoginAction(sender: UIButton) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
