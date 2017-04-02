//
//  BookListViewController.swift
//  BookCase
//
//  Created by heike on 22/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit
import CoreData

class BookListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var booksSortedBy: UISegmentedControl!
    @IBOutlet weak var emptyBookListHint: UILabel!
    
    // MARK: - Properties
    fileprivate var stack: CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    private var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and reload the data
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
    private let sortByKey = "Sort by"
    
    private var searchBar: UISearchBar!
    fileprivate var notSearching = true
    fileprivate var filteredBooks: [Book]? = nil
    
    fileprivate var bookListIsEmpty: Bool! {
        didSet {
            if bookListIsEmpty {
                UIView.animate(withDuration: 0.5, animations: {
                    self.tableView.alpha = 0
                    self.booksSortedBy.alpha = 0
                    self.emptyBookListHint.alpha = 1
                })
            } else {
                tableView.alpha = 1
                booksSortedBy.alpha = 1
                emptyBookListHint.alpha = 0
            }
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if Google Books API Key is set
        if GoogleBooksAPI.GoogleBooksAPIKey.APIKey == "" {
            showAlert(title: "API Key missing", message: "Please provide a Goolge Books API Key in the GoogleBooksAPIKey.swift file.")
        }
        
        // Register Book Overview Cell
        tableView.register(UINib(nibName: "BookOverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "BookOverviewCell")
        
        // Self-Sizing Table View Cells
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 105.0;
        
        // Sort results by saved segmented control state
        booksSortedBy.selectedSegmentIndex = UserDefaults.standard.integer(forKey: sortByKey)
        sortFetchedResultsBy(selectedSegmentIndex: booksSortedBy.selectedSegmentIndex)
        
        // Configure Search Bar
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: false)
        
        if !(tableView.visibleCells.count > 0) {
            tableView.alpha = 0
            booksSortedBy.alpha = 0
            emptyBookListHint.alpha = 1
        }
    }
    
    // MARK: - IBActions
    @IBAction func sortBooksBy(_ sender: UISegmentedControl) {
        sortFetchedResultsBy(selectedSegmentIndex: booksSortedBy.selectedSegmentIndex)
    }
    
    // MARK: - Helper functions
    private func executeSearch() {
        if let fc = fetchedResultsController {
            try? fc.performFetch()
        }
    }
    
    // TODO: Refactor ...
    fileprivate func sortFetchedResultsBy(selectedSegmentIndex: Int) {
        // Save segmented control state in UserDefaults
        UserDefaults.standard.set(selectedSegmentIndex, forKey: sortByKey)
        switch selectedSegmentIndex {
        // Sort by titel
        case 0:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: #keyPath(BookCoreData.titleIndex), cacheName: nil)
        // Sort by author
        case 1:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "authors", ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: #keyPath(BookCoreData.authors), cacheName: nil)
        default:
            assertionFailure("All segmented control indicies must be implemented.")
        }
    }
    

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - Extensions
extension BookListViewController: UISearchBarDelegate {
    // MARK: UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        notSearching = false
        
        let searchPredicate = NSPredicate(format: "(title contains[c] $text) OR (authors contains[c] $text) OR (publisher contains[c] $text) OR (isbn contains[c] $text)").withSubstitutionVariables(["text" : searchText])
        
        if searchText == "" {
            filteredBooks = fetchedResultsController?.fetchedObjects as? [Book]
        } else {
            filteredBooks = fetchedResultsController?.fetchedObjects?.filter() {
                return searchPredicate.evaluate(with: $0)
                } as! [Book]?
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        notSearching = true
        
        searchBar.resignFirstResponder()
        searchBar.text = nil
        
        sortFetchedResultsBy(selectedSegmentIndex: booksSortedBy.selectedSegmentIndex)
        tableView.reloadData()
        
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: true)
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension BookListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        guard notSearching else { return 1 }
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard notSearching else { return filteredBooks?.count ?? 0 }
        guard let sectionInfo = fetchedResultsController?.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard notSearching else { return nil }
        guard let sectionInfo = fetchedResultsController?.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.name.isEmpty ? "Unknown" : sectionInfo.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "BookOverviewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookOverviewTableViewCell
        
        if notSearching {
            cell.configureCell(book: fetchedResultsController?.object(at: indexPath) as! Book)
        } else {
            cell.configureCell(book: filteredBooks![indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailView") as! BookDetailTableViewController
        detailVC.detailViewState = DetailViewState.ShareBook
        if notSearching {
            detailVC.book = fetchedResultsController?.object(at: indexPath) as! Book
        } else {
            detailVC.book = filteredBooks![indexPath.row]
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stack.context.delete(fetchedResultsController?.object(at: indexPath) as! NSManagedObject)
            stack.save()
        }
    }
    
    
}

extension BookListViewController: NSFetchedResultsControllerDelegate {
    // MARK: Fetched Results Controller Delegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            tableView.insertSections(set, with: .fade)
        case .delete:
            tableView.deleteSections(set, with: .fade)
        default:
            // irrelevant in our case
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            assertionFailure("move")
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        bookListIsEmpty = !(tableView.visibleCells.count > 0)
    }
    
}
