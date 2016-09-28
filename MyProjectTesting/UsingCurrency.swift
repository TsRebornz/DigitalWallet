//
//  UsingCurrency.swift
//  MyProject
//
//  Created by username on 15/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import XCTest
import Foundation
@testable import MyProject

class UsingCurrency: XCTestCase {
    let defaultTimeOut: TimeInterval = 120

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testCurrencyData() {
        let expectation = self.expectation(description: "Alamofire gets bitcoin rates")
        var currencyData : CurrencyData!
        BlockCypherApi.getCurrencyData(doWithJson: { json in
            currencyData = CurrencyData(json: json)
            XCTAssert(currencyData.data?.count != nil , "No data in currency data")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: defaultTimeOut, handler: { error in
            if let t_error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        })
    }
}
