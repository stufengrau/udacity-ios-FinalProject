//
//  Book.swift
//  BookCase
//
//  Created by heike on 14/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

protocol Book {
    var bookInformation: BookInformation { get }
    func fetchCoverImage(completion: @escaping (_ coverImage: UIImage?) -> Void)
}

// MARK: -
class BookImageCaching: Book {
    
    // MARK: - Properties
    let bookInformation: BookInformation
    private var coverImage: UIImage?
    
    // MARK: - Initializer
    init(bookInformation: BookInformation) {
        self.bookInformation = bookInformation
        self.coverImage = nil
    }
    
    // MARK: - Fetch cover image
    func fetchCoverImage(completion: @escaping (_ coverImage: UIImage?) -> Void) {
        if let coverImage = self.coverImage {
            completion(coverImage)
        } else {
            if let coverImageURL = bookInformation.coverURL {
                GoogleBooksAPI.shared.getBookImage(for: coverImageURL, completionHandler: { (data) in
                    guard let imageData = data else {
                        completion(nil)
                        return
                    }
                    self.coverImage = UIImage(data: imageData)
                    completion(self.coverImage)
                })
            } else {
                completion(nil)
            }
        }
    }
    
}

// MARK: -
class BookLibrary {
    
    // MARK: - Properties
    var books = [Book]()
    
    // MARK: - Singelton
    static let shared = BookLibrary()
    private init() {}
    
}

// MARK: -
// Structure for Book Information
struct BookInformation {
    
    // MARK: - Properties
    let coverURL: String?
    let title: String
    let subtitle: String?
    let authors: [String]
    let publisher: String?
    let publishedDate: PublicationDate?
    let pages: Int?
    let googleBookURL: String?
    
    // MARK: - Initializer
    init?(_ book: [String:AnyObject]) {
        
        // Make sure, all necessary keys have a value
        guard let title = book[GoogleBooksAPI.GoogleBooksResponseKeys.Title] as? String else {
            return nil
        }
        
        self.title = title
        
        // TODO: Refactor?
        if let bookURL = book[GoogleBooksAPI.GoogleBooksResponseKeys.PreviewURL] as? String {
            self.googleBookURL = rewriteLinkToHttps(url: bookURL)
        } else {
            self.googleBookURL = nil
        }
        
        // TODO: Refactor?
        if let imageLinks = book[GoogleBooksAPI.GoogleBooksResponseKeys.ImageLinks] as? [String:AnyObject], let imageURL =  imageLinks[GoogleBooksAPI.GoogleBooksResponseKeys.SmallThumbnailURL] as? String {
            self.coverURL = rewriteLinkToHttps(url: imageURL)
        } else {
            self.coverURL = nil
        }
        
        self.subtitle = book[GoogleBooksAPI.GoogleBooksResponseKeys.Subtitle] as? String
        self.publisher = book[GoogleBooksAPI.GoogleBooksResponseKeys.Publisher] as? String
        self.pages = book[GoogleBooksAPI.GoogleBooksResponseKeys.BookPages] as? Int
        
        self.publishedDate = PublicationDate(isoDate: book[GoogleBooksAPI.GoogleBooksResponseKeys.PublisedDate] as? String)
        
        self.authors = book[GoogleBooksAPI.GoogleBooksResponseKeys.Authors] as? [String] ?? []
        
    }
}

// MARK: -
// Create an array of books
func createListOfBooks(_ bookSearchResult: [[String:AnyObject]]) -> [Book] {
    
    
    var listOfBooks = [Book]()
    
    for item in bookSearchResult {
        // Is there any volume info?
        guard let bookInfo = item[GoogleBooksAPI.GoogleBooksResponseKeys.VolumeInfo] as? [String:AnyObject] else {
            return []
        }
        
        // Add the book to the list, if the book information could be created
        if let bookInformation = BookInformation(bookInfo) {
            listOfBooks.append(BookImageCaching(bookInformation: bookInformation))
        }
    }
    
    return listOfBooks
}

// Make sure URLs start with https
func rewriteLinkToHttps(url: String) -> String {
    return url.replacingOccurrences(of: "http://", with: "https://")
}


