//
//  BookDetailCoverTableViewCell.swift
//  BookCase
//
//  Created by heike on 19/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookDetailCoverTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookThumbnail: UIImageView!
    @IBOutlet weak var titel: UILabel!
    @IBOutlet weak var subtitel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(book: Book) {
        
        book.fetchCoverImage { (coverImage) in
            if let coverImage = coverImage {
                DispatchQueue.main.async {
                    self.bookThumbnail.image = coverImage
                }
            }
        }
        
        titel.text = book.bookInformation.title
        subtitel.text = book.bookInformation.subtitle
    }
    
}
