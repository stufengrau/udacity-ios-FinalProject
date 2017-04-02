//
//  BookDetailTableViewCell.swift
//  BookCase
//
//  Created by heike on 19/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookDetailTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    // MARK: - Properties
    // Enum for better readability
    private enum CellContent: Int {
        case Author = 1
        case Publisher = 2
        case PublishedDate = 3
        case Language = 4
        case Pages = 5
        case ISBN = 6
    }
    
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Cell configuration
    func configureCell(book: Book, index: Int) {
        
        guard let cellContent = CellContent(rawValue: index) else {
            assertionFailure("Not all detail view cells are configured correctly")
            return
        }
        
        switch cellContent {
        case .Author:
            let authors = book.bookInformation.authors
            let headline = "Author".appending(authors.contains(", ") ? "s" : "")
            let content = authors.isEmpty ? nil : authors
            configureCell(headline: headline, content: content)
        case .Publisher:
            configureCell(headline: "Publisher", content: book.bookInformation.publisher)
        case .PublishedDate:
            configureCell(headline: "Publication Date", date: book.bookInformation.publishedDate)
        case .Language:
            if let language = book.bookInformation.language {
                configureCell(headline: "Language", content: Locale.current.localizedString(forIdentifier: language))
            } else {
                configureCell(headline: "Language", content: nil)
            }
        case .Pages:
            configureCell(headline: "Pages", pages: book.bookInformation.pages)
        case .ISBN:
            configureCell(headline: "ISBN", content: book.bookInformation.isbn)
        }
        
    }
    
    private func configureCell(headline: String, content: String?) {
        headlineLabel.text = headline
        contentLabel.text = content ?? "No data available"
    }
    
    private func configureCell(headline: String, pages: Int?) {
        configureCell(headline: headline, content: pages?.description)
    }
    
    private func configureCell(headline: String, date: PublicationDate?) {
        configureCell(headline: headline, content: date?.description)
    }
    
}
