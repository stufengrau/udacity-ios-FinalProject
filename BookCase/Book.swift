//
//  Book.swift
//  BookCase
//
//  Created by heike on 14/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import Foundation

class BookLibrary {
    
    var books = [Book]()
    
    static let shared = BookLibrary()
    private init() {}
    
}

// Structure for Book Data
struct Book {
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
        
        if let bookURL = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.PreviewURL] as? String {
            self.googleBookURL = rewriteLinkToHttps(url: bookURL)
        } else {
           self.googleBookURL = nil
        }
        
        if let imageLinks = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.ImageLinks] as? [String:AnyObject], let imageURL =  imageLinks[GoogleBooksAPI.GoogleBooksResponseKeys.SmallThumbnailURL] as? String {
            self.coverURL = rewriteLinkToHttps(url: imageURL)
        } else {
            self.coverURL = nil
        }
        
        self.subtitle = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.Subtitle] as? String
        self.publisher = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.Publisher] as? String
        self.pages = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.BookPages] as? Int
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let isoDate = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.PublisedDate] as? String {
            self.publishedDate = dateFormatter.date(from: isoDate)
        } else {
            self.publishedDate = nil
        }

        self.authors = bookInformation[GoogleBooksAPI.GoogleBooksResponseKeys.Authors] as? [String] ?? []

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
        
        if let book = Book(bookInfo) {
            listOfBooks.append(book)
        }
    }
    
    return listOfBooks
}

func rewriteLinkToHttps(url: String) -> String {

        return url.replacingOccurrences(of: "http://", with: "https://")

}


