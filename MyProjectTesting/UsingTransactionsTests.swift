import XCTest
import Alamofire
import Foundation


@testable import MyProject


class UsingTransactionsTests: TestBase {
    
    let defaultTimeOut: NSTimeInterval = 45
    
    var testTransaction : Transaction!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
   func testOptimizeImports(){
        let ui_amount = 1650000
        let transaction : Transaction = self.createTransactionTestObjectWithEmptyAddress(ui_amount)
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
        let brKey : BRKey = BRKey(privateKey: privateKey, testnet: testnet)!
        
        let amounts = 350000
        
        let txRefsValues = [ 200000, 300000]
        let balance = txRefsValues.reduce(0, combine: +)
        
        let transaction : Transaction = self.createTransactionTestObject(balance, arrayOfTxValues: txRefsValues, amount: amounts, feeRate: self.feeRate)
        let tx_refs : [TxRef] = (transaction.address as! Address).txsrefs!
        
        transaction.createMetaData(tx_refs, brkey: brKey, sendAddresses: [sendAddresses], amounts: [amounts], feeValue: feeRate)
        XCTAssert( nil != transaction.txData , "TxData not created" )
    }
    
    func testCreateOutputs(){
        
        let txData : TxData = self.createTestTxData()
        txData.createOuputModelByInputAndAmount(self.feeRate)
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
        //let testnet = true
        let balance = 100000000
        let txRefsValues = [ 50000000, 15500000, 4500000, 30000000 ]
        let amountToSend = 58000000
        
        let transaction : Transaction = self.createTransactionTestObject(balance, arrayOfTxValues: txRefsValues, amount: amountToSend, feeRate: self.feeRate)

        transaction.prepareMetaDataForTx()
        transaction.calculateVariablesForMetaData()
        transaction.createTransaction()
        
        XCTAssert(nil != transaction.transaction , "Transaction not created")
        //transaction.signTransaction()
        //let rawTxData = transaction.transaction?.getRawTxDataStr()
    }
    
    func testSendTransaction(){
        
    }

}
