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
    @IBOutlet weak var outerActivityIndicatorView: UIView!
    @IBOutlet weak var searchActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nothingFoundView: UIView!
    @IBOutlet weak var nothingFoundMessage: UILabel!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register Book Overview Cell
        tableView.register(UINib(nibName: "BookOverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "BookOverviewCell")
        
        // Self-Sizing Table View Cells
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 105.0;
        
        // Configure search bar
        googleBooksSearchBar.delegate = self
        googleBooksSearchBar.becomeFirstResponder()
        
        // Just show search bar and hide all other views
        searchResultTableView.isHidden = true
        outerActivityIndicatorView.isHidden = true
        nothingFoundView.isHidden = true
        
    }
    
    // MARK: - IBActions
    // Dismiss Book Search View
    @IBAction func doneSearchingTapped(_ sender: UIBarButtonItem) {
        googleBooksSearchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Book Search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        googleBooksSearchBar.resignFirstResponder()
        
        // Hide eventually visible views from earlier search
        nothingFoundView.isHidden = true
        searchResultTableView.isHidden = true
        
        // Show activity indicator while waiting for network results
        outerActivityIndicatorView.isHidden = false
        searchActivityIndicatorView.startAnimating()
        
        guard let searchTerm = googleBooksSearchBar.text else {
            fatalError("searchTerm should not be empty")
        }
        
        // Adapt search term for parametrization of the google book search url
        let concatenatedSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
        
        // Ask Google Books API for search term
        GoogleBooksAPI.shared.searchGoogleBooks(concatenatedSearchTerm) { (result) in
            // Hide Activity View Indicator
            DispatchQueue.main.async {
                self.searchActivityIndicatorView.stopAnimating()
                self.outerActivityIndicatorView.isHidden = true
            }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    // Show results
                    self.searchResultTableView.isHidden = false
                    self.searchResultTableView.reloadData()
                    // After a search scroll to first row of table view
                    self.searchResultTableView.scrollToRow(at: [0,0], at: UITableViewScrollPosition.top, animated: false)
                }
            case .nothingFound:
                // Show message if nothing was found
                DispatchQueue.main.async {
                    self.nothingFoundMessage.text = "Nothing found for \n\n\"\(searchTerm)\""
                    self.nothingFoundView.isHidden = false
                }
            case .failure:
                // Show alert if a network error occured
                DispatchQueue.main.async {
                    self.showAlert(title: "Network Error", message: "Please try again later.")
                }
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
        // On cell selection open Detail View of the selected book
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "BookDetailView") as! BookDetailTableViewController
        // If we are in book search view, a book can be saved in the detail view
        detailVC.detailViewState = DetailViewState.SaveBook
        detailVC.book = BookLibrary.shared.books[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}


