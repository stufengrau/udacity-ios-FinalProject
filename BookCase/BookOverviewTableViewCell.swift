//
//  BookOverviewTableViewCell.swift
//  BookCase
//
//  Created by heike on 16/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookOverviewTableViewCell: UITableViewCell {

    @IBOutlet weak var bookThumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var authors: UILabel!
    @IBOutlet weak var publisher: UILabel!
    
    func confiureCell(book: Book) {
        
        if let coverURL = book.coverURL {
            GoogleBooksAPI.shared.getBookImage(for: coverURL) { (data) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.bookThumbnail.image = UIImage(data: data)
                    }
                }
            }
        }
        
        title.text = book.title
        publisher.text = book.publisher
        authors.text = book.authors.joined(separator: ", ")
    }

}
