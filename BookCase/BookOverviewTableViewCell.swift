//
//  BookOverviewTableViewCell.swift
//  BookCase
//
//  Created by heike on 16/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookOverviewTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var bookThumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var authors: UILabel!
    @IBOutlet weak var publisher: UILabel!
    
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Cell Configuration
    func configureCell(book: Book) {
        
        // Fetch the cover image
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
