//
//  BookSearchViewController.swift
//  BookCase
//
//  Created by heike on 15/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookSearchViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var googleBooksSearchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var searchActivityIndicatorView: UIActivityIndicatorView!
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleBooksSearchBar.delegate = self
        searchResultTableView.isHidden = true
    }
    
    // MARK: - IBActions
    @IBAction func doneSearchingTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Book Search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Dismiss keyboard
        googleBooksSearchBar.endEditing(true)
        
        searchResultTableView.isHidden = true
        searchActivityIndicatorView.startAnimating()
        
        guard let searchTerm = googleBooksSearchBar.text else {
            assertionFailure("searchTerm should not be empty")
            return
        }
        
        // Adapt search term for parametrization of the google book search url
        let concatenatedSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
        
        GoogleBooksAPI.shared.searchGoogleBooks(concatenatedSearchTerm) { (result) in
            DispatchQueue.main.async {
                self.searchActivityIndicatorView.stopAnimating()
            }
            switch result {
            case .success:
                debugPrint("Google Books Search was successful:")
                dump(BookLibrary.shared.books)
                DispatchQueue.main.async {
                    self.searchResultTableView.isHidden = false
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

// MARK: -
extension BookSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BookLibrary.shared.books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "BookOverviewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookOverviewTableViewCell
        
        cell.configureCell(book: BookLibrary.shared.books[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailView") as! BookDetailTableViewController
        detailVC.book = BookLibrary.shared.books[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}


