//
//  MovieVideo+CoreDataProperties.swift
//  Cineko
//
//  Created by Jovit Royeca on 25/08/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MovieVideo {

    @NSManaged var videoID: String?
    @NSManaged var iso6391: String?
    @NSManaged var key: String?
    @NSManaged var name: String?
    @NSManaged var site: String?
    @NSManaged var size: NSNumber?
    @NSManaged var videoType: String?
    @NSManaged var movie: Movie?
    @NSManaged var tvShow: TVShow?
    
}
