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
    

    // Not really an UI Test ...
    // just an unedited recording (automatically generated code) of a quick App Demo
    func testAppDemo() {
        
        let app = XCUIApplication()
        
        // Activate View to add a book
        app.navigationBars["My Book List"].buttons["Add"].tap()
        
        // Search for books with search string "vim"
        app.searchFields["Search for title, author, ISBN, etc."].typeText("vim\r")
        
        // Add some books
        let tablesQuery = app.tables
        let viAndVimEditorsPocketReferenceStaticText = tablesQuery.staticTexts["vi and Vim Editors Pocket Reference"]
        viAndVimEditorsPocketReferenceStaticText.tap()
        let bookcaseBookdetailtableviewNavigationBar = app.navigationBars["Bookcase.BookDetailTableView"]
        let saveButton = bookcaseBookdetailtableviewNavigationBar.buttons["Save"]
        saveButton.tap()
        tablesQuery.staticTexts["Mark McDonnell"].tap()
        saveButton.tap()
        let tablesQuery2 = app.tables
        tablesQuery2.cells.containing(.staticText, identifier:"vi und Vim kurz & gut").staticTexts["O'Reilly Germany"].tap()
        saveButton.tap()
        app.navigationBars["Book Online Search"].buttons["Done"].tap()
        
        
        // Sort by Author / Title
        app.buttons["Author"].tap()
        app.buttons["Titel"].tap()
        
        // Show Book Detail View and Activity View to share a book
        tablesQuery.staticTexts["\"O'Reilly Media, Inc.\""].tap()
        bookcaseBookdetailtableviewNavigationBar.buttons["Share"].tap()
        app.buttons["Cancel"].tap()
        bookcaseBookdetailtableviewNavigationBar.buttons["My Book List"].tap()
        
        // Search in Book List
        app.tables.containing(.other, identifier:"P").element.swipeDown()
        let searchField = tablesQuery2.children(matching: .searchField).element
        searchField.tap()
        searchField.typeText("reilly")
        tablesQuery2.buttons["Cancel"].tap()
        
        // Delete added books
        tablesQuery2.cells.containing(.staticText, identifier:"vi and Vim Editors Pocket Reference").staticTexts["Arnold Robbins"].swipeLeft()
        let deleteButton = tablesQuery.buttons["Delete"]
        deleteButton.tap()
        tablesQuery2.cells.containing(.staticText, identifier:"vi und Vim kurz & gut").staticTexts["Arnold Robbins"].swipeLeft()
        deleteButton.tap()
        let tablesQuery3 = XCUIApplication().tables
        tablesQuery3.staticTexts["Mark McDonnell"].swipeLeft()
        tablesQuery3.buttons["Delete"].tap()
        
    }
    
}
