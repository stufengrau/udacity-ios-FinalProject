//
//  BookCoreData+CoreDataProperties.swift
//  BookCase
//
//  Created by heike on 25/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import Foundation
import CoreData
import UIKit


extension BookCoreData {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookCoreData> {
        return NSFetchRequest<BookCoreData>(entityName: "Book");
    }
    
    /* titleIndex was at first a computed property
     but this had various negative side effects like following error:
     CoreData: error: (NSFetchedResultsController) The fetched object at index x has an out of order section name 'X.
     Objects must be sorted by section name'
     http://stackoverflow.com/questions/12150101/core-data-the-fetched-object-at-index-x-has-an-out-of-order-section-name-xxxxx
     Since it was a computed property the sort descriptor couldn't be set to titleIndex and was instead set to title
     Just the key selector in the FetchedResultsController was set to titleIndex
     -> titleIndex is now a managed attribute
     */
    
    @NSManaged public var title: String
    @NSManaged public var titleIndex: String
    @NSManaged public var subtitle: String?
    @NSManaged public var authors: String
    @NSManaged public var publisher: String?
    @NSManaged public var publishedDateAttr: Date?
    @NSManaged public var publishedDateTypeAttr: String?
    @NSManaged public var pagesAttr: Int16
    @NSManaged public var googleBookURL: String?
    @NSManaged public var language: String?
    @NSManaged public var isbn: String?
    @NSManaged public var coverURL: String?
    @NSManaged public var coverImage: UIImage?
    
}
