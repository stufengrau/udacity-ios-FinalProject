//
//  BookSearchViewController.swift
//  BookCase
//
//  Created by heike on 15/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class BookSearchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchGoogleBooks(_ sender: UIButton) {
        let searchTerm = "vim"
        GoogleBooksAPI.shared.searchGoogleBooks(searchTerm) { (result) in
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

