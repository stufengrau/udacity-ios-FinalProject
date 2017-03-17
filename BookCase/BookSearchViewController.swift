//
//  BookSearchViewController.swift
//  BookCase
//
//  Created by heike on 15/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookSearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var googleBooksSearchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        googleBooksSearchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // dismiss keyboard
        googleBooksSearchBar.endEditing(true)
        
        guard let searchTerm = googleBooksSearchBar.text else {
            assertionFailure("searchTerm should not be empty")
            return
        }
    
        let concatenatedSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
            
        GoogleBooksAPI.shared.searchGoogleBooks(concatenatedSearchTerm) { (result) in
            switch result {
            case .success:
                debugPrint("Google Books Search was successful:")
                dump(Book.shared.bookData)
                DispatchQueue.main.async {
                    self.searchResultTableView.reloadData()
                }
            case .nothingFound:
                debugPrint("Nothing found for: \(searchTerm)")
            case .failure:
                debugPrint("Network failure. Please try again later.")
            }
        }
        
    }

}

extension BookSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Book.shared.bookData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BookOverviewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookOverviewTableViewCell
        
        if let coverURL = Book.shared.bookData[indexPath.row].coverURL {
            GoogleBooksAPI.shared.getBookImage(for: coverURL) { (data) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.bookThumbnail.image = UIImage(data: data)
                    }
                }
            }
        }

        cell.title.text = Book.shared.bookData[indexPath.row].title
        cell.publisher.text = Book.shared.bookData[indexPath.row].publisher
        cell.authors.text = Book.shared.bookData[indexPath.row].authors.joined(separator: ", ")
        
        return cell
    }
    
}


