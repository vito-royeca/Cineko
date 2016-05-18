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

protocol LoginViewControllerDelegate : NSObjectProtocol {
    func loginSuccess(viewController: UIViewController)
}

class LoginViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Variables
    var authenticationURLString:String?
    var hasHUD = false
    var delegate:LoginViewControllerDelegate?
    
    // MARK: Actions
    @IBAction func doneAction(sender: UIBarButtonItem) {
        if let delegate = delegate {
            delegate.loginSuccess(self)
        }
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.bounces = false
        webView.delegate = self
        if let authenticationURLString  = authenticationURLString {
            if let authURL = NSURL(string: authenticationURLString) {
                webView.loadRequest(NSURLRequest(URL: authURL))
            }
        }
    }
    
    // MARK: Utility methods
    func requestSessionID() {
        if !hasHUD {
            MBProgressHUD.showHUDAddedTo(webView, animated: true)
            hasHUD = true
        }
        
        let completion = { (error: NSError?) in
            performUIUpdatesOnMain {
                MBProgressHUD.hideHUDForView(self.webView, animated: true)
                self.hasHUD = false
                
                if let error = error {
                    JJJUtil.alertWithTitle("Error", andMessage:"\(error.userInfo[NSLocalizedDescriptionKey]!)")
                } else {
                    self.doneButton.enabled = true
                    self.cancelButton.enabled = false
                }
            }
        }
        
        do {
            try TMDBManager.sharedInstance.authenticationSessionNew(completion)
        } catch {}
    }
}

// MARK: UIWebViewDelegate
extension LoginViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if !hasHUD {
            MBProgressHUD.showHUDAddedTo(webView, animated: true)
            hasHUD = true
        }
        return true
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        MBProgressHUD.hideHUDForView(webView, animated: true)
        hasHUD = false
        
        if let request = webView.request {
            if let url = request.URL {
                if url.absoluteString.containsString("/account/") {
                    requestSessionID()
                } else {
                    if let lastPath = url.lastPathComponent {
                        do {
                            if try lastPath == TMDBManager.sharedInstance.getAvailableRequestToken() {
                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                hasHUD = false
                                
                            } else if lastPath == "deny" {
                                try TMDBManager.sharedInstance.removeRequestToken()
                                doneButton.enabled = true
                                cancelButton.enabled = false
                                
                            } else if lastPath == "allow" {
                                requestSessionID()
                                
                            }  else if lastPath == "signup" {
                                
                            }
                        } catch {}
                    }
                }
            }
        }
    }
}
