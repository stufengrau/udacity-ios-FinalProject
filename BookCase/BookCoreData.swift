//
//  BookCoreData+CoreDataClass.swift
//  BookCase
//
//  Created by heike on 25/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// TODO: Conform to Book Protocol
public class BookCoreData: NSManagedObject {
    
    // TODO: Finish initializer
    convenience init(book: Book, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Book", in: context) {
            self.init(entity: ent, insertInto: context)
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
