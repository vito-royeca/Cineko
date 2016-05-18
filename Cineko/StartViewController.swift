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
                self.presentLoginViewController(urlString)
            
            } else {
                let success = { (results: AnyObject!) in
                    if let dict = results as? [String: AnyObject] {
                        if let requestToken = dict[TMDBConstants.Authentication.TokenNew.Keys.RequestToken] as? String {
                            
                            do {
                             try TMDBManager.sharedInstance.saveRequestToken(requestToken)
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
                    MBProgressHUD.showHUDAddedTo(view, animated: true)
                    try TMDBManager.sharedInstance.authenticationTokenNew(success, failure: failure)
                } catch {}
            }
        } catch {}
    }
    
    @IBAction func skipLoginAction(sender: UIButton) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("DrawerController") as? MMDrawerController {
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: Utility methods
    func presentLoginViewController(authenticateURLString: String) {
        if let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
            controller.authenticationURLString = authenticateURLString
            controller.delegate = self
            self.presentViewController(controller, animated: true, completion: nil)
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
