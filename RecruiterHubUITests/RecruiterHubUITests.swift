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

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        let button = app.buttons["barButtonItem"]
        button.tap()
    
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testStoryboard() throws {

        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.buttons["Following\n1"].tap()
        XCTAssertTrue(app.navigationBars.buttons["Your Profile"].exists)
        app.navigationBars["Following"].buttons["Your Profile"].tap()
        XCTAssertTrue(app.collectionViews.buttons["Following\n1"].exists)
    }
    
    func testLogout() throws {
        
        let app = XCUIApplication()
        app.launch()
//        app.buttons["Edit"].tap()
//        let label = app.staticTexts.element(matching: .any, identifier: "Edit Profile").label
//        XCTAssertEqual(label, "Edit Profile")
//        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Log Out"]/*[[".cells.staticTexts[\"Log Out\"]",".staticTexts[\"Log Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.sheets["Log Out"].scrollViews.otherElements.buttons["Log Out"].tap()
//
//
        while !(app.textFields["Email Address..."].exists) {
            
        }
        
        let emailAddressTextField = app.textFields["Email Address..."]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("rick@gmail.com")
//        let passwordTextField = app.textFields["Password..."]
//        passwordTextField.tap()
//        passwordTextField.typeText("egleh141")
//        app.buttons["Log in"].tap()
//        XCTAssert(app.buttons["Edit"].exists)
        //        let app = XCUIApplication()
//        app.launch()
//        print(app.debugDescription)
//        let buttons = app.buttons["Edit"]
//        buttons.tap()
//        let label = app.staticTexts.element(matching: .any, identifier: "Edit Profile").label
//        XCTAssertEqual(label, "Edit Profile")
//        app.staticTexts.element(matching: .any, identifier: "Edit Profile").tap()
//        app.terminate()
    }
    

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
