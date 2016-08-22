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
        let transaction : Transaction = self.createTransactionTestObjectWithEmptyAddres()
        transaction.address = Address()
        let txref_a : TxRef = self.createTestObjectTxRef(1500000)
        let txref_b : TxRef = self.createTestObjectTxRef(1200000)
        let txref_c : TxRef = self.createTestObjectTxRef(200000)
        let txref_d : TxRef = self.createTestObjectTxRef(250000)
        let address : Address = transaction.address as! Address
        address.txsrefs = [TxRef]()
        address.txsrefs?.append(txref_a)
        address.txsrefs?.append(txref_b)
        address.txsrefs?.append(txref_c)
        address.txsrefs?.append(txref_d)
        let txRefs : [TxRef] = transaction.optimizeInputsByAmount(address.txsrefs!, ui_amount: 600000)
        XCTAssert(txRefs.count == 3 , "Bad tx opimiztion")
        
    }
    
    func testPrepareTxDataForTransaction(){
        let testnet = true
        let privateKey : String = "cSF9RngdtVNaKpbsH6eBgWGm8xFNc3ViRXgZpfQddQxaGe2G4uXJ"
        let balance = 500000
        let sendAddresses = "moVeRgCBbJj1w7nhzzoSCffVJTpwH8N8SH"
        let amounts = 350000
        let feeValue = 60
        let brKey : BRKey = BRKey(privateKey: privateKey, testnet: testnet)!
        let transaction : Transaction = self.createTransactionTestObjectWithEmptyAddres()
        transaction.address = Address()
        let txref_a : TxRef = self.createTestObjectTxRef(200000)
        let txref_b : TxRef = self.createTestObjectTxRef(250000)
        
        var optimizedRefs : [TxRef] = [TxRef]()
        optimizedRefs.append(txref_a)
        optimizedRefs.append(txref_b)
        
        transaction.createMetaData(optimizedRefs, balance: balance, brkey: brKey, sendAddresses: [sendAddresses], amounts: [amounts], feeValue: feeValue)
        XCTAssert( nil != transaction.txData , "TxData not created" )
    }
    
//    func testCalculateAdditionalMetaData(){
//        XCTAssert(<#T##expression: BooleanType##BooleanType#>)
//    }
    
    func testCreateOutputs(){
        
    }
    
    func testCreateTransaction(){
        
    }
    
    func testSendTransaction(){
        
    }

}
