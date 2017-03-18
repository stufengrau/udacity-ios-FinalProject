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
                dump(BookLibrary.shared.books)
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
        return BookLibrary.shared.books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "BookOverviewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookOverviewTableViewCell
        
        cell.confiureCell(book: BookLibrary.shared.books[indexPath.row])
        
        return cell
    }
    
}


