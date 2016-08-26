//
//  Cine_Ko_UITests.swift
//  Cine Ko!UITests
//
//  Created by Jovit Royeca on 22/06/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import XCTest
import SimulatorStatusMagic

class Cine_Ko_UITests: XCTestCase {
        
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        // SimulatorStatusMagic
        SDStatusBarManager.sharedInstance().enableOverrides()
        
        continueAfterFailure = false
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTakeScreenshots() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // set landscape for iPad Pro
        if UIScreen.mainScreen().bounds.size.width > 1024 {
            let value = UIInterfaceOrientation.LandscapeLeft.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        }
    
//        snapshot("00-InitialScreen")
        
        app.buttons["Skip Login"].tap()
        sleep(20)
        
        let tablesQuery = app.tables
        let seeAllButton = tablesQuery.cells.containingType(.StaticText, identifier:"Now Showing").buttons["See All >"]
        seeAllButton.tap()
        sleep(20)
        snapshot("01-NowShowing")
        let featuredButton = app.navigationBars["Now Showing"].buttons["Featured"]
        featuredButton.tap()
        
        snapshot("00-Featured")
        
        app.tabBars.buttons["Movies"].tap()
        sleep(20)
        snapshot("02-Movies")
        
        app.tabBars.buttons["TV Shows"].tap()
        sleep(20)
        snapshot("03-TVShows")
        
        app.tabBars.buttons["Search"].tap()
        let button = app.navigationBars["Cine_Ko_.SearchView"].childrenMatchingType(.Button).elementBoundByIndex(1)
        button.tap()
        snapshot("04-SearchSettings")
    }
    
}
