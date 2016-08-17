import XCTest
import Alamofire
import Foundation


@testable import MyProject


class UsingTransactionsTests: TestBase {
    
    /*
     How to create and raise exeption in swift
     NSException(name: "TransactionAddresGetException", reason: "Addres get failed", userInfo: nil).raise()
    */
    
    
    
    let defaultTimeOut: NSTimeInterval = 45
    
    var testTransaction : Transaction!
    
    override func setUp() {
        super.setUp()
        //self.testTransaction = createTransactionTestObject()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
//    func testResetButtonEnabledOnceRaceComplete() {
//        let expectation = keyValueObservingExpectationForObject(viewController.resetButton,
//                                                                keyPath: "enabled",
//                                                                expectedValue: true)
//        
//        // Simulate tapping the start race button
//        viewController.handleStartRaceButton(viewController.startRaceButton)
//        
//        // Wait for the test to run
//        waitForExpectationsWithTimeout(5, handler: nil)
//    }
    
//    func testTransactionClassGetAddressFromApi() {
//
//        let expectation = keyValueObservingExpectationForObject( (self.testTransaction.address as! Address) , keyPath: "balance", expectedValue: nil )
//        
//        self.testTransaction.getAddress()
//        
//        waitForExpectationsWithTimeout(self.defaultTimeOut, handler: { error in
//            if let error = error{
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//            
//        })
//        XCTAssertNotNil(self.testTransaction.address, "Test Address is nil")
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
    
    func testOptimizeImports(){
        
    }
    
    func testPrepareTxDataForTransaction(){
        
    }
    
    func testOptimizeInputs(){
        
    }
    
    func testCreateOutputs(){
        
    }
    
    func testCreateTransaction(){
        
    }
    
    func testSendTransaction(){
        
    }

}
