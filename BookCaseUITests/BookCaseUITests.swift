//
//  BookCaseUITests.swift
//  BookCaseUITests
//
//  Created by heike on 20/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import XCTest

class BookCaseUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShowBookDetailAfterSearch() {
        // For developing process of the Book Detail View use this test to display the Book Detail View
        // after a search, so you don't have to manually search and navigate to this view.
        
        let app = XCUIApplication()
        let searchForBook = app.searchFields["Search for title, author, ISBN, etc."]
        searchForBook.tap()
        searchForBook.typeText("Vim")
        app.buttons["Search"].tap()

        let cellQuery = app.tables.cells.element(boundBy: 6)
        cellQuery.tap()
        
        
    }
    
}
