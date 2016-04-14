//
//  TVShow.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class TVShow: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension TVShow : ThumbnailTableViewCellDisplayable {
    func id() -> AnyObject? {
        return tvShowID
    }
    
    func path() -> String? {
        return posterPath
    }
    
    func caption() -> String? {
        return name
    }
}