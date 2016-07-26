//
//  MyProjectTests.swift
//  MyProjectTests
//
//  Created by Макаренков Антон Вячеславович on 20/07/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import XCTest
import Alamofire

@testable import MyProject

class MyProjectTests: XCTestCase {
    
    let base58TestArr : Array = ["O000000000000000000","l0000000","&*^$&*^$&*^$&*^$&*^$&*^$&*^$","asd;lfj falksdjflj  dslkjflkasj flksdajflj ", "" ]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testKey() {
        let hui = BRKey(privateKey: "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", testnet: true)
        XCTAssert(hui != nil, "Hui is nil")
        XCTAssert(hui?.address != nil, "Address is nil")
        if hui == nil {
            XCTFail("Something is wrong")
        }
        XCTAssertNotNil(hui, "hui is nil")
    }
    
    func testGetBalance() {
        let adress = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        //Define an expectation
        let expectation = expectationWithDescription("Alamofire send request and handle respnse using the callback closure")
        let request = Alamofire.request(.GET, "https://api.blockcypher.com/v1/btc/test3/addrs/\(adress)/balance")
        let timeout = request.task.originalRequest?.timeoutInterval
        
        request.validate()
        request.responseJSON { response in
                    XCTAssert(response.result.isSuccess, "Error reqursting balance \(response.result.error)")
                    guard let jsonResp = response.result.value as? [String: AnyObject] else {
                        XCTFail("Balance is not a JSON Type")
                        return
                    }
                    XCTAssertNotNil(jsonResp, "Balance is not a JSON Type" )
                        
                    let bal = Balance(json: jsonResp)
                    XCTAssertNotNil(bal, "Error initializing object")
                    
                    XCTAssert(bal!.final_balance == 4433416, "Balance not match bal = \(bal!.final_balance)")
                    print(bal!.final_balance)
            
                    //Exercise the asynchronous code
                    expectation.fulfill()
                }
        //Wait for the expectation to be fulfilled
        waitForExpectationsWithTimeout(timeout!, handler: { error in
            if let error = error{
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        })
    }
    
//    func testAsyncCalback() {
//        let service = SomeService()
    
        // 1. Define an expectation
//        let expectation = expectationWithDescription("SomeService does stuff and runs the callback closure")
    
        // 2. Exercise the asynchronous code
//        service.doSomethingAsync { success in
//            XCTAssertTrue(success)
    
            // Don't forget to fulfill the expectation in the async callback
//            expectation.fulfill()
//        }
    
        // 3. Wait for the expectation to be fulfilled
//        waitForExpectationsWithTimeout(1) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//        }
    
    func testBrkeyAdress(){
        
        //initialize etalon private key
        
        //create brkey
        // compare
    }
    
    func addressHandle(_ json: [String: AnyObject]) {
        for string in json {
            print(string)
        }
    }
    
    func testGetFullAdressFunction(){
        //        let address = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        let addressAlwayaWorkable = "1DEP8i3QJCsomS4BSMY2RpU1upv62aGvhD"
        print("0")
        
        BlockCypherApi.getFullAddress(addressAlwayaWorkable, testnet: false, doAfterRequest: addressHandle)
        
        print("2")
    }
    
    
    
}
