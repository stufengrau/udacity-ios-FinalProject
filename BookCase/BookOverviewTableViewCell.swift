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
    
    // MARK: Properties
    private var fetcher: ImageFetcher? = nil
    
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Cell Configuration
    func configureCell(book: Book) {
        
        // Overwriting the fetcher effectively cancels previous still running fetch request
        fetcher = ImageFetcher(view: bookThumbnail)
        
        // Reset book Cover image
        bookThumbnail.image = nil
        
        // Fetch the cover image
        fetcher?.fetchCover(for: book)
        
        title.text = book.bookInformation.title
        publisher.text = book.bookInformation.publisher
        authors.text = book.bookInformation.authors
    }
    
}

private class ImageFetcher {
    
    private weak var view: UIImageView?
    
    func fetchCover(for book: Book) {
        book.fetchCoverImage { [weak self] (coverImage) in
            if let coverImage = coverImage {
                DispatchQueue.main.async {
                    self?.view?.image = coverImage
                }
            }
        }
    }
    
    init(view: UIImageView) {
        self.view = view
    }
    
}
