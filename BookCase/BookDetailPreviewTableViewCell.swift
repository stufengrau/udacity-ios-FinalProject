//
//  BookDetailPreviewTableViewCell.swift
//  BookCase
//
//  Created by heike on 20/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookDetailPreviewTableViewCell: UITableViewCell {
    
    // MARK: Properties
    private var previewURLString: String?
    
    // MARK: - IBOutlets
    @IBOutlet weak var previewBookButton: UIButton!
    
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Cell Configuration
    func configureCell(book: Book) {
        // Disable Preview Button if no preview URL is set
        previewURLString = book.bookInformation.googleBookURL
        previewBookButton.isEnabled = (previewURLString != nil)
    }
    
    // MARK: - IBActions
    @IBAction func previewBookTapped(_ sender: UIButton) {
        guard let previewURLString = previewURLString, let previewURL = URL(string:previewURLString) else {
            return
        }
        // Open Google Books preview in Safari
        UIApplication.shared.open(previewURL, options: [:], completionHandler: nil)
    }
}
