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
        
        book.fetchCoverImage { (coverImage) in
            if let coverImage = coverImage {
                DispatchQueue.main.async {
                    self.bookThumbnail.image = coverImage
                }
            }
        }
        
        title.text = book.bookInformation.title
        publisher.text = book.bookInformation.publisher
        authors.text = book.bookInformation.authors.joined(separator: ", ")
    }

}
