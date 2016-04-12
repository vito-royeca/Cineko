//
//  MediaInfoTableViewCell.swift
//  Cineko
//
//  Created by Jovit Royeca on 11/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

class MediaInfoTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        overviewLabel.sizeToFit()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
