//
//  Movie.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class Movie: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass
    func runtimeToString() -> String? {
        if let runtime = runtime {
            let duration = runtime.integerValue
            let minutes = duration % 60;
            let hours = duration / 60
            return "\(hours)hr \(minutes)min"
            
        }
        
        return nil
    }
}
