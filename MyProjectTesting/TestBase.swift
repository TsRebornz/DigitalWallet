import XCTest
import Alamofire
import Foundation


@testable import MyProject


public class TestBase : XCTestCase {
    
    let privateKey : String = "92eByNE4NdnfpK31XV2o1iD9Bir6eLASeyDqq46YzkogTBb3HZH"
    let sendAddress : String = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
    
    
    func createTransactionTestObjectWithEmptyAddres(amount : Int) -> Transaction{
        //User input variables
        let testnet = true
        let privateKey : String = self.privateKey
        let brkey : BRKey = BRKey(privateKey: privateKey, testnet: testnet)!
        let sendAddress = self.sendAddress
        let fee = 60
        let amount = amount
        let transaction : Transaction = Transaction(brkey: brkey, sendAddress: sendAddress, fee: fee, amount: amount, testnet: testnet)
        return transaction
    }
    
    func createTestObjectTxRef(valueOfInput : Int) -> TxRef {
        let testTxRef = TxRef(tx_hash: "e5a2c36607f6128e35314de476110bb20f0de39c6d2aec380a79ac76b9e01a24",
                              block_heigth: 920372,
                              tx_input_n: 18446744073709551615,
                              tx_output_n: 1,
                              value: valueOfInput,
                              ref_balance: 373496800,
                              spent: false,
                              script: "76a9145781aca39c743a68b97e5f35cee622be3e60a20188ac",
                              confirmations: 2936)
        
        return testTxRef
    }
    
    func createTestTxData() -> TxData {
        let txref_a : TxRef = self.createTestObjectTxRef(200000)
        let txref_b : TxRef = self.createTestObjectTxRef(300000)
        
        var optimizedRefs : [TxRef] = [TxRef]()
        optimizedRefs.append(txref_a)
        optimizedRefs.append(txref_b)
        
        let balance : Int = 15000000
        
        let testnet = true
        let privateKey : String = self.privateKey
        let brKey = BRKey(privateKey: privateKey, testnet: testnet)
        
        let sendAddresses = self.sendAddress
        
        let amount = 500000
        
        let fee = 60
        
        let txData = TxData(txrefs: optimizedRefs, balance: balance, brkey: brKey!, sendAddresses: [sendAddresses], amounts: [amount], selectedFee: fee)
        return txData!
    }
    
}
