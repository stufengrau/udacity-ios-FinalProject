//
//  ShareMessageGenerator.swift
//  BookCase
//
//  Created by heike on 02.04.17.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import Foundation

struct ShareMessageGenerator {
    
    // MARK: Properties
    let book: Book
    
    enum Message {
        case Info(String)
        case Error(String, String)
    }
    
    var shareMessage: Message {
        guard let shareURL = book.bookInformation.googleBookURL else {
            return .Error("Missing Preview URL", "Sorry, there is no URL available to share for this book.")
        }
        return .Info("Book Recommendation: \n \n\(book.bookInformation.title) \n\n\(shareURL)")
    }
    
}
