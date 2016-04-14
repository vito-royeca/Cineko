//
//  Person.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class Person: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension Person : ThumbnailTableViewCellDisplayable {
    func id() -> AnyObject? {
        return personID
    }
    
    func path() -> String? {
        return profilePath
    }
    
    func caption() -> String? {
        return name
    }
}