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
    
    private var completion: ((_ coverImage: UIImage?) -> Void)?

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
    
    var cachedCoverImage: UIImage? {
        return self.coverImage
    }
    
    var titleIndex: String {
        return String(title.uppercased().characters.first ?? Character(""))
    }
    
    func fetchCoverImage(completion: @escaping (_ coverImage: UIImage?) -> Void) {
        if let coverImage = self.coverImage {
            completion(coverImage)
        } else {
            if let coverImageURL = self.coverURL {
                self.completion = completion
                GoogleBooksAPI.shared.getBookImage(for: coverImageURL, completionHandler: { (data) in
                    guard let imageData = data else {
                        self.completion?(nil)
                        return
                    }
                    DispatchQueue.main.async {
                        debugPrint("Cover Image fetched")
                        self.coverImage = UIImage(data: imageData)
                        try? self.managedObjectContext?.save()
                    }
                    self.completion?(self.coverImage)
                })
            } else {
                completion(nil)
            }
        }
    }
    
    
    // TODO: Finish initializer
    convenience init(book: Book, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Book", in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = book.bookInformation.title
            self.subtitle = book.bookInformation.subtitle
            self.authors = book.bookInformation.authors
            self.publisher = book.bookInformation.publisher
            if let publicationDate = book.bookInformation.publishedDate {
                self.publishedDateAttr = getDateAndTypeFrom(publicationDate: publicationDate).date
                self.publishedDateTypeAttr = getDateAndTypeFrom(publicationDate: publicationDate).type
            }
            self.pagesAttr = Int16(book.bookInformation.pages ?? 0)
            self.googleBookURL = book.bookInformation.googleBookURL
            self.coverURL = book.bookInformation.coverURL
            self.coverImage = book.cachedCoverImage
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

fileprivate func getDateAndTypeFrom(publicationDate: PublicationDate) -> (date: Date, type: String) {
    return (publicationDate.date, publicationDate.dateType.rawValue)
}
