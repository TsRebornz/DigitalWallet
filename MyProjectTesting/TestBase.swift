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
    
}
