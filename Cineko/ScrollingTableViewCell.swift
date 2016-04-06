//
//  ScrollingTableViewCell.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import SDWebImage

protocol ScrollingTableViewCellDelegate : NSObjectProtocol {
    func seeAllAction(tag: Int);
    func didSelectItem(tag: Int, dict: [String: AnyObject])
}

class ScrollingTableViewCell: UITableViewCell {
    // MARK: Constants
    static let Height:CGFloat = 150
    static let MaxItems = 12
    struct Keys {
        static let ID  = "id"
        static let URL = "url"
    }
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Variables
    weak var delegate: ScrollingTableViewCellDelegate?
    var data:[[String: AnyObject]]?
    
    // MARK: Actions
    @IBAction func seeAllAction(sender: UIButton) {
        if let delegate = delegate {
            delegate.seeAllAction(tag)
        }
    }
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
extension ScrollingTableViewCell : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ScrollingTableViewCell.MaxItems
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ThumbnailCollectionViewCell
        
        if let data = data {
            cell.imageView.sd_setImageWithURL(NSURL(string: data[indexPath.row][Keys.URL] as! String), placeholderImage: UIImage(named: "image"))
        }
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension ScrollingTableViewCell : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate,
            let data = data {
            delegate.didSelectItem(tag, dict: data[indexPath.row])
        }
    }
}

