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
public class BookCoreData: NSManagedObject, Book {
    
    var bookInformation: BookInformation {
        return BookInformation(title: title, subtitle: subtitle, authors: authors, publisher: publisher, publishedDate: publishedDate, pages: pages, googleBookURL: googleBookURL, coverURL: coverURL)
    }
    
    var publishedDate: PublicationDate? {
        guard let date = publishedDateAttr, let type = publishedDateTypeAttr else {
            return nil
        }
        guard let dateType = PublicationDate.DateType(rawValue: type) else {
            return nil
        }
        return PublicationDate(date: date, dateType: dateType)
    }
    
    var pages: Int? {
        return pagesAttr > 0 ? Int(pagesAttr) : nil
    }
    
    func fetchCoverImage(completion: @escaping (_ coverImage: UIImage?) -> Void) {
        completion(coverImage)
        fetchCoverImage(completion: { (coverImage) in
            self.coverImage = coverImage
        })
    }

    
    // TODO: Finish initializer
    convenience init(bookInformation: BookInformation, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Book", in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = bookInformation.title
            self.subtitle = bookInformation.subtitle
            self.authors = bookInformation.authors
            self.publisher = bookInformation.publisher
            if let publicationDate = bookInformation.publishedDate {
                self.publishedDateAttr = getDateAndTypeFrom(publicationDate: publicationDate).date
                self.publishedDateTypeAttr = getDateAndTypeFrom(publicationDate: publicationDate).type
            }
            self.pagesAttr = Int16(bookInformation.pages ?? 0)
            self.googleBookURL = bookInformation.googleBookURL
            self.coverURL = bookInformation.coverURL
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

fileprivate func getDateAndTypeFrom(publicationDate: PublicationDate) -> (date: Date, type: String) {
    return (publicationDate.date, publicationDate.dateType.rawValue)
}
