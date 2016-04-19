//
//  ScrollingTableViewCell.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD
import SDWebImage

public enum DisplayType : Int {
    case Poster
    case Backdrop
    case Profile
}

protocol ThumbnailTableViewCellDisplayable : NSObjectProtocol {
    func path(displayType: DisplayType) -> String?
    func caption(displayType: DisplayType) -> String?
}


protocol ThumbnailTableViewCellDelegate : NSObjectProtocol {
    func seeAllAction(tag: Int)
    func didSelectItem(tag: Int, displayable: ThumbnailTableViewCellDisplayable)
}

class ThumbnailTableViewCell: UITableViewCell {
    // MARK: Constants
    static let Height:CGFloat = 180
    static let MaxItems = 12
    
    // MARK: Variables
    weak var delegate: ThumbnailTableViewCellDelegate?
    var displayType:DisplayType?
    var showCaption = false
    private var imageSizeAdjusted = false
    private var noDataLabel:UILabel?
    var fetchRequest:NSFetchRequest?
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let context = CoreDataManager.sharedInstance().mainObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest!,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
    }()
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

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
        let space = CGFloat(5.0)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        collectionView.registerNib(UINib(nibName: "ThumbnailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: Custom methods
    func loadData() {
        var items = 0
        
        if (fetchRequest) != nil {
            do {
                try fetchedResultsController.performFetch()
            } catch {}
            fetchedResultsController.delegate = self
            
            if let sections = fetchedResultsController.sections {
                if let sectionInfo = sections.first {
                    items = sectionInfo.numberOfObjects
                }
            }
        }
        
        if items > 0 {
            if let noDataLabel = noDataLabel {
                noDataLabel.removeFromSuperview()
            }
            collectionView.reloadData()
        } else {
            if noDataLabel == nil {
                let width = collectionView.frame.size.width/2
                let height = collectionView.frame.size.height/2
                let x = collectionView.frame.size.width/4
                let y = collectionView.frame.size.height/4
                noDataLabel = UILabel(frame: CGRectMake(x, y, width, height))
                noDataLabel!.textAlignment = .Center
                noDataLabel!.text = "No Data Found"
                noDataLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
                collectionView.addSubview(noDataLabel!)
            }
        }
    }
    
    func configureCell(cell: ThumbnailCollectionViewCell, displayable: ThumbnailTableViewCellDisplayable) {
        if let path = displayable.path(displayType!) {
            var urlString:String?
            
            switch displayType! {
            case .Poster:
                urlString = "\(TMDBConstants.ImageURL)/\(TMDBConstants.PosterSizes[0])\(path)"
            case .Profile:
                urlString = "\(TMDBConstants.ImageURL)/\(TMDBConstants.ProfileSizes[1])\(path)"
            case .Backdrop:
                urlString = "\(TMDBConstants.ImageURL)/\(TMDBConstants.BackdropSizes[0])\(path)"
            }
            
            let url = NSURL(string: urlString!)
            let completedBlock = { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) in
                if self.showCaption {
                    cell.captionLabel.text = displayable.caption(self.displayType!)
                    cell.captionLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
                } else {
                    cell.captionLabel.text = nil
                    cell.captionLabel.backgroundColor = nil
                }
                
                if !self.imageSizeAdjusted &&
                    image != nil  {
                    let imageWidth = image.size.width
                    let imageHeight = image.size.height
                    let height = self.collectionView.frame.size.height
                    let newWidth = (imageWidth * height) / imageHeight
                    self.flowLayout.itemSize = CGSizeMake(newWidth, height)
                    self.imageSizeAdjusted = true
                }
                
                MBProgressHUD.hideHUDForView(cell, animated: true)
                cell.hasHUD = false
            }
            
            if !cell.hasHUD && cell.thumbnailImage.image == nil {
                MBProgressHUD.showHUDAddedTo(cell, animated: true)
                cell.hasHUD = true
            }
            cell.thumbnailImage.sd_setImageWithURL(url, completed: completedBlock)
            
        } else {
            cell.thumbnailImage.image = UIImage(named: "noImage")
            cell.captionLabel.text = displayable.caption(displayType!)
//            cell.captionLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            cell.captionLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
        }
    }
}

// MARK: UICollectionViewDataSource
extension ThumbnailTableViewCell : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (fetchRequest) != nil,
            let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
        
            return sectionInfo.numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ThumbnailCollectionViewCell
        
        if let displayable = fetchedResultsController.objectAtIndexPath(indexPath) as? ThumbnailTableViewCellDisplayable {
            configureCell(cell, displayable: displayable)
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension ThumbnailTableViewCell : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate,
            let displayable = fetchedResultsController.objectAtIndexPath(indexPath) as? ThumbnailTableViewCellDisplayable {
            delegate.didSelectItem(self.tag, displayable: displayable)
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension ThumbnailTableViewCell : NSFetchedResultsControllerDelegate {
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            collectionView.insertSections(NSIndexSet(index: sectionIndex))
            
        case .Delete:
            collectionView.deleteSections(NSIndexSet(index: sectionIndex))
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            collectionView.insertItemsAtIndexPaths([newIndexPath!])
            
        case .Delete:
            collectionView.deleteItemsAtIndexPaths([indexPath!])
            
        case .Update:
            if let indexPath = indexPath {
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                    
                    if let c = cell as? ThumbnailCollectionViewCell,
                        let displayable = fetchedResultsController.objectAtIndexPath(indexPath) as? ThumbnailTableViewCellDisplayable {
                        configureCell(c, displayable: displayable)
                    }
                }
            }
            
        case .Move:
            collectionView.deleteItemsAtIndexPaths([indexPath!])
            collectionView.insertItemsAtIndexPaths([newIndexPath!])
        }
    }
}

