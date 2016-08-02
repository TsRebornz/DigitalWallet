import Foundation
import Gloss

public class TxRef : Decodable{
    public let tx_hash : String?
    public let block_heigth : UInt64?
    public let tx_input_n : UInt64?
    public let tx_output_n : UInt64?
    public let value : UInt64?
    public let ref_balance : UInt64?
    public let spent : Bool?
    public let script : String?
    public let confirmations : UInt64?
    public let double_spent : Bool?
    public required init?(json: JSON) {
        self.tx_hash = "tx_hash" <~~ json
        self.block_heigth = "block_height" <~~ json
        self.tx_input_n = "tx_input_n" <~~ json
        self.tx_output_n = "tx_output_n" <~~ json
        self.value = "ref_balance" <~~ json
        self.ref_balance = "spent" <~~ json
        self.spent = "confirmations" <~~ json
        self.script = "script" <~~ json
        self.confirmations = "double_spent" <~~ json
        self.double_spent = "tx_hash" <~~ json
    }
}
