import Foundation
import Gloss

public class Address : NSObject, Decodable {
    public let address : String?
    public let total_received : UInt64?
    public let total_sent : UInt64?
    public let balance : NSNumber?
    public let unconfimed_balance : UInt64? //Баланс с неподтвержденных транзакций
    public let final_balance : UInt64?
    public let n_tx : UInt64? // n_tx n -- number tx -- transaction
    public let unconfirmed_n_tx : UInt64?
    public let final_n_tx : UInt64?
    public var txsrefs : [TxRef]?
    
    public required init?(json: JSON) {
        self.address = "address" <~~ json
        self.total_received = "total_received" <~~ json
        self.total_sent = "total_sent" <~~ json
        self.balance = "balance" <~~ json
        self.unconfimed_balance = "unconfimed_balance" <~~ json
        self.final_balance = "final_balance" <~~ json
        self.n_tx = "n_tx" <~~ json
        self.unconfirmed_n_tx = "unconfirmed_n_tx" <~~ json
        self.final_n_tx = "final_n_tx" <~~ json
        self.txsrefs = "txrefs" <~~ json
    }
    
    
    // MARK: - For testing
    public init(address: String, total_received : UInt64, total_sent : UInt64, balance : NSNumber, unconfirmed_balance : UInt64, final_balance : UInt64, n_tx : UInt64, unconfirmed_n_tx : UInt64, final_n_tx : UInt64 , txrefs : [TxRef]) {
        self.address = address
        self.total_received = total_received
        self.total_sent = total_sent
        self.balance = balance
        self.unconfimed_balance = unconfirmed_balance
        self.final_balance = final_balance
        self.n_tx = n_tx
        self.unconfirmed_n_tx = unconfirmed_n_tx
        self.final_n_tx = final_n_tx
        self.txsrefs = txrefs
    }
    
    public override init() {
        self.address = nil
        self.total_received = nil
        self.total_sent = nil
        self.balance = 0
        self.unconfimed_balance = nil
        self.final_balance = nil
        self.n_tx = nil
        self.unconfirmed_n_tx = nil
        self.final_n_tx = nil
        self.txsrefs = nil
    }
    // MARK: -
}


