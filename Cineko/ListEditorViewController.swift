//
//  ListEditorViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 09/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import Eureka
import JJJUtils
import MBProgressHUD

protocol ListEditorViewControllerDelegate : NSObjectProtocol {
    func listEditorAction(editor: ListEditorViewController, name: String, description: String)
}

class ListEditorViewController : FormViewController {
    // MARK: Variables
    var delegate:ListEditorViewControllerDelegate?
    var listName:String?
    var listDescription:String?
    
    // MARK: Actions
    @IBAction func saveAction(sender: UIBarButtonItem) {
        if let name = form.values()["name"] as? String {
            
            if let description = form.values()["description"] as? String {
                if let delegate = self.delegate {
                    delegate.listEditorAction(self, name: name, description: description)
                }
                
            } else {
                JJJUtil.alertWithTitle("Error", andMessage:"Description is blank.")
            }
        }  else {
            JJJUtil.alertWithTitle("Error", andMessage:"Name is blank.")
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
