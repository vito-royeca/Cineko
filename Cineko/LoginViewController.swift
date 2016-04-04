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

class LoginViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var webView: UIWebView!
    
    // MARL: Variables
    var authenticationURLString:String?
    var requestToken:String?
    
    // MARK: Actions
    @IBAction func doneAction(sender: UIBarButtonItem) {
        if let _ = TMDBManager.sharedInstance().sessionID {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
            
            self.presentViewController(controller, animated: true, completion: nil)
            
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.bounces = false
        webView.delegate = self
        if let authenticationURLString  = authenticationURLString {
            if let authURL = NSURL(string: authenticationURLString) {
                requestToken = authURL.lastPathComponent
                webView.loadRequest(NSURLRequest(URL: authURL))
            }
        }
    }
    
    // MARK: Utility methods
    func requestSessionID() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let sessionID = dict[Constants.TMDBRequestSessionID.SessionID] as? String {
                    TMDBManager.sharedInstance().sessionID = sessionID
                    
                    performUIUpdatesOnMain {
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        self.doneButton.enabled = true
                        self.cancelButton.enabled = false
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
        
        if let requestToken = requestToken {
            TMDBManager.sharedInstance().requestSessionID(requestToken, success: success, failure: failure);
        }
    }
}

extension LoginViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let url = request.URL {
            if let lastPath = url.lastPathComponent {
                if lastPath == "deny" {
                    doneButton.enabled = true
                    cancelButton.enabled = false
                
                } else if lastPath == "allow" {
                    requestSessionID()
                    
                }  else if lastPath == "signup" {
                    
                }
            }
        }
        
        return true
    }
}
