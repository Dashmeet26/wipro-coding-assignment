//
//  CodingAssignmentTests.swift
//  CodingAssignmentTests
//
//  Created by FT User on 14/10/20.
//  Copyright © 2020 FT User. All rights reserved.
//

import XCTest
@testable import CodingAssignment

class HomeViewControllerTests: XCTestCase {
    
    var viewControllerUnderTest = HomeViewController()
    let tableView = UITableView()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 44

        for number in 0..<20 {
            let data = DescriptionData.init(title: "\(number)", description: "\(number)", imageHref: "\(number)")
            viewControllerUnderTest.tableData.append(data)
        }
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //Mark :- test case to test whether viewcontroller has a tableview created via code
    func testHasATableView() {
        XCTAssertNotNil(viewControllerUnderTest.tableView)
    }
    
    //Mark :- test case to test whether viewcontroller conforms to tableView delegate
    func testTableViewConfromsToTableViewDelegateProtocol() {
        XCTAssertTrue(viewControllerUnderTest.conforms(to: UITableViewDelegate.self))
    }
    
    //Mark :- test case to test whether viewcontroller conforms to tableView datasource
    func testTableViewConformsToTableViewDataSourceProtocol() {
        XCTAssertTrue(viewControllerUnderTest.conforms(to: UITableViewDataSource.self))
        XCTAssertTrue(viewControllerUnderTest.responds(to: #selector(viewControllerUnderTest.tableView(_:numberOfRowsInSection:))))
        XCTAssertTrue(viewControllerUnderTest.responds(to: #selector(viewControllerUnderTest.tableView(_:cellForRowAt:))))
    }
    
     //Mark :- test case to test number of sections in tableview
    func testNumberOfTableViewSections() {
        XCTAssertEqual(viewControllerUnderTest.tableView.numberOfSections, 1,
                       "TableView should have one section")
    }
    
    //Mark :- test case to test data count in tableview
    func testDataSource() {
        XCTAssertEqual(viewControllerUnderTest.tableData.count, 20,
                       "DataSource should have correct number of data")
    }
    
    //Mark :- test case to test TableView should have zero sections when no data is present
    func testHasZeroSectionsWhenZeroKittens() {
        viewControllerUnderTest.tableData = []

        XCTAssertEqual(viewControllerUnderTest.tableView.numberOfSections, 0,
                       "TableView should have zero sections when no data is present")
    }
    
    //Mark :- test the api call
    func testApi() {
        // create a expectation
        let pass = expectation(description: "Waiting for api call")
        
        // Make call for api
        let infoUrl = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
        NetworkManager.sharedHandler.makeGetRequestFor(url: infoUrl) { (res, error, data) in
            
            // check is error is nil or not, If not error fail the test.
            XCTAssert(error == nil, "failed with error \(error?.localizedDescription ?? "")")
            
            // check is error is nil or not, If not error fail the test.
            XCTAssert(data != nil, "data is nil")
            
            if let responseData = data {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any]
                    
                    // Check is json object is nill
                    XCTAssert(jsonObj != nil, "json object is nil")
                    
                    // Check for rows data
                    let rows = jsonObj?["rows"] as? [[String:Any]]
                    XCTAssert(rows?.count != 0, "Rows data not available")
                    
                    //Check for title
                    let data = jsonObj?["title"] as? String ?? ""
                    XCTAssert(data != "", "Title not available")
                    
                }
                catch {
                    XCTAssert(false, "Exception while conveting data to json")
                    pass.fulfill()
                }
            }
            pass.fulfill()
            
        }
        // wait for the expression
        wait(for: [pass], timeout: 60)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
