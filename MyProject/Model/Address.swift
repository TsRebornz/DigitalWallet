import Foundation
import Gloss

public class Address : Decodable{
    public let address : String?
    public let total_received : UInt64?
    public let total_sent : UInt64?
    public let balance : UInt64?
    public let unconfimed_balance : UInt64? //Баланс с неподтвержденных транзакций
    public let final_balance : UInt64?
    public let n_tx : UInt64? // n_tx n -- number tx -- transaction
    public let unconfirmed_n_tx : UInt64?
    public let final_n_tx : UInt64?
    public let txsrefs : [TxRef]?
    
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
        //guard let t_txrefs : [TxRef] = "txrefs" <~~ json
            //else { return nil }
        self.txsrefs = "txrefs" <~~ json
    }
}


