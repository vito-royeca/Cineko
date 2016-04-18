//
//  Network.swift
//  Cineko
//
//  Created by Jovit Royeca on 07/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData

class Network: NSManagedObject {

    struct Keys {
        static let NetworkID = "id"
        static let Name = "name"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Network", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        networkID = dictionary[Keys.NetworkID] as? NSNumber
        name = dictionary[Keys.Name] as? String
    }

}
