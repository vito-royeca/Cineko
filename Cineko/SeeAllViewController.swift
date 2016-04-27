//
//  SeeAllViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 20/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class SeeAllViewController: UIViewController {
    // MARK: Constants
    static let Height:CGFloat = 180
    static let MaxItems = 12
    static let MaxImageWidth = CGFloat(80)
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: Variables
    weak var delegate: ThumbnailDelegate?
    var displayType:DisplayType?
    var captionType:CaptionType?
    var showCaption = false
    var fetchRequest:NSFetchRequest?
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let context = CoreDataManager.sharedInstance().mainObjectContext
        self.fetchRequest!.fetchLimit = -1
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest!,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
    }()
    private var shouldReloadCollectionView = false
    private var blockOperation:NSBlockOperation?
    private var imageSizeAdjusted = false

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        let space = CGFloat(1.0)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        collectionView.registerNib(UINib(nibName: "ThumbnailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        loadData()
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
    
    // MARK: Custom methods
    func loadData() {
        if (fetchRequest) != nil {
            do {
                try fetchedResultsController.performFetch()
            } catch {}
            fetchedResultsController.delegate = self
        }
    }
    
    func configureCell(cell: ThumbnailCollectionViewCell, displayable: ThumbnailDisplayable) {
        if let path = displayable.imagePath(displayType!) {
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
                cell.contentMode = .ScaleToFill
                
                if let image = image {
                    if !self.imageSizeAdjusted {
                        let space: CGFloat = 1.0
                        let imageHeight = image.size.height
                        let imageWidth = image.size.width
                        let idealWidth = (self.view.frame.size.width - (3*space)) / 3.0
                        let width = idealWidth > SeeAllViewController.MaxImageWidth ? SeeAllViewController.MaxImageWidth : idealWidth
                        let height = (imageHeight*width)/imageWidth
                        self.flowLayout.minimumInteritemSpacing = space
                        self.flowLayout.minimumLineSpacing = space
                        self.flowLayout.itemSize = CGSizeMake(width, height)
                        self.imageSizeAdjusted = true
                    }
                } else {
                    var caption:String?
                    if let captionType = self.captionType {
                        caption = displayable.caption(captionType)
                    }
                    self.setDefaultImageForCell(cell, caption: caption)
                }
                
                if self.showCaption {
                    cell.captionLabel.text = displayable.caption(self.captionType!)
                    cell.captionLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
                    cell.captionLabel.textColor = UIColor.blackColor()
                } else {
                    cell.captionLabel.text = nil
                    cell.captionLabel.backgroundColor = nil
                }
            }
            cell.thumbnailImage.sd_setImageWithURL(url, completed: completedBlock)
            
        } else {
            var caption:String?
            if let captionType = self.captionType {
                caption = displayable.caption(captionType)
            }
            setDefaultImageForCell(cell, caption: caption)
        }
    }
    
    func setDefaultImageForCell(cell: ThumbnailCollectionViewCell, caption: String?) {
        if let image = UIImage(named: "noImage") {
            if !imageSizeAdjusted {
                let space: CGFloat = 1.0
                let imageHeight = image.size.height
                let imageWidth = image.size.width
                let idealWidth = (self.view.frame.size.width - (3*space)) / 3.0
                let width = idealWidth > SeeAllViewController.MaxImageWidth ? SeeAllViewController.MaxImageWidth : idealWidth
                let height = (imageHeight*width)/imageWidth
                self.flowLayout.minimumInteritemSpacing = space
                self.flowLayout.minimumLineSpacing = space
                self.flowLayout.itemSize = CGSizeMake(width, height)
//                imageSizeAdjusted = true
            }
            cell.thumbnailImage.image = image
            cell.contentMode = .ScaleToFill
        }
        
        if let caption = caption {
            cell.captionLabel.text = caption
            cell.captionLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
            cell.captionLabel.textColor = UIColor.blackColor()
        }
    }
}

// MARK: UICollectionViewDataSource
extension SeeAllViewController : UICollectionViewDataSource {
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
        
        if let displayable = fetchedResultsController.objectAtIndexPath(indexPath) as? ThumbnailDisplayable {
            configureCell(cell, displayable: displayable)
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension SeeAllViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate,
            let displayable = fetchedResultsController.objectAtIndexPath(indexPath) as? ThumbnailDisplayable {
            delegate.didSelectItem(self.view.tag, displayable: displayable)
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension SeeAllViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        shouldReloadCollectionView = false
        blockOperation = NSBlockOperation()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            blockOperation!.addExecutionBlock({
                self.collectionView.insertSections(NSIndexSet(index: sectionIndex))
            })
            
        case .Delete:
            blockOperation!.addExecutionBlock({
                self.collectionView.deleteSections(NSIndexSet(index: sectionIndex))
            })
            
        case .Update:
            blockOperation!.addExecutionBlock({
                self.collectionView.reloadSections(NSIndexSet(index: sectionIndex))
            })
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            if collectionView.numberOfSections() > 0 {
                if let indexPath = indexPath {
                    if collectionView.numberOfItemsInSection(indexPath.section) == 0 {
                        shouldReloadCollectionView = true
                    } else {
                        blockOperation!.addExecutionBlock({
                            self.collectionView.insertItemsAtIndexPaths([newIndexPath!])
                        })
                    }
                }
            } else {
                shouldReloadCollectionView = true
            }
            
        case .Delete:
            if collectionView.numberOfItemsInSection(indexPath!.section) == 1 {
                shouldReloadCollectionView = true
            } else {
                blockOperation!.addExecutionBlock({
                    self.collectionView.deleteItemsAtIndexPaths([indexPath!])
                })
            }
            
        case .Update:
            if let indexPath = indexPath {
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                    
                    if let c = cell as? ThumbnailCollectionViewCell,
                        let displayable = fetchedResultsController.objectAtIndexPath(indexPath) as? ThumbnailDisplayable {
                        blockOperation!.addExecutionBlock({
                            self.configureCell(c, displayable: displayable)
                        })
                    }
                }
            }
            
        case .Move:
            blockOperation!.addExecutionBlock({
                self.collectionView.deleteItemsAtIndexPaths([indexPath!])
                self.collectionView.insertItemsAtIndexPaths([newIndexPath!])
            })
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        if shouldReloadCollectionView {
            collectionView.reloadData()
        } else {
            collectionView.performBatchUpdates({
                self.blockOperation!.start()
                }, completion:nil)
        }
    }
}
