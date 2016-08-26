//
//  VideoTableViewCell.swift
//  Cineko
//
//  Created by Jovit Royeca on 25/08/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData
import XCDYouTubeKit

protocol VideoTableViewCellDelegate : NSObjectProtocol {
    func playVideoFullScreen(videoPlayer: XCDYouTubeVideoPlayerViewController)
}

class VideoTableViewCell: UITableViewCell {

    // MARK: Variables
    private var _videoOID: NSManagedObjectID?
    var videoOID : NSManagedObjectID? {
        get {
            return _videoOID
        }
        set (newValue) {
            if (_videoOID != newValue) {
                _videoOID = newValue
                
                displayThumbnail()
            }
        }
        
    }
    private var videoPlayer:XCDYouTubeVideoPlayerViewController?
    var delegate:VideoTableViewCellDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    // MARK: Actions
    @IBAction func playAction(sender: UIButton) {
        if let videoPlayer = videoPlayer,
            let delegate = delegate {
            delegate.playVideoFullScreen(videoPlayer)
        }
    }
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    // MARK: Custom methods
    func displayThumbnail() {
        if let videoOID = videoOID {
            let video = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(videoOID) as! Video
            playButton.hidden = true
            self.captionLabel.text = video.name
            
            if let key = video.key {
                videoPlayer = XCDYouTubeVideoPlayerViewController(videoIdentifier: key)
                
                NSNotificationCenter.defaultCenter().removeObserver(self, name: XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification, object:nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoTableViewCell.videoPlayerViewControllerDidReceiveVideo(_:)), name: XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification, object: nil)
                
//                NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object:nil)
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoTableViewCell.moviePlayerPlaybackDidFinish(_:)), name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
            }
            
            if let _ = thumbnailImage.image {
                playButton.hidden = false
            }
        }
    }
    
    // MARK: Notification handlers
    func videoPlayerViewControllerDidReceiveVideo(notification: NSNotification) {
        if let _ = thumbnailImage.image {
            return
        }

        if let video = notification.userInfo![XCDYouTubeVideoUserInfoKey] as? XCDYouTubeVideo {
            
            var thumbnailURL:NSURL?
            if let mediumThumbnailURL = video.mediumThumbnailURL {
                thumbnailURL = mediumThumbnailURL
            } else if let smallThumbnailURL = video.smallThumbnailURL {
                thumbnailURL = smallThumbnailURL
            }
            
            let request = NSURLRequest(URL: thumbnailURL!)
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                if let data = data {
                    
                    if let image = UIImage(data: data) {
                        
                        let averageColor = image.averageColor().colorWithAlphaComponent(0.97)
                        let contrastColor = averageColor.blackOrWhiteContrastingColor()
                    
                        performUIUpdatesOnMain {
                            if let buttonImage = self.playButton.imageForState(.Normal) {
                                let tintedImage = buttonImage.imageWithRenderingMode(.AlwaysTemplate)
                                self.playButton.setImage(tintedImage, forState: .Normal)
                                self.playButton.tintColor = contrastColor
                            }
                        
                            self.thumbnailImage.contentMode = .ScaleAspectFit
                            self.thumbnailImage.image = image
                            self.playButton.hidden = false
                            self.captionLabel.textColor = contrastColor
                        }
                    }
                }
            });
            
            task.resume()
        }
    }
    
    func moviePlayerPlaybackDidFinish(notification: NSNotification) {
        
    }
}
