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
                let completion = { (error: NSError?) in
                    if let error = error {
                        performUIUpdatesOnMain {
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                            
                        }
                        
                    } else {
                        do {
                            if let requestToken = try TMDBManager.sharedInstance.getAvailableRequestToken() {
                                performUIUpdatesOnMain {
                                        let urlString = "\(TMDBConstants.AuthenticateURL)/\(requestToken)"
                                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                                    self.performSegueWithIdentifier("presentLoginFromStart", sender: urlString)
                                }
                            }
                        } catch {}
                    }
                }
                
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance.authenticationTokenNew(completion)
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
