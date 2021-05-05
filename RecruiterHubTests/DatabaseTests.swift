//
//  DatabaseTests.swift
//  RecruiterHubTests
//
//  Created by Ryan Helgeson on 3/13/21.
//

import XCTest
@testable import RecruiterHub

class DatabaseTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_createThumbnailValid() {
        let urlString = "https://firebasestorage.googleapis.com/v0/b/recruiterhub-cb0ef.appspot.com/o/ryanhelgeson14-gmail-com%2Fvideos%2Fryanhelgeson14-gmail-com_Mar%207,%202021%20at%2011:32:18%20PM%20CST.mov?alt=media&token=c4aead01-080a-438f-a57d-f8935a874c95"
        guard let url = URL(string: urlString) else {
            return
        }
        let image = DatabaseManager.createThumbnail(url: url)
        XCTAssertNotEqual(UIImage(systemName: "person.circle")!, image)
    }
    
    func test_createThumbnailInvalid() {
        let urlString = "NotAValidURL"
        guard let url = URL(string: urlString) else {
            return
        }
        let image = DatabaseManager.createThumbnail(url: url)
        XCTAssertEqual(UIImage(systemName: "person.circle")!, image)
    }
    
    func test_findPostValid() {
        var data: [[String: Any]] = []
        for index in 0...9 {
            data.append([
                "url": "url\(index).com"
            ])
        }
        
        let indexOf7 = DatabaseManager.findPost(posts: data, url: "url7.com")
        XCTAssertEqual(7, indexOf7)
    }
    
    func test_findPostInvalid() {
        var data: [[String: Any]] = []
        for index in 0...9 {
            data.append([
                "url": "url\(index).com"
            ])
        }
        
        let badValue = DatabaseManager.findPost(posts: data, url: "urlThatDoesntExist.com")
        XCTAssertEqual(10, badValue)
    }
    
    func test_safeEmail() {
        let email = "ryanhelgeson14@gmail.com"
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        XCTAssertEqual("ryanhelgeson14-gmail-com", safeEmail)
    }
    
    func test_RHUser() {
        var user = RHUser()
        
        user.emailAddress = "ryanhelgeson14@gmail.com"
        user.firstName = "Ryan"
        user.lastName = "Helgeson"
    
        XCTAssertEqual("Ryan Helgeson", user.name)
        XCTAssertEqual("ryanhelgeson14-gmail-com", user.safeEmail)
        XCTAssertEqual("ryanhelgeson14-gmail-com_profile_picture.png", user.profilePictureFileName)
    }
    
    func test_getDataForUser() {
        let expect = expectation(description: "Data")
        
        DatabaseManager.shared.getDataForUser(user: "ryanhelgeson14-gmail-com", completion: {
            user in
            
            guard let user = user else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(6, user.heightFeet)
            XCTAssertEqual(6, user.heightInches)
            XCTAssertEqual("Ryan", user.firstName)
            XCTAssertEqual("Helgeson", user.lastName)
            XCTAssertEqual("ryanhelgeson14-gmail-com", user.safeEmail)
            XCTAssertEqual("R", user.bats)
            XCTAssertEqual("R", user.arm)
            XCTAssertEqual(2014, user.gradYear)
            XCTAssertEqual("helgeryan", user.username)
            XCTAssertEqual("Minnetonka", user.highSchool)
            XCTAssertEqual("MN", user.state)
            XCTAssertEqual(240, user.weight)
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func test_getScoutInfo() {
        let expect = expectation(description: "Data")
        
        DatabaseManager.shared.getScoutInfoForUser(user: "ryanhelgeson14-gmail-com", completion: {
            scoutInfo in
            guard let scoutInfo = scoutInfo else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(74.2, scoutInfo.changeup)
            XCTAssertEqual(87.5, scoutInfo.fastball)
            XCTAssertEqual(75, scoutInfo.curveball)
            XCTAssertEqual(0, scoutInfo.slider)
            XCTAssertEqual(7.53, scoutInfo.sixty)
            XCTAssertEqual(91.2, scoutInfo.exitVelo)
            XCTAssertEqual(80, scoutInfo.infield)
            XCTAssertEqual(0, scoutInfo.outfield)
            expect.fulfill()
        })
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func test_downloadURLValid() {
        let expect = expectation(description: "Data")
        
        guard let expectedURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/recruiterhub-cb0ef.appspot.com/o/images%2Fryanhelgeson14-gmail-com?alt=media&token=6d06f73d-364c-46b1-9e97-18b07c8f47f8") else {
            XCTAssert(false)
            return
        }
        
        let path = "images/ryanhelgeson14-gmail-com"
        StorageManager.shared.downloadURL(for: path, completion: { result in
        
            switch result {
            case .success(let resultURL):
                XCTAssertEqual(expectedURL, resultURL)
                break
            case .failure(_):
                XCTAssert(false)
                break
            }
            expect.fulfill()
        })
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func test_downloadURLInvalid() {
        let expect = expectation(description: "Data")

        let path = "images/Not_An_Image_Location_com"
        StorageManager.shared.downloadURL(for: path, completion: { result in
        
            switch result {
            case .success(_):
                XCTAssert(false)
                break
            case .failure(let error):
                guard let error = error as? StorageManager.StorageErrors else {
                    XCTAssert(false)
                    return
                }
                
                XCTAssertEqual(StorageManager.StorageErrors.failedToGetDownloadUrl, error)
                break
            }
            expect.fulfill()
        })
        waitForExpectations(timeout: 2, handler: nil)
    }

}
