//
//  ListEditorViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 09/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import Eureka
import MBProgressHUD

protocol ListEditorViewControllerDelegate : NSObjectProtocol {
    func success(editor: ListEditorViewController)
    func failure(editor: ListEditorViewController, error: NSError?)
}

class ListEditorViewController : FormViewController {
    // MARK: Variables
    var delegate:ListEditorViewControllerDelegate?
    
    // MARK: Actions
    @IBAction func saveAction(sender: UIBarButtonItem) {
        if let name = form.values()["name"] as? String,
            let description = form.values()["description"] as? String {
            
            let completion = { (error: NSError?) in
                performUIUpdatesOnMain {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    if let error = error {
                        print("Error in: \(#function)... \(error)")
                        
                        if let delegate = self.delegate {
                            delegate.failure(self, error: error)
                        }
                        
                    } else {
                        if let delegate = self.delegate {
                                delegate.success(self)
                        }
                    }
                }
            }
            
            do {
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                try TMDBManager.sharedInstance().createList(name, description: description, completion: completion)
            } catch {
                MBProgressHUD.hideHUDForView(view, animated: true)
                if let delegate = self.delegate {
                    delegate.failure(self, error: nil)
                }
            }
        }
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        form =
            Section("")
        
            +++ Section("Name")
            <<< TextRow() {
                $0.tag = "name"
            }
            
            +++ Section("Description")
            <<< TextAreaRow() {
                $0.tag = "description"
            }
    }
}
