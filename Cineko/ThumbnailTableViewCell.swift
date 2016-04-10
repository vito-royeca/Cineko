//
//  ScrollingTableViewCell.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import SDWebImage

public enum ThumbnailType : Int {
    case InTheaters
    case OnTV
    case PopularPeople
}

protocol ThumbnailTableViewCellDelegate : NSObjectProtocol {
    func seeAllAction(type: ThumbnailType);
    func didSelectItem(type: ThumbnailType, dict: [String: AnyObject])
}

class ThumbnailTableViewCell: UITableViewCell {
    // MARK: Constants
    static let Height:CGFloat = 180
    static let MaxItems = 12
    struct Keys {
        static let ID  = "id"
        static let URL = "url"
    }
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: Variables
    weak var delegate: ThumbnailTableViewCellDelegate?
    var data:[[String: AnyObject]]?
    var thumbnailType: ThumbnailType?
    
    // MARK: Actions
    @IBAction func seeAllAction(sender: UIButton) {
        if let delegate = delegate {
            delegate.seeAllAction(thumbnailType!)
        }
    }
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let width = collectionView.frame.size.width / 3
        let height = collectionView.frame.size.height
        let space = CGFloat(5.0)
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(width, height)
        
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
        return ThumbnailTableViewCell.MaxItems
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ThumbnailCollectionViewCell
        
        if let data = data {
            if let urlString = data[indexPath.row][Keys.URL] as? String {
                cell.imageView.sd_setImageWithURL(NSURL(string: urlString), placeholderImage: UIImage(named: "image"))
                
            } else {
                if let thumbnailType = thumbnailType {
                    switch thumbnailType {
                        case .InTheaters:
                            cell.imageView.image = UIImage(named: "movie")
                        case .OnTV:
                            cell.imageView.image = UIImage(named: "tv")
                        case .PopularPeople:
                            cell.imageView.image = UIImage(named: "people")
                    }

                } else {
                    cell.imageView.image = nil
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
            let data = data,
            let thumbnailType = thumbnailType {
            delegate.didSelectItem(thumbnailType, dict: data[indexPath.row])
        }
    }
}


