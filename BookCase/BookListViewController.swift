//
//  BookListViewController.swift
//  BookCase
//
//  Created by heike on 22/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "BookOverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "BookOverviewCell")
        
        // Self-Sizing Table View Cells
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 105.0;
        
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

// MARK: -
extension BookListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "BookOverviewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookOverviewTableViewCell
        
        cell.configureCell(book: BookImageCaching(bookInformation: BookInformation(["title" : "Test" as AnyObject])!))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailView") as! BookDetailTableViewController
        detailVC.detailViewState = DetailViewState.Share
        detailVC.book = BookImageCaching(bookInformation: BookInformation(["title" : "Test" as AnyObject])!)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
