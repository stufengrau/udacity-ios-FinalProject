//
//  Book.swift
//  BookCase
//
//  Created by heike on 14/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

// MARK: -
// Book Detail View and Book Overview Cell expect type "Book"
// A "Book" can be a Core Data Object or a book from the Google Books search result
// To prevent fetching the image multiple times, cache the image
protocol Book {
    var bookInformation: BookInformation { get }
    var cachedCoverImage: UIImage? { get }
    func fetchCoverImage(completion: @escaping (_ coverImage: UIImage?) -> Void)
}

// MARK: -
// To provide image caching for the Google Books API search results
class BookImageCaching: Book {
    
    // MARK: - Properties
    let bookInformation: BookInformation
    var cachedCoverImage: UIImage?
    
    // MARK: - Initializer
    init(bookInformation: BookInformation) {
        self.bookInformation = bookInformation
        self.cachedCoverImage = nil
    }
    
    // MARK: - Fetch cover image
    // Fetch the cover image via network request, if no cached Image is available
    func fetchCoverImage(completion: @escaping (_ coverImage: UIImage?) -> Void) {
        // Cached Image available
        if let coverImage = self.cachedCoverImage {
            completion(coverImage)
        } else {
            // URL available for cover Image?
            if let coverImageURL = bookInformation.coverURL {
                // Try to get the image data via network request
                GoogleBooksAPI.shared.getBookImage(for: coverImageURL, completionHandler: { (data) in
                    guard let imageData = data else {
                        completion(nil)
                        return
                    }
                    self.cachedCoverImage = UIImage(data: imageData)
                    completion(self.cachedCoverImage)
                })
            } else {
                completion(nil)
            }
        }
    }
}

// MARK: -
// To save the Google Books API search results
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
    let title: String
    let subtitle: String?
    let authors: String
    let publisher: String?
    let publishedDate: PublicationDate?
    let pages: Int?
    let language: String?
    let isbn: String?
    let googleBookURL: String?
    let coverURL: String?
    
    
    // Create Book Information from JSON Object
    static func from(json: [String:AnyObject]) -> BookInformation? {
        // Make sure, all necessary keys have a value
        guard let title = json[GoogleBooksAPI.GoogleBooksResponseKeys.Title] as? String else {
            return nil
        }
        
        let subtitle = json[GoogleBooksAPI.GoogleBooksResponseKeys.Subtitle] as? String
        let authorsArray = json[GoogleBooksAPI.GoogleBooksResponseKeys.Authors] as? [String] ?? []
        let authors = authorsArray.joined(separator: ", ")
        let publisher = json[GoogleBooksAPI.GoogleBooksResponseKeys.Publisher] as? String
        let publishedDate = PublicationDate.from(isoDate: json[GoogleBooksAPI.GoogleBooksResponseKeys.PublisedDate] as? String)
        let pages = json[GoogleBooksAPI.GoogleBooksResponseKeys.BookPages] as? Int
        let language = json[GoogleBooksAPI.GoogleBooksResponseKeys.Language] as? String
        
        // Get ISBN if available, prefer ISBN13 over ISBN10
        var isbn: String?
        if let industryId = json[GoogleBooksAPI.GoogleBooksResponseKeys.IndustryIDs] as? [[String:AnyObject]] {
            for type in industryId {
                if let industryType = type[GoogleBooksAPI.GoogleBooksResponseKeys.IndustryIDType] as? String, let identifier = type[GoogleBooksAPI.GoogleBooksResponseKeys.Identifier] as? String {
                    if industryType == GoogleBooksAPI.GoogleBooksResponseValues.ISBN13 {
                        isbn = identifier
                        break
                    }
                    if industryType == GoogleBooksAPI.GoogleBooksResponseValues.ISBN10 {
                        isbn = identifier
                    }
                }
            }
        }
        
        var googleBookURL: String? = nil
        if let bookURL = json[GoogleBooksAPI.GoogleBooksResponseKeys.PreviewURL] as? String {
            googleBookURL = rewriteLinkToHttps(url: bookURL)
        }
        
        var coverURL: String? = nil
        if let imageLinks = json[GoogleBooksAPI.GoogleBooksResponseKeys.ImageLinks] as? [String:AnyObject], let imageURL =  imageLinks[GoogleBooksAPI.GoogleBooksResponseKeys.SmallThumbnailURL] as? String {
            coverURL = rewriteLinkToHttps(url: imageURL)
        }
        
        return BookInformation(title: title, subtitle: subtitle, authors: authors, publisher: publisher, publishedDate: publishedDate, pages: pages, language: language, isbn: isbn, googleBookURL: googleBookURL, coverURL: coverURL)
        
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
        if let bookInformation = BookInformation.from(json: bookInfo) {
            listOfBooks.append(BookImageCaching(bookInformation: bookInformation))
        }
    }
    
    return listOfBooks
}


// Make sure URLs start with https
func rewriteLinkToHttps(url: String) -> String {
    return url.replacingOccurrences(of: "http://", with: "https://")
}


