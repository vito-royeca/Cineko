//
//  MoviesViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import BLKFlexibleHeightBar

class MoviesViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var myCustomBar:FacebookStyleBar?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        
        // Setup the custom bar
        myCustomBar = FacebookStyleBar(frame:CGRectMake(0.0, 0.0, CGRectGetWidth(view.frame), 100.0))
        let behaviorDefiner = FacebookStyleBarBehaviorDefiner()
        behaviorDefiner.addSnappingPositionProgress(0.0, forProgressRangeStart:0.0, end:40.0/(105.0-20.0))
        behaviorDefiner.addSnappingPositionProgress(1.0, forProgressRangeStart:40.0/(105.0-20.0), end:1.0)
        behaviorDefiner.snappingEnabled = true
        behaviorDefiner.thresholdNegativeDirection = 140.0
        let scrollView = tableView as UIScrollView
        scrollView.delegate = behaviorDefiner
        myCustomBar!.behaviorDefiner = behaviorDefiner
        view.addSubview(myCustomBar!)
        
        tableView.contentInset = UIEdgeInsetsMake(myCustomBar!.maximumBarHeight, 0.0, 0.0, 0.0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"Cell")
    }
}

// MARK: UITableViewDataSource
extension MoviesViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        return cell
    }
}

// MARK: UITableViewDelegate
extension MoviesViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let nc = UINavigationController(rootViewController: self)
        let vc = UIViewController(nibName: nil, bundle: nil)
        vc.view.backgroundColor = UIColor.greenColor()
        nc.setViewControllers([vc], animated: false)
//        presentViewController(nc, animated: true, completion: nil)
        view.addSubview(nc.view)
    }
}
