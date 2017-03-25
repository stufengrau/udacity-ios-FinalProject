//
//  BookCoreData+CoreDataProperties.swift
//  BookCase
//
//  Created by heike on 25/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import Foundation
import CoreData


extension BookCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookCoreData> {
        return NSFetchRequest<BookCoreData>(entityName: "Book");
    }

    @NSManaged public var title: String
    @NSManaged public var subtitle: String?
    @NSManaged public var publisher: String?
    @NSManaged public var authors: NSObject?
    @NSManaged public var publishedDate: NSObject?
    @NSManaged public var pages: Int32
    @NSManaged public var coverURL: String?
    @NSManaged public var googleBookURL: String?
    @NSManaged public var coverImage: Data?

}
