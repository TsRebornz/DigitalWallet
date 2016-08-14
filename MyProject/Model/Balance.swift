import Foundation
import Gloss

public struct Balance : Decodable {
    public let adress : String?
    public let total_received : UInt64?
    public let total_sent : UInt64?
    public let balance : UInt64?
    public let unconfirmed_balance : UInt64?
    public let final_balance : UInt64?
    public let n_tx : UInt32?
    public let unconfirmed_n_tx : UInt32?
    public let final_n_tx : UInt32?
    
    public init?(json: JSON) {
        self.final_balance = "final_balance" <~~ json
        self.adress = "address" <~~ json
        self.total_received = "total_received" <~~ json
        self.total_sent = "total_sent" <~~ json
        self.balance = "balance" <~~ json
        self.unconfirmed_balance = "unconfirmed_balance" <~~ json
        self.n_tx = "n_tx" <~~ json
        self.unconfirmed_n_tx = "unconfirmed_n_tx" <~~ json
        self.final_n_tx = "final_n_tx" <~~ json
    }
}


