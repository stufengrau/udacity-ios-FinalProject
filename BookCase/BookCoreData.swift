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

public class BookCoreData: NSManagedObject, Book {
    
    // Conform to Book Protocol
    var bookInformation: BookInformation {
        return BookInformation(title: title, subtitle: subtitle, authors: authors, publisher: publisher, publishedDate: publishedDate, pages: pages, language: language, isbn: isbn, googleBookURL: googleBookURL, coverURL: coverURL)
    }
    
    var cachedCoverImage: UIImage? {
        return coverImage
    }
    
    // Generate a Publication Date
    var publishedDate: PublicationDate? {
        guard let date = publishedDateAttr, let type = publishedDateTypeAttr else {
            return nil
        }
        guard let dateType = PublicationDate.DateType(rawValue: type) else {
            return nil
        }
        return PublicationDate(date: date, dateType: dateType)
    }
    
    // Convert pages to Swift Int Type
    var pages: Int? {
        return pagesAttr > 0 ? Int(pagesAttr) : nil
    }
    
    // MARK: Convenience initializer
    convenience init(book: Book, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Book", in: context) {
            self.init(entity: ent, insertInto: context)
            
            self.title = book.bookInformation.title
            self.titleIndex = String(title.uppercased().characters.first ?? Character(""))
            self.subtitle = book.bookInformation.subtitle
            self.authors = book.bookInformation.authors
            self.publisher = book.bookInformation.publisher
            // Convert Publication Date to two Attributes in Book Entity
            if let publicationDate = book.bookInformation.publishedDate {
                self.publishedDateAttr = getDateAndTypeFrom(publicationDate: publicationDate).date
                self.publishedDateTypeAttr = getDateAndTypeFrom(publicationDate: publicationDate).type
            }
            // Convert pages from Swift Int Type to Int16 Attribute in Book Entity
            self.pagesAttr = Int16(book.bookInformation.pages ?? 0)
            self.language = book.bookInformation.language
            self.isbn = book.bookInformation.isbn
            self.googleBookURL = book.bookInformation.googleBookURL
            self.coverURL = book.bookInformation.coverURL
            self.coverImage = book.cachedCoverImage
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    // MARK: - Fetch cover image
    // Fetch the cover image via network request, if no image is already stored in Core Data
    func fetchCoverImage(completion: @escaping (_ coverImage: UIImage?) -> Void) {
        if let coverImage = coverImage {
            completion(coverImage)
        } else {
            if let coverImageURL = coverURL {
                GoogleBooksAPI.shared.getBookImage(for: coverImageURL, completionHandler: { (data) in
                    guard let imageData = data else {
                        completion(nil)
                        return
                    }
                    DispatchQueue.main.async {
                        self.coverImage = UIImage(data: imageData)
                        try? self.managedObjectContext?.save()
                    }
                    completion(self.coverImage)
                })
            } else {
                completion(nil)
            }
        }
    }
}

// MARK: - Helper function to convert a publication date for Book Entity Attributes
fileprivate func getDateAndTypeFrom(publicationDate: PublicationDate) -> (date: Date, type: String) {
    return (publicationDate.date, publicationDate.dateType.rawValue)
}
