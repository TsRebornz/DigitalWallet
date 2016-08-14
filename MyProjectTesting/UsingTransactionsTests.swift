import XCTest
import Alamofire
import Foundation


@testable import MyProject


class UsingTransactionsTests: TestBase {
    
    /*
     How to create and raise exeption in swift
     NSException(name: "TransactionAddresGetException", reason: "Addres get failed", userInfo: nil).raise()
    */
    
    var testTransaction : Transaction!
    
    override func setUp() {
        super.setUp()
        self.testTransaction = createTransactionTestObject()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
//    func testTransactionClassGetAddressFromApi() {
        //let expectation = expectationWithDescription("Alamofire send BC.Balance request and handle response using the callback")
//        let address: Address = self.testTransaction.getAddress()
//        waitForExpectationsWithTimeout(self.defaultTimeOut, handler: { error in
//            if let error = error{
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//            
//        })
//        XCTAssertNotNil(address, "Test Address is nill")
//    }
    
//    func testTransactionClass() {
//        //Expectation
//        
//        //User input variables
//        self.testTransaction.getAddress()
//        
//        self.testTransaction.optimizeInputsAccordingToAmount()
//        self.testTransaction.prepareMetaDataForTx()
//        
//    }

}
