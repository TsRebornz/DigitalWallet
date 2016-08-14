import Foundation
import Gloss

public class TxRef : Decodable{
    public let tx_hash : String?
    public let block_heigth : UInt64?
    public let tx_input_n : UInt64?
    public let tx_output_n : UInt64?
    public let value : Int?
    public let ref_balance : UInt64? // nil if tx is UNCONFIRMED!
    public let spent : Bool?
    public let script : String?
    public let confirmations : UInt64?
    public let double_spent : Bool?
    public let spent_by : String?
    public required init?(json: JSON) {
        self.tx_hash = "tx_hash" <~~ json
        self.block_heigth = "block_height" <~~ json
        self.tx_input_n = "tx_input_n" <~~ json
        self.tx_output_n = "tx_output_n" <~~ json
        self.value = "value" <~~ json
        self.ref_balance = "ref_balance" <~~ json
        self.spent = "spent" <~~ json
        self.script = "script" <~~ json
        self.confirmations = "confirmations" <~~ json
        self.double_spent = "double_spent" <~~ json
        self.spent_by = "spent_by" <~~ json
    }
}
