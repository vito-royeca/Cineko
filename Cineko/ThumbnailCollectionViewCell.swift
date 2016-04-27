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
    @IBOutlet weak var captionLabel: UILabel!
    
    // MARK: Variables
    var hasHUD = false
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        captionLabel.adjustsFontSizeToFitWidth = true
    }

}
