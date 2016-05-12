//
//  SearchSettingsViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 12/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import Eureka
import MMDrawerController

class SearchSettingsViewController: FormViewController {

    // MARK: Actions
    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        composeForm()
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        composeForm()
        mm_drawerController.showsShadow = false
    }

    func composeForm() {
        let components = NSCalendar.currentCalendar().components(.Year, fromDate: NSDate())
        let currentYear = components.year
        let minimumYear = 1900
        
        form =
            Section("")
            
            +++ Section("Movies")
            <<< SwitchRow() {
                $0.tag = "movieIncludeYear"
                $0.title = "Include Year Released"
                $0.value = false
            }
            <<< PickerInlineRow<Int>("movieYearReleased") { (row : PickerInlineRow<Int>) -> Void in
                row.options = []
                for year in currentYear.stride(to: minimumYear, by: -1) {
                    row.options.append(year)
                }
                row.title = "Year Released"
                row.value = row.options[0]
                row.disabled = "$movieIncludeYear = false"
            }
            <<< SwitchRow() {
                $0.tag = "movieIncludeAdult"
                $0.title = "Include Adult"
                $0.value = true
            }
            
            +++ Section("TV Shows")
            <<< SwitchRow() {
                $0.tag = "tvShowIncludeYear"
                $0.title = "Include First Air Date"
                $0.value = false
            }
            <<< PickerInlineRow<Int>("tvShowFirstAirDate") { (row : PickerInlineRow<Int>) -> Void in
                row.options = []
                for year in currentYear.stride(to: minimumYear, by: -1) {
                    row.options.append(year)
                }
                row.title = "First Air Date"
                row.value = row.options[0]
                row.disabled = "$tvShowIncludeYear = false"
            }
            <<< SwitchRow() {
                $0.tag = "tvShowIncludeAdult"
                $0.title = "Include Adult"
                $0.value = true
            }
            
            +++ Section("People")
            <<< SwitchRow() {
                $0.tag = "peopleIncludeAdult"
                $0.title = "Include Adult"
                $0.value = true
        }
    }
    
}

