import Foundation
import Gloss

public class FullAddress : Decodable{
    public let address : String?
    public let final_n_tx : UInt64? //Колличество подтврежденных транзакций
    public let final_balance : UInt64?
    public let total_sent : UInt64?
    public let unconfimed_balance : UInt64? //Баланс с неподтвержденных транзакций
    public let balance : UInt64?
    public let n_tx : UInt64? // n_tx n -- number tx -- transaction
    public let unconfirmed_n_tx : UInt64?
    public let total_received : UInt64?
    public let txs : [Tx]
    
    public required init?(json: JSON) {
        guard let t_address : String = "address" <~~ json,
              let t_final_n_tx : UInt64 = "final_n_tx" <~~ json,
              let t_final_balance : UInt64 = "final_balance" <~~ json,
              let t_total_sent : UInt64 = "total_sent" <~~ json,
              let t_unconfimed_balance : UInt64 = "unconfirmed_balance" <~~ json,
              let t_balance : UInt64 = "balance" <~~ json,
              let t_n_tx : UInt64 = "n_tx" <~~ json,
              let t_unconfirmed_n_tx : UInt64 = "unconfirmed_n_tx" <~~ json,
              let t_total_received : UInt64 = "total_received" <~~ json
        else { return nil }
        guard let t_txs : [Tx] = "txs" <~~ json
        else { return nil }
        self.address = t_address
        self.final_n_tx = t_final_n_tx
        self.final_balance = t_final_balance
        self.total_sent = t_total_sent
        self.unconfimed_balance = t_unconfimed_balance
        self.balance = t_balance
        self.n_tx = t_n_tx
        self.unconfirmed_n_tx = t_unconfirmed_n_tx
        self.total_received = t_total_received
        self.txs = t_txs        
    }
}
