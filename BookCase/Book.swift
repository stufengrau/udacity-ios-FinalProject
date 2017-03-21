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

class BookImageCaching: Book {
    let bookInformation: BookInformation
    private var coverImage: UIImage?
    
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
    
    init(bookInformation: BookInformation) {
        self.bookInformation = bookInformation
        self.coverImage = nil
    }
}

class BookLibrary {
    
    var books = [Book]()
    
    static let shared = BookLibrary()
    private init() {}
    
}

// Structure for Book Information
struct BookInformation {
    let coverURL: String?
    let title: String
    let subtitle: String?
    let authors: [String]
    let publisher: String?
    let publishedDate: Date?
    let pages: Int?
    let googleBookURL: String?
    
    
    // initializer is failable
    init?(_ book: [String:AnyObject]) {
        
        // make sure, all necessary keys have a value
        guard let title = book[GoogleBooksAPI.GoogleBooksResponseKeys.Title] as? String else {
            return nil
        }
        
        self.title = title
        
        if let bookURL = book[GoogleBooksAPI.GoogleBooksResponseKeys.PreviewURL] as? String {
            self.googleBookURL = rewriteLinkToHttps(url: bookURL)
        } else {
           self.googleBookURL = nil
        }
        
        if let imageLinks = book[GoogleBooksAPI.GoogleBooksResponseKeys.ImageLinks] as? [String:AnyObject], let imageURL =  imageLinks[GoogleBooksAPI.GoogleBooksResponseKeys.SmallThumbnailURL] as? String {
            self.coverURL = rewriteLinkToHttps(url: imageURL)
        } else {
            self.coverURL = nil
        }
        
        self.subtitle = book[GoogleBooksAPI.GoogleBooksResponseKeys.Subtitle] as? String
        self.publisher = book[GoogleBooksAPI.GoogleBooksResponseKeys.Publisher] as? String
        self.pages = book[GoogleBooksAPI.GoogleBooksResponseKeys.BookPages] as? Int
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let isoDate = book[GoogleBooksAPI.GoogleBooksResponseKeys.PublisedDate] as? String {
            self.publishedDate = dateFormatter.date(from: isoDate)
        } else {
            self.publishedDate = nil
        }

        self.authors = book[GoogleBooksAPI.GoogleBooksResponseKeys.Authors] as? [String] ?? []

    }
}

// create an array of books
func createListOfBooks(_ bookSearchResult: [[String:AnyObject]]) -> [Book] {
    
    
    var listOfBooks = [Book]()
    
    for item in bookSearchResult {
        guard let bookInfo = item[GoogleBooksAPI.GoogleBooksResponseKeys.VolumeInfo] as? [String:AnyObject] else {
            debugPrint("No Volume Info key found")
            return []
        }
        
        if let bookInformation = BookInformation(bookInfo) {
            listOfBooks.append(BookImageCaching(bookInformation: bookInformation))
        }
    }
    
    return listOfBooks
}

func rewriteLinkToHttps(url: String) -> String {

        return url.replacingOccurrences(of: "http://", with: "https://")

}


