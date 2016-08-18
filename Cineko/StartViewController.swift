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
import MMDrawerController

class StartViewController: UIViewController {
    
    // MARK: Actions
    @IBAction func loginAction(sender: UIButton) {
        do {
            if let requestToken = try TMDBManager.sharedInstance.getAvailableRequestToken() {
                let urlString = "\(TMDBConstants.AuthenticateURL)/\(requestToken)"
                performSegueWithIdentifier("presentLoginFromStart", sender: urlString)
            
            } else {
                let success = { (results: AnyObject!) in
                    if let dict = results as? [String: AnyObject] {
                        if let requestToken = dict[TMDBConstants.Authentication.TokenNew.Keys.RequestToken] as? String,
                            let expires_at = dict[TMDBConstants.Authentication.TokenNew.Keys.ExpiresAt] as? String {
                            
                            let formatter = NSDateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
                            let expirationDate = formatter.dateFromString(expires_at)
                            
                            do {
                             try TMDBManager.sharedInstance.saveRequestToken(requestToken, date: expirationDate!)
                            } catch {}
                            
                            performUIUpdatesOnMain {
                                let urlString = "\(TMDBConstants.AuthenticateURL)/\(requestToken)"
                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                self.performSegueWithIdentifier("presentLoginFromStart", sender: urlString)
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
                    MBProgressHUD.showHUDAddedTo(view, animated: true)
                    try TMDBManager.sharedInstance.authenticationTokenNew(success, failure: failure)
                } catch {}
            }
        } catch {}
    }
    
    @IBAction func skipLoginAction(sender: UIButton) {
        performSegueWithIdentifier("presentDrawerFromStart", sender: sender)
    }
    
    // MARK: Overrides
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentLoginFromStart" {
            if let vc = segue.destinationViewController as? LoginViewController {
                vc.authenticationURLString = sender as? String
                vc.delegate = self
            }
        } else if segue.identifier == "presentDrawerFromStart" {
            // no op
        }
    }
}

// MARK: LoginViewControllerDelegate
extension StartViewController : LoginViewControllerDelegate {
    func loginSuccess(viewController: UIViewController) {
        if TMDBManager.sharedInstance.hasSessionID() {
            if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("DrawerController") as? MMDrawerController {
                viewController.presentViewController(controller, animated: true, completion: nil)
            }
            
        } else {
            viewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
