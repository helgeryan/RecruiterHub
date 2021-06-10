//
//  RecruiterHubUITests.swift
//  RecruiterHubUITests
//
//  Created by Ryan Helgeson on 6/1/21.
//

import XCTest
@testable import RecruiterHub


class RecruiterHubUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBarButtonItem() throws {
        // UI tests must launch the application that they test.
        
        let app = XCUIApplication()
        app.launch()
        app.navigationBars["Your Profile"].buttons["barButtonItem"].tap()
        let libraryTab = app.sheets["Attach Video"].scrollViews.otherElements.buttons["Library"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: libraryTab, handler: nil)
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(libraryTab.exists)
    }
    
    func testConnectionTabs() throws {

        let app = XCUIApplication()
        app.launch()
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.buttons["Following\n1"].tap()
        XCTAssertTrue(app.navigationBars.buttons["Your Profile"].exists)
        app.navigationBars["Following"].buttons["Your Profile"].tap()
        XCTAssertTrue(app.collectionViews.buttons["Following\n1"].exists)
    }
    
    func testLogoutLogin() throws {
        
        let app = XCUIApplication()
        app.launch()
        app.navigationBars["Your Profile"].buttons["Edit"].tap()
        let logoutCell = app.tables.staticTexts["Log Out"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: logoutCell, handler: nil)
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(logoutCell.exists)
        
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Log Out"]/*[[".cells.staticTexts[\"Log Out\"]",".staticTexts[\"Log Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssertTrue(app.sheets["Log Out"].scrollViews.otherElements.buttons["Log Out"].exists)
        app.sheets["Log Out"].scrollViews.otherElements.buttons["Log Out"].tap()
        let loginButton = app.buttons["Log in"]
        
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: loginButton, handler: nil)
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(loginButton.exists)
        
        app.buttons["Log in"].tap()
        let invalidLoginAlert = app.alerts["Whoops"].scrollViews.otherElements.buttons["Dismiss"]
        XCTAssertTrue(invalidLoginAlert.exists)
        invalidLoginAlert.tap()
        
        // Tap to edit the email address field. Type in a known email and password
        let emailAddressTextField = app.textFields["Email Address..."]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("blank@gmail.com")
        app.buttons["Return"].tap()
                
        let passwordTextField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordTextField.exists)
        passwordTextField.typeText("egleh141")
        
        loginButton.tap()
        
        let editButton = app.navigationBars["Your Profile"].buttons["Edit"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: editButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(editButton.exists)
                
    }
    
    func testSearch() throws {
        
        let app = XCUIApplication()
        app.launch()
        let searchTabBarItem = app.tabBars["Tab Bar"].buttons["Search"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: searchTabBarItem, handler: nil)
        
        waitForExpectations(timeout: 5, handler: nil)
        searchTabBarItem.tap()
        XCTAssertTrue(app.tables.staticTexts.count == 0)
        
        let navigationBarSearchField = app.navigationBars["RecruiterHub.SearchUserView"].searchFields["Searching for Users.. "]
            
        navigationBarSearchField.typeText("a")
        let searchCells = app.tables.staticTexts
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: searchCells, handler: nil)
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(searchCells.count != 0)
        
    }
    
    func testNotifications() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars["Tab Bar"].buttons["Notifications"].tap()
        
        let likedYourPostCellsQuery = app.tables.cells
        likedYourPostCellsQuery.children(matching: .image).element(boundBy: 0).tap()
        
        let notificationsButton = app.navigationBars["Notifications"].buttons["Notifications"]
        notificationsButton.tap()
        
        let image = likedYourPostCellsQuery.children(matching: .button).element(boundBy: 0)
        image.tap()
    }
    
    func testFeed() throws {
        
        let app = XCUIApplication()
        app.launch()
        app.tabBars["Tab Bar"].buttons["Feed"].tap()
        
        let underTheRadarStaticText = XCUIApplication().navigationBars["Under The Radar"].staticTexts["Under The Radar"]
        XCTAssertTrue(underTheRadarStaticText.exists)
    
        let tablesQuery = app.tables
        let loveButton = tablesQuery.cells.buttons["love"].firstMatch
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: loveButton, handler: nil)
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertTrue(loveButton.isHittable)
        loveButton.tap()
        
        let sendButtonsQuery = tablesQuery.cells.buttons["send"].firstMatch
        sendButtonsQuery.tap()
        
        let chatNameLabel = app.navigationBars.staticTexts.firstMatch
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: chatNameLabel, handler: nil)
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(chatNameLabel.exists)
        let underTheRaderButton = app.navigationBars.buttons["Under The Radar"]
        XCTAssertTrue(underTheRaderButton.exists)
        underTheRaderButton.tap()
        
        //        sendButtonsQuery.buttons["2 likes"].tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.buttons["3 comments"]/*[[".cells.buttons[\"3 comments\"]",".buttons[\"3 comments\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.navigationBars["Add Comment"].buttons["Under The Radar"].tap()
//        sendButtonsQuery.children(matching: .image).element.tap()
//        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).tap()
//        underTheRaderButton.tap()
//        XCUIDevice.shared.orientation = .faceUp
//        XCUIDevice.shared.orientation = .portrait
        
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
