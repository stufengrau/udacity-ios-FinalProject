//
//  BookDetailPreviewTableViewCell.swift
//  BookCase
//
//  Created by heike on 20/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookDetailPreviewTableViewCell: UITableViewCell {

    var previewURL: String?
    
    @IBOutlet weak var previewBookButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(googlePreviewURL: String?) {
        previewURL = googlePreviewURL
        if (googlePreviewURL != nil) {
            previewBookButton.isEnabled = true
        } else {
            previewBookButton.isEnabled = false
        }
    }

    @IBAction func previewBookTapped(_ sender: UIButton) {
        // open Google Books preview in Safari
        UIApplication.shared.open(URL(string: previewURL!)!, options: [:], completionHandler: nil)
    }
}
