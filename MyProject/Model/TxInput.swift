import Foundation
import Gloss

public class TxInput : Decodable{
    public let addresses : Array<String>
    public let output_index : UInt64?
    public let output_value : UInt64?
    public let prev_hash : String? // Хэш предыдущей транзакции которая была input
    public let script : String? // could be nil
    public let script_type : String? //// could be nil
    public let sequence : UInt64?
    
    public required init?(json: JSON) {
        guard let t_addresses : Array<String> = "addresses" <~~ json,
            let t_script : String = "script" <~~ json,
            let t_script_type : String = "script_type" <~~ json,
            let t_output_index : UInt64 = "output_index" <~~ json,
            let t_output_value : UInt64 = "output_value" <~~ json,
            let t_prev_hash : String = "prev_hash" <~~ json,
            let t_sequence : UInt64 = "sequence" <~~ json
            else { return nil }
        self.addresses = t_addresses
        self.script = t_script
        self.script_type = t_script_type
        self.output_index = t_output_index
        self.output_value = t_output_value
        self.prev_hash = t_prev_hash
        self.sequence = t_sequence
    }
}
