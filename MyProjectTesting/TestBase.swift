import XCTest
import Alamofire
import Foundation


@testable import MyProject


open class TestBase : XCTestCase {
    
    let privateKey : String = "92eByNE4NdnfpK31XV2o1iD9Bir6eLASeyDqq46YzkogTBb3HZH"
    let sendAddress : String = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
    let feeRate : Int = 60

    func createTransactionTestObject(_ balance : Int, arrayOfTxValues : [Int],  amount : Int, feeRate : Int ) -> Transaction {
        //User input variables
        let testnet = true
        let privateKey : String = self.privateKey
        let brkey : BRKey = BRKey(privateKey: privateKey, testnet: testnet)!
        let sendAddress = self.sendAddress
        let testAddress = self.createTestAddress(balance, arrayOfTxValues: arrayOfTxValues)
        let transaction : Transaction = Transaction(address: testAddress!, brkey: brkey, sendAddress: sendAddress, fee: feeRate, amount: amount)
        return transaction
    }
        
    func createTestAddress(_ balance: Int, arrayOfTxValues : [Int]) -> Address? {
        guard balance == arrayOfTxValues.reduce(0, +) else {
            NSException(name: NSExceptionName(rawValue: "testbase.createtestaddress"), reason: "Prosto idi na Xyu , bratan. Ne umeesh polzovatsya ne beris", userInfo: nil).raise()
            return nil
        }
        let testnet = true
        let key : BRKey = BRKey(privateKey: self.privateKey, testnet: testnet)!
        let selfAddress = key.address!
        
        var txrefs = [TxRef]()
        for txValue in arrayOfTxValues {
            let txRef = self.createTestObjectTxRef(txValue)
            txrefs.append(txRef)
        }
        
        let address = Address(address: selfAddress,
                              total_received: UInt64(balance),
                              total_sent: UInt64(0),
                              balance: balance  as NSNumber ,
                              unconfirmed_balance: UInt64(0),
                              final_balance: UInt64(balance),
                              n_tx: UInt64(0),
                              unconfirmed_n_tx: UInt64(0),
                              final_n_tx: UInt64(0),
                              txrefs: txrefs)
        
//        let address = Address(address: selfAddress,
//                              total_received: UInt64(balance),
//                              total_sent: UInt64(0),
//                              balance: NSNumber(balance),
//                              unconfirmed_balance: UInt64(0),
//                              final_balance: UInt64(balance),
//                              n_tx: UInt64(0),
//                              unconfirmed_n_tx: UInt64(0),
//                              final_n_tx: UInt64(0),
//                              txrefs: txrefs)
        return address
    }
    
    func createTestObjectTxRef(_ valueOfInput : Int) -> TxRef {
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
        let testnet = true
        let privateKey : String = self.privateKey
        let brKey = BRKey(privateKey: privateKey, testnet: testnet)
        let sendAddresses = self.sendAddress
        let amount = 500000
        let fee = 60
        let txData = TxData(txrefs: optimizedRefs, brkey: brKey!, sendAddresses: [sendAddresses], amounts: [amount], selectedFee: fee)
        return txData!
    }
}
