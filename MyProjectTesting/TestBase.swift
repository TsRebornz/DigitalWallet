import XCTest
import Alamofire
import Foundation


@testable import MyProject


public class TestBase : XCTestCase {
    
    
    
    func createTransactionTestObjectWithEmptyAddres() -> Transaction{
        //User input variables
        let testnet = true
        let privateKey : String = "92eByNE4NdnfpK31XV2o1iD9Bir6eLASeyDqq46YzkogTBb3HZH"
        let brkey : BRKey = BRKey(privateKey: privateKey, testnet: testnet)!
        let sendAddress = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        let fee = 60
        let amount = 1500000
        let transaction : Transaction = Transaction(brkey: brkey, sendAddress: sendAddress, fee: fee, amount: amount, testnet: testnet)
        return transaction
    }
    
    func createTransactionTestObject(){        
//        let testnet = true
//        let privateKey : String = "92eByNE4NdnfpK31XV2o1iD9Bir6eLASeyDqq46YzkogTBb3HZH"
//        let brkey : BRKey = BRKey(privateKey: privateKey, testnet: testnet)!
//        let sendAddress = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
//        let fee = 60
//        let amount = 1500000
//        let transaction : Transaction = Transaction(brkey: brkey, sendAddress: sendAddress, fee: fee, amount: amount, testnet: testnet)
//        var testAddress =  (transaction.address as! Address)
//        testAddress.address = ""
//        testAddress.balance = 0
//        testAddress.final_balance = 0
//        testAddress.final_n_tx = 0
//        testAddress.n_tx = 0
//        testAddress.total_received = 0
//        testAddress.total_sent = 0
//        testAddress.txsrefs = 0
//        testAddress.txsrefs = [TxRef]
    }
    
    
    
    
    
}
