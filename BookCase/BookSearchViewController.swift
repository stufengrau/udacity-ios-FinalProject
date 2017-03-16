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
            case .nothingFound:
                debugPrint("Nothing found for: \(searchTerm)")
            case .failure:
                debugPrint("Network failure. Please try again later.")
            }
        }
        
    }

}


