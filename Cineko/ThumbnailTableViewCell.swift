//
//  ScrollingTableViewCell.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import SDWebImage

protocol ThumbnailTableViewCellDelegate : NSObjectProtocol {
    func seeAllAction(tag: Int)
    func didSelectItem(tag: Int, dict: [String: AnyObject])
}

class ThumbnailTableViewCell: UITableViewCell {
    // MARK: Constants
    static let Height:CGFloat = 180
    static let MaxItems = 12
    struct Keys {
        static let ID      = "id"
        static let OID     = "oid"
        static let URL     = "url"
        static let Caption  = "caption"
    }
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: Variables
    weak var delegate: ThumbnailTableViewCellDelegate?
    var data:[[String: AnyObject]]?
    var showCaption = false
    private var imageSizeAdjusted = false

    // MARK: Actions
    @IBAction func seeAllAction(sender: UIButton) {
        if let delegate = delegate {
            delegate.seeAllAction(self.tag)
        }
    }
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let width = collectionView.frame.size.width / CGFloat(visibleThumbnails)
//        let height = collectionView.frame.size.height
        let space = CGFloat(5.0)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
//        flowLayout.itemSize = CGSizeMake(width, height)
        
        collectionView.registerNib(UINib(nibName: "ThumbnailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// MARK: UICollectionViewDataSource
extension ThumbnailTableViewCell : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = data {
            return data.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ThumbnailCollectionViewCell
        
        if let data = data {
            if let urlString = data[indexPath.row][Keys.URL] as? String {
                let url = NSURL(string: urlString)
                let completedBlock = { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) in
                    if self.showCaption {
                        if let caption = data[indexPath.row][Keys.Caption] as? String {
                            cell.captionLabel.text = caption
                            let average = image.averageColor()
//                          cell.captionLabel.shadowColor = image.patternColor(average)
//                          cell.captionLabel.textColor = average
                            cell.captionLabel.textColor = image.patternColor(average)
                        }
                    } else {
                        cell.captionLabel.text = nil
                    }
                    
                    if !self.imageSizeAdjusted &&
                        image != nil  {
                        let imageWidth = image.size.width
                        let imageHeight = image.size.height
                        let height = collectionView.frame.size.height
                        let newWidth = (imageWidth * height) / imageHeight
                        self.flowLayout.itemSize = CGSizeMake(newWidth, height)
                        self.imageSizeAdjusted = true
                    }
                }
                cell.thumbnailImage.sd_setImageWithURL(url, completed: completedBlock)
                
            } else {
                cell.thumbnailImage.image = UIImage(named: "noImage")
                if let caption = data[indexPath.row][Keys.Caption] as? String {
                    cell.captionLabel.text = caption
                    cell.captionLabel.textColor = UIColor.redColor()
                }
            }
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension ThumbnailTableViewCell : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate,
            let data = data {
            delegate.didSelectItem(self.tag, dict: data[indexPath.row])
        }
    }
}


