//
//  ThumbnailCollectionViewCell.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

public enum DisplayType : Int {
    case Poster
    case Backdrop
    case Profile
}
public enum CaptionType : Int {
    case Title
    case Name
    case Job
    case Role
    case NameAndJob
    case NameAndRole
}

protocol ThumbnailDisplayable : NSObjectProtocol {
    func imagePath(displayType: DisplayType) -> String?
    func caption(captionType: CaptionType) -> String?
}


protocol ThumbnailDelegate : NSObjectProtocol {
    func seeAllAction(tag: Int)
    func didSelectItem(tag: Int, displayable: ThumbnailDisplayable, path: NSIndexPath)
}


class ThumbnailCollectionViewCell: UICollectionViewCell {
    // MARK: Outlets
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    // MARK: Variables
    var HUDAdded = false

    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func prepareForReuse() {
        thumbnailImage.image = UIImage(named: "noImage")
    }
    
    // MARK: Custom methods
    func addCaptionImage(text: String) {
        if let image = thumbnailImage.image {
            let textColor = UIColor.blackColor()
            let font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)

            // Compute rect to draw the text inside
            let imageSize = thumbnailImage.frame.size //image.size
            let attr = [NSForegroundColorAttributeName: textColor, NSFontAttributeName: font]
            let textSize = text.sizeWithAttributes(attr)
            let width = imageSize.width
            let widthNum = textSize.width > imageSize.width ? Int(textSize.width/imageSize.width) : 1
            let widthExcess = textSize.width > imageSize.width ? Int(textSize.width%imageSize.width) : 0
            let height = (textSize.height * CGFloat(widthNum)) + (widthExcess > 0 ? textSize.height : 0)
            let textRect = CGRectMake(0, imageSize.height - height, width, height)

            // Create the image
            UIGraphicsBeginImageContextWithOptions(imageSize, true, 0.0)
            image.drawInRect(CGRectMake(0, 0, imageSize.width, imageSize.height))
            
            // Background
            let context = UIGraphicsGetCurrentContext()
            UIColor.whiteColor().colorWithAlphaComponent(0.60).set()
            CGContextFillRect(context, textRect)
            
            // Text
            text.drawInRect(CGRectIntegral(textRect), withAttributes:attr)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            // done creating the image
            UIGraphicsEndImageContext()
            
            thumbnailImage.image = newImage
        }
    }
}
