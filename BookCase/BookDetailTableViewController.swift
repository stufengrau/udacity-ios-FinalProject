//
//  BookDetailTableViewController.swift
//  BookCase
//
//  Created by heike on 19/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookDetailTableViewController: UITableViewController {
    
    // MARK: - Propterites
    var book: Book!
    private let numberOfCells = 6
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Self-Sizing Table View Cells:
        // http://www.appcoda.com/self-sizing-cells/
        // https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithSelf-SizingTableViewCells.html
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 44.0;
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        // TODO: Refactor this code!
        // Configure cell based on cell index
        switch indexPath.row {
        case 0:
            let bookDetailCoverCell = tableView.dequeueReusableCell(withIdentifier: "BookDetailCoverCell", for: indexPath) as! BookDetailCoverTableViewCell
            bookDetailCoverCell.configureCell(book: book)
            cell = bookDetailCoverCell
        case 1:
            let bookDetailCell = tableView.dequeueReusableCell(withIdentifier: "BookDetailCell", for: indexPath) as! BookDetailTableViewCell
            if book.bookInformation.authors.count == 0 {
                bookDetailCell.configureCell(headline: "Author", content: nil)
            } else if book.bookInformation.authors.count == 1 {
                bookDetailCell.configureCell(headline: "Author", content: book.bookInformation.authors[0])
            } else {
                bookDetailCell.configureCell(headline: "Authors", content: book.bookInformation.authors.joined(separator: ", "))
            }
            cell = bookDetailCell
        case 2:
            let bookDetailCell = tableView.dequeueReusableCell(withIdentifier: "BookDetailCell", for: indexPath) as! BookDetailTableViewCell
            bookDetailCell.configureCell(headline: "Publisher", content: book.bookInformation.publisher)
            cell = bookDetailCell
        case 3:
            let bookDetailCell = tableView.dequeueReusableCell(withIdentifier: "BookDetailCell", for: indexPath) as! BookDetailTableViewCell
            bookDetailCell.configureCell(headline: "Pages", pages: book.bookInformation.pages)
            cell = bookDetailCell
        case 4:
            let bookDetailCell = tableView.dequeueReusableCell(withIdentifier: "BookDetailCell", for: indexPath) as! BookDetailTableViewCell
            bookDetailCell.configureCell(headline: "Publication Date", date: book.bookInformation.publishedDate)
            cell = bookDetailCell
        default:
            let bookDetailPreviewCell = tableView.dequeueReusableCell(withIdentifier: "BookDetailPreviewCell", for: indexPath) as! BookDetailPreviewTableViewCell
            bookDetailPreviewCell.configureCell(googlePreviewURL: book.bookInformation.googleBookURL)
            cell = bookDetailPreviewCell
            
        }
        
        // Disable cell selection
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Self-sizing table view cell
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Disable cell selection
        return nil
    }
    
    
}
