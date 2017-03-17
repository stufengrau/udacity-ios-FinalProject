//
//  Book.swift
//  BookCase
//
//  Created by heike on 14/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import Foundation

class Book {
    
    var bookData = [BookData]()
    
    static let shared = Book()
    private init() {}
    
}

// Structure for Book Data
struct BookData {
    let coverURL: String?
    let title: String
    let subtitle: String?
    let authors: [String]
    let publisher: String?
    let publishedDate: Date?
    let pages: Int?
    let googleBookURL: String?
    
    
    // initializer is failable
    init?(_ bookInformation: [String:AnyObject]) {
        
        // make sure, all necessary keys have a value
        guard let title = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.Title] as? String else {
            return nil
        }
        
        self.title = title
        self.googleBookURL = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.PreviewURL] as? String
        self.subtitle = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.Subtitel] as? String
        self.coverURL = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.SmallThumbnailURL] as? String
        self.publisher = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.Publisher] as? String
        self.pages = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.BookPages] as? Int
        self.publishedDate = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.PublisedDate] as? Date
        self.authors = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.Authors] as? [String] ?? []

    }
}

// create an array of books
func createListOfBooks(_ bookSearchResult: [[String:AnyObject]]) -> [BookData] {
    
    
    var result = [BookData]()
    
    for item in bookSearchResult {
        guard let bookInfo = item[GoogleBooksAPI.GoogleBooksResponseKeys.VolumeInfo] as? [String:AnyObject] else {
            debugPrint("No Volume Info key found")
            return []
        }
        
        if let bookData = BookData(bookInfo) {
            result.append(bookData)
        }
    }
    
    return result
    
}

func rewriteLinkToHttps(url: String) -> String {

        return url.replacingOccurrences(of: "http://", with: "https://")

}


