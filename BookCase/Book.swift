//
//  Book.swift
//  BookCase
//
//  Created by heike on 14/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

// TODO: Refactor Book Protocol!
protocol Book {
    var bookInformation: BookInformation { get }
    var cachedCoverImage: UIImage? { get }
    func fetchCoverImage(completion: @escaping (_ coverImage: UIImage?) -> Void)
}

// MARK: -
class BookImageCaching: Book {
    
    // MARK: - Properties
    let bookInformation: BookInformation
    var cachedCoverImage: UIImage?
    private var completion: ((_ coverImage: UIImage?) -> Void)?

    // MARK: - Initializer
    init(bookInformation: BookInformation) {
        self.bookInformation = bookInformation
        self.cachedCoverImage = nil
    }
    
    // MARK: - Fetch cover image
    func fetchCoverImage(completion: @escaping (_ coverImage: UIImage?) -> Void) {
        if let coverImage = self.cachedCoverImage {
            completion(coverImage)
        } else {
            if let coverImageURL = bookInformation.coverURL {
                self.completion = completion
                GoogleBooksAPI.shared.getBookImage(for: coverImageURL, completionHandler: { (data) in
                    guard let imageData = data else {
                        self.completion?(nil)
                        return
                    }
                    self.cachedCoverImage = UIImage(data: imageData)
                    self.completion?(self.cachedCoverImage)
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
    let title: String
    let subtitle: String?
    let authors: [String]
    let publisher: String?
    let publishedDate: PublicationDate?
    let pages: Int?
    let googleBookURL: String?
    let coverURL: String?
    
    // Create Book Information from JSON Object
    static func from(json: [String:AnyObject]) -> BookInformation? {
        // Make sure, all necessary keys have a value
        guard let title = json[GoogleBooksAPI.GoogleBooksResponseKeys.Title] as? String else {
            return nil
        }
        
        let subtitle = json[GoogleBooksAPI.GoogleBooksResponseKeys.Subtitle] as? String
        let authors = json[GoogleBooksAPI.GoogleBooksResponseKeys.Authors] as? [String] ?? []
        let publisher = json[GoogleBooksAPI.GoogleBooksResponseKeys.Publisher] as? String
        let publishedDate = PublicationDate.from(isoDate: json[GoogleBooksAPI.GoogleBooksResponseKeys.PublisedDate] as? String)
        let pages = json[GoogleBooksAPI.GoogleBooksResponseKeys.BookPages] as? Int
        
        var googleBookURL: String? = nil
        if let bookURL = json[GoogleBooksAPI.GoogleBooksResponseKeys.PreviewURL] as? String {
            googleBookURL = rewriteLinkToHttps(url: bookURL)
        }
        
        var coverURL: String? = nil
        if let imageLinks = json[GoogleBooksAPI.GoogleBooksResponseKeys.ImageLinks] as? [String:AnyObject], let imageURL =  imageLinks[GoogleBooksAPI.GoogleBooksResponseKeys.SmallThumbnailURL] as? String {
            coverURL = rewriteLinkToHttps(url: imageURL)
        }
        
        return BookInformation(title: title, subtitle: subtitle, authors: authors, publisher: publisher, publishedDate: publishedDate, pages: pages, googleBookURL: googleBookURL, coverURL: coverURL)
        
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


