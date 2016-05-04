//
//  DynamicHeightTableViewCell.swift
//  Cineko
//
//  Created by Jovit Royeca on 12/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

class DynamicHeightTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dynamicLabel: UILabel!
    
    // MARK: Overrides
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
        dynamicLabel.textColor = fontColor
        
        if accessoryType != .None {
            if let image = UIImage(named: "forward") {
                let tintedImage = image.imageWithRenderingMode(.AlwaysTemplate)
                let imageView = UIImageView(image: tintedImage)
                imageView.tintColor = fontColor
                accessoryView = imageView
            }
        }
    }
}
