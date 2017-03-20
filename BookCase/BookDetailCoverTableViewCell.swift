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
        
        if let coverURL = book.coverURL {
            GoogleBooksAPI.shared.getBookImage(for: coverURL) { (data) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.bookThumbnail.image = UIImage(data: data)
                    }
                }
            }
        }
        
        titel.text = book.title
        subtitel.text = book.subtitle
    }

}
