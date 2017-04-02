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
    var previewURL: String?
    
    // MARK: - IBOutlets
    @IBOutlet weak var previewBookButton: UIButton!
    
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
        // Disable Preview Button if no preview URL is set
        previewBookButton.isEnabled = (book.bookInformation.googleBookURL != nil)
    }
    
    // MARK: - IBActions
    @IBAction func previewBookTapped(_ sender: UIButton) {
        // Open Google Books preview in Safari
        UIApplication.shared.open(URL(string: previewURL!)!, options: [:], completionHandler: nil)
    }
}
