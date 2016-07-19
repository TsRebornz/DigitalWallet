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
        //"api.blockcypher.com/v1/btc/test3"
        Alamofire.request(.GET, "https://api.blockcypher.com/v1/btc/main/addrs/\(adress)/balance")
            .validate()
            .responseJSON { response in
                XCTAssert(response.result.isSuccess, "Error reqursting balance \(response.result.error)")
                
                let jsonResp = response.result.value as? [String: AnyObject]
                XCTAssertNotNil(jsonResp, "Balance is not a JSON Type")

                let bal = Balance(json: jsonResp!)
                XCTAssertNotNil(bal, "Error initializing object")

                XCTAssert(bal!.final_balance == 4433416, "Balance not match bal = \(bal!.final_balance)")
                print(bal!.final_balance)
        }
    }
    
    func testBrkeyAdress(){
        
        //initialize etalon private key
        
        //create brkey
        // compare
    }
    
    func testGetFullAdressFunction(){
        let adress = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        let addressAlwayaWorkable = "1DEP8i3QJCsomS4BSMY2RpU1upv62aGvhD"
        print("0")
        
        BlockCypherApi.getFullAdress(addressAlwayaWorkable, testnet: false, doAfterRequest: {(json) -> Void in
            print("unconfirmed_balance - \(json)")
        })
        
        print("2")
    }
    
    
    
}
