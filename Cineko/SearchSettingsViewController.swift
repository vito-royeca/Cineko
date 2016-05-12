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

struct SearchSettingsKeys {
    static let MovieIncludeYearReleased = "MovieIncludeYearReleased"
    static let MovieYearReleased = "MovieYearReleased"
    static let MovieIncludeAdult = "MovieIncludeAdult"
    static let TVShowIncludeFirstAirDate = "TVShowIncludeFirstAirDate"
    static let TVShowFirstAirDate = "TVShowFirstAirDate"
    static let PeopleIncludeAdult = "PeopleIncludeAdult"
}

class SearchSettingsViewController: FormViewController {

    // MARK: Constants
    let minimumYear = 1900
    
    // MARK: Variables
    var currentYear = 0
    
    // MARK: Actions
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: SearchSettingsKeys.MovieIncludeYearReleased)
        NSUserDefaults.standardUserDefaults().setInteger(currentYear, forKey: SearchSettingsKeys.MovieYearReleased)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: SearchSettingsKeys.MovieIncludeAdult)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: SearchSettingsKeys.TVShowIncludeFirstAirDate)
        NSUserDefaults.standardUserDefaults().setInteger(currentYear, forKey: SearchSettingsKeys.TVShowFirstAirDate)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: SearchSettingsKeys.PeopleIncludeAdult)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        composeForm()
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let components = NSCalendar.currentCalendar().components(.Year, fromDate: NSDate())
        currentYear = components.year
        
        composeForm()
        mm_drawerController.showsShadow = false
    }

    func composeForm() {
        
        form =
            Section("")
            
            // Movies
            +++ Section("Movies")
            <<< SwitchRow() {
                    $0.title = "Include Year Released"
                    $0.tag = SearchSettingsKeys.MovieIncludeYearReleased
                    $0.value = NSUserDefaults.standardUserDefaults().boolForKey(SearchSettingsKeys.MovieIncludeYearReleased)
                }.onChange { row in
                    NSUserDefaults.standardUserDefaults().setBool(row.value!, forKey: SearchSettingsKeys.MovieIncludeYearReleased)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            
            <<< PickerInlineRow<Int>("movieYearReleased") { (row : PickerInlineRow<Int>) -> Void in
                    row.options = []
                    for year in currentYear.stride(to: minimumYear, by: -1) {
                        row.options.append(year)
                    }
                    row.disabled = "$MovieIncludeYearReleased = false"
                    row.title = "Year Released"
                    row.tag = SearchSettingsKeys.MovieYearReleased
                    let year = NSUserDefaults.standardUserDefaults().integerForKey(SearchSettingsKeys.MovieYearReleased)
                    row.value = year > 0 ? year : currentYear
                }.onChange { row in
                    NSUserDefaults.standardUserDefaults().setInteger(row.value!, forKey: SearchSettingsKeys.MovieYearReleased)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            
            <<< SwitchRow() {
                    $0.title = "Include Adult"
                    $0.tag = SearchSettingsKeys.MovieIncludeAdult
                    $0.value = NSUserDefaults.standardUserDefaults().boolForKey(SearchSettingsKeys.MovieIncludeAdult)
                }.onChange { row in
                    NSUserDefaults.standardUserDefaults().setBool(row.value!, forKey: SearchSettingsKeys.MovieIncludeAdult)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            
            // TV Shows
            +++ Section("TV Shows")
            <<< SwitchRow() {
                    $0.title = "Include First Air Date"
                    $0.tag = SearchSettingsKeys.TVShowIncludeFirstAirDate
                    $0.value = NSUserDefaults.standardUserDefaults().boolForKey(SearchSettingsKeys.TVShowIncludeFirstAirDate)
                }.onChange { row in
                    NSUserDefaults.standardUserDefaults().setBool(row.value!, forKey: SearchSettingsKeys.TVShowIncludeFirstAirDate)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            
            <<< PickerInlineRow<Int>("tvShowFirstAirDate") { (row : PickerInlineRow<Int>) -> Void in
                    row.options = []
                    for year in currentYear.stride(to: minimumYear, by: -1) {
                        row.options.append(year)
                    }
                    row.disabled = "$TVShowIncludeFirstAirDate = false"
                    row.title = "First Air Date"
                    row.tag = SearchSettingsKeys.TVShowFirstAirDate
                    let year = NSUserDefaults.standardUserDefaults().integerForKey(SearchSettingsKeys.TVShowFirstAirDate)
                    row.value = year > 0 ? year : currentYear
                }.onChange { row in
                    NSUserDefaults.standardUserDefaults().setInteger(row.value!, forKey: SearchSettingsKeys.TVShowFirstAirDate)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            
            +++ Section("People")
            <<< SwitchRow() {
                    $0.title = "Include Adult"
                    $0.tag = SearchSettingsKeys.PeopleIncludeAdult
                    $0.value = NSUserDefaults.standardUserDefaults().boolForKey(SearchSettingsKeys.PeopleIncludeAdult)
                }.onChange { row in
                    NSUserDefaults.standardUserDefaults().setBool(row.value!, forKey: SearchSettingsKeys.PeopleIncludeAdult)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
    }
    
}

