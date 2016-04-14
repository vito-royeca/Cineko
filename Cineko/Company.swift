//
//  ProductionCompany.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class Company: NSManagedObject {

    struct Keys {
        static let CompanyDescription  = "description"
        static let Headquarters = "headquarters"
        static let Homepage = "homepage"
        static let CompanyID = "id"
        static let LogoPath = "logo_path"
        static let Name = "name"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Company", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        companyDescription = dictionary[Keys.CompanyDescription] as? String
        headquarters = dictionary[Keys.Headquarters] as? String
        homepage = dictionary[Keys.Homepage] as? String
        companyID = dictionary[Keys.CompanyID] as? NSNumber
        logoPath = dictionary[Keys.LogoPath] as? String
        name = dictionary[Keys.Name] as? String
    }

}
