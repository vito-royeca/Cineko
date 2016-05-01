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
    
    @IBOutlet weak var dateIcon: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationIcon: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var ratingIcon: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateLabel.adjustsFontSizeToFitWidth = true
        durationLabel.adjustsFontSizeToFitWidth = true
        ratingLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Custom Methods
    func changeColor(backgroundColor: UIColor?, fontColor: UIColor?) {
        self.backgroundColor = backgroundColor
        
        if let image = dateIcon.image {
            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
            dateIcon.image = tintedImage
            dateIcon.tintColor = fontColor
        }
        
        if let image = durationIcon.image {
            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
            durationIcon.image = tintedImage
            durationIcon.tintColor = fontColor
        }
        
        if let image = ratingIcon.image {
            let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
            ratingIcon.image = tintedImage
            ratingIcon.tintColor = fontColor
        }
        
        dateLabel.textColor = fontColor
        durationLabel.textColor = fontColor
        ratingLabel.textColor = fontColor
    }
}
