//
//  DetailsAndTweetsTableViewCell.swift
//  Cineko
//
//  Created by Jovit Royeca on 18/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

enum DetailsAndTweetsSelection {
    case Details
    case Tweets
}

protocol DetailsAndTweetsTableViewCellDelegate : NSObjectProtocol {
    func selectionChanged(selection: DetailsAndTweetsSelection)
}

class DetailsAndTweetsTableViewCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: Variables
    var delegate:DetailsAndTweetsTableViewCellDelegate?
    
    // MARK: Actions
    @IBAction func segmentedAction(sender: UISegmentedControl) {
        if let delegate = delegate {
            delegate.selectionChanged(sender.selectedSegmentIndex == 0 ? .Details : .Tweets)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Custom Methods
    func changeColor(backgroundColor: UIColor?, fontColor: UIColor?) {
        self.backgroundColor = backgroundColor
        
        if let fontColor = fontColor {
            segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: fontColor], forState: .Normal)
            segmentedControl.tintColor = fontColor
        }
    }
}
