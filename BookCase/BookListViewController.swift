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
    @IBOutlet weak var selectedBookSorting: UISegmentedControl!
    @IBOutlet weak var emptyBookListView: UIView!
    
    // MARK: - Properties
    fileprivate var searchBar: UISearchBar!
    
    private let selectedBookSortingKey = "Sort by"
    
    private let sortByTitleIndex = NSSortDescriptor(key: "titleIndex", ascending: true)
    private let sortByAuthor = NSSortDescriptor(key: "authors", ascending: true)
    private let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
    
    fileprivate var stack: CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    fileprivate var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, execute the search and reload the data
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
    fileprivate var bookSortMode: Int! {
        didSet {
            switch bookSortMode {
            case 0:
                fetchRequest.sortDescriptors = [sortByTitleIndex, sortByTitle]
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: #keyPath(BookCoreData.titleIndex), cacheName: nil)
            case 1:
                fetchRequest.sortDescriptors = [sortByAuthor, sortByTitle]
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: #keyPath(BookCoreData.authors), cacheName: nil)
            default:
                assertionFailure("All segmented control indicies must be implemented.")
            }
        }
    }
    
    fileprivate var inSearchMode: Bool = false {
        didSet {
            selectedBookSorting.isEnabled = !inSearchMode
            if inSearchMode {
                fetchRequest.sortDescriptors = [sortByTitle]
            } else {
                fetchRequest.predicate = nil
            }
        }
        
    }
    
    fileprivate var bookListIsEmpty: Bool! {
        didSet {
            if bookListIsEmpty {
                UIView.animate(withDuration: 0.5, animations: {
                    self.tableView.alpha = 0
                    self.selectedBookSorting.alpha = 0
                    self.emptyBookListView.alpha = 1
                })
            } else {
                tableView.alpha = 1
                selectedBookSorting.alpha = 1
                emptyBookListView.alpha = 0
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
        
        fetchRequest.fetchBatchSize = 20
        
        // Sort books by saved segmented control state
        selectedBookSorting.selectedSegmentIndex = UserDefaults.standard.integer(forKey: selectedBookSortingKey)
        bookSortMode = selectedBookSorting.selectedSegmentIndex

        configureSearchBar()
        configureTableView()
        setupIntialView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: index, animated: true)
        }
    }
    
    // MARK: - IBActions
    @IBAction func sortBooksBy(_ sender: UISegmentedControl) {
        if sender == selectedBookSorting {
            UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: selectedBookSortingKey)
            bookSortMode = sender.selectedSegmentIndex
        }
    }
    
    // MARK: - Helper functions
    private func executeSearch() {
        if let fc = fetchedResultsController {
            try? fc.performFetch()
        }
    }
    
    private func configureSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.barTintColor = UIColor.BookCaseColors.darkBlue
    }
    
    private func configureTableView() {
        // Register Book Overview Cell
        tableView.register(UINib(nibName: "BookOverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "BookOverviewCell")
        
        // Self-Sizing Table View Cells
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 105.0;
        
        // Table Header View contains Search Bar and hides it by default
        tableView.tableHeaderView = searchBar
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: false)
    }
    
    private func setupIntialView() {
        
        emptyBookListView.backgroundColor = UIColor.white
        
        if !(tableView.visibleCells.count > 0) {
            tableView.alpha = 0
            selectedBookSorting.alpha = 0
            emptyBookListView.alpha = 1
        } else {
            emptyBookListView.alpha = 0
        }
    }
    
}

// MARK: - Extensions
extension BookListViewController: UISearchBarDelegate {
    
    // MARK: UISearchBar Delegate
    
    /*  First I tried to filter the objects returned by the fetchedResultsController:
     
     filteredBooks = fetchedResultsController?.fetchedObjects as? [Book]
     
     if searchText == "" {
     filteredBooks = fetchedResultsController?.fetchedObjects as? [Book]
     } else {
     filteredBooks = fetchedResultsController?.fetchedObjects?.filter() {
     return searchPredicate!.evaluate(with: $0)
     } as! [Book]?
     }
     tableView.reloadData()
     
     The filtered objects were saved in an Array "filteredBooks"
     TableView functions used the "filteredBooks" Array while in search mode
     This worked fine, except for Insertions and Deletions of Objects in CoreData
     
     The following solutions works fine but I believe performance wise this is not
     the best way to go for larger datasets. Have to read more about profiling and
     Core Data in general to find a better implementation.
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        inSearchMode = true
        
        let searchPredicate = NSPredicate(format: "(title contains[c] $text) OR (authors contains[c] $text) OR (publisher contains[c] $text) OR (isbn contains[c] $text)").withSubstitutionVariables(["text" : searchText])
        
        if searchText.isEmpty {
            fetchRequest.predicate = nil
        } else {
            fetchRequest.predicate = searchPredicate
        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.text = nil
        
        inSearchMode = false
        bookSortMode = selectedBookSorting.selectedSegmentIndex
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: true)
        searchBar.setShowsCancelButton(false, animated: false)
        
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
        guard !inSearchMode else { return 1 }
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !inSearchMode else { return nil }
        guard let sectionInfo = fetchedResultsController?.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.name.isEmpty ? "Unknown" : sectionInfo.name
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.BookCaseColors.lightBlue
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "BookOverviewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookOverviewTableViewCell
        
        cell.configureCell(book: fetchedResultsController?.object(at: indexPath) as! Book)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailView") as! BookDetailTableViewController
        detailVC.detailViewState = DetailViewState.ShareBook
        detailVC.book = fetchedResultsController?.object(at: indexPath) as! Book
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
            assertionFailure("The NSFetchedResultsChangeType \(type) for a section info is not covered")
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
        default:
            assertionFailure("The NSFetchedResultsChangeType \(type) for an object is not covered")
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        bookListIsEmpty = !(tableView.visibleCells.count > 0) && !inSearchMode
    }
    
}
