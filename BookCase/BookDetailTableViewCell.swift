//
//  BookDetailTableViewCell.swift
//  BookCase
//
//  Created by heike on 19/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(headline: String, content: String?) {
        headlineLabel.text = headline
        contentLabel.text = content ?? "No Data"
    }
    
    func configureCell(headline: String, pages: Int?) {
        configureCell(headline: headline, content: pages?.description)
    }
    
    func configureCell(headline: String, date: PublicationDate?) {
        configureCell(headline: headline, content: date?.description)
    }

}
