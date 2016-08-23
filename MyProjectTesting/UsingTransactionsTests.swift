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
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
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
    
    func testOptimizeImports(){
        let transaction : Transaction = self.createTransactionTestObjectWithEmptyAddres()
        transaction.address = Address()
        let ui_amount = 1650000
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
        let txRefs : [TxRef] = transaction.optimizeInputsByAmount(address.txsrefs!, ui_amount: ui_amount)
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
        let txref_b : TxRef = self.createTestObjectTxRef(300000)
        
        var optimizedRefs : [TxRef] = [TxRef]()
        optimizedRefs.append(txref_a)
        optimizedRefs.append(txref_b)
        
        transaction.createMetaData(optimizedRefs, balance: balance, brkey: brKey, sendAddresses: [sendAddresses], amounts: [amounts], feeValue: feeValue)
        XCTAssert( nil != transaction.txData , "TxData not created" )
    }
    
    func testCreateOutputs(){
        let minersFee = 60
        let txData : TxData = self.createTestTxData()
        txData.createOuputModelByInputAndAmount(minersFee)
        XCTAssert( nil != txData.output , "Output is nil")
        XCTAssert( (txData.output?.addresses)! != (txData.output?.amounts)! , "Addresses count not equal amounts count" )
    }
    
    
//    func testCalculateAdditionalMetaData(){
//        var txData : TxData = self.createTestTxData()
//        txData.calculateVariables()
//        XCTAssert(false, "Output and fee values doesn't calculated")
//    }        
    
    
    
    func testCreateTransaction(){
        
    }
    
    func testSendTransaction(){
        
    }

}
