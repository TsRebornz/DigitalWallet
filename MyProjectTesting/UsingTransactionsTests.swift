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
        let ui_amount = 1650000
        let transaction : Transaction = self.createTransactionTestObjectWithEmptyAddres(ui_amount)
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
        let optimizedInputs : [TxRef] = TXService.optimizeInputsByAmount( address.txsrefs! , ui_amount: ui_amount)
        XCTAssert(optimizedInputs.count == 3 , "Bad tx opimiztion")
    }
    
    func testPrepareTxDataForTransaction(){
        let testnet = true
        let privateKey : String = self.privateKey
        let sendAddresses = self.sendAddress
        let amounts = 350000
        let feeValue = 60
        let brKey : BRKey = BRKey(privateKey: privateKey, testnet: testnet)!
        let transaction : Transaction = self.createTransactionTestObjectWithEmptyAddres(amounts)
        transaction.address = Address()
        let txref_a : TxRef = self.createTestObjectTxRef(200000)
        let txref_b : TxRef = self.createTestObjectTxRef(300000)
        
        var optimizedRefs : [TxRef] = [TxRef]()
        optimizedRefs.append(txref_a)
        optimizedRefs.append(txref_b)
        
        transaction.createMetaData(optimizedRefs, brkey: brKey, sendAddresses: [sendAddresses], amounts: [amounts], feeValue: feeValue)
        XCTAssert( nil != transaction.txData , "TxData not created" )
    }
    
    func testCreateOutputs(){
        let minersFee = 60
        let txData : TxData = self.createTestTxData()
        txData.createOuputModelByInputAndAmount(minersFee)
        XCTAssert( nil != txData.output , "Output is nil")
        XCTAssert( (txData.output?.addresses)! != (txData.output?.amounts)! , "Addresses count not equal amounts count" )
    }
    
    
    func testCalculateAdditionalMetaData(){
        let txData : TxData = self.createTestTxData()
        let miners_fee = txData.calculateMiners_fee()
        txData.createOuputModelByInputAndAmount(miners_fee)
        XCTAssert((txData.output?.addresses)! != (txData.output?.amounts)! , "Addresses count not equal amounts count" )
    }        
            
    func testCreateTransaction(){
        //Init transaction
        let testnet = true
        let privateKey : String = self.privateKey
        let brKey : BRKey = BRKey(privateKey: privateKey, testnet: testnet)!
        let balance = 100000000
        
        let amountToSend = 58000000
        
        let txref_a : TxRef = self.createTestObjectTxRef(50000000)
        let txref_b : TxRef = self.createTestObjectTxRef(4500000)
        let txref_c : TxRef = self.createTestObjectTxRef(15500000)
        let txref_d : TxRef = self.createTestObjectTxRef(30000000)
        
        var refs : [TxRef] = [TxRef]()
        refs.append(txref_a)
        refs.append(txref_b)
        refs.append(txref_c)
        refs.append(txref_d)
        
        let transaction : Transaction = createTransactionTestObjectWithEmptyAddres(amountToSend)
        
        transaction.address = Address(address: brKey.address!, total_received: 0, total_sent: 0, balance: balance, unconfirmed_balance: 0, final_balance: UInt64(balance), n_tx: 0, unconfirmed_n_tx: 0, final_n_tx: 0, txrefs: refs)
        
        
        transaction.prepareMetaDataForTx()
        transaction.calculateVariablesForMetaData()
        transaction.createTransaction()
        
        XCTAssert(nil != transaction.transaction, "Transaction not created")
        transaction.signTransaction()
        let rawTxData = transaction.transaction?.getRawTxDataStr()
    }
    
    func testSendTransaction(){
        
    }

}
