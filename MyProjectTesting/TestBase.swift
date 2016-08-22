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
    
}
