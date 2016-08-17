import Foundation
import Gloss

public class Tx : Decodable{
    public let addresses : Array<String>
    public let block_hash : String?
    public let block_height : UInt64?
    public let block_index : UInt64?
    public let confirmations : UInt64?
    public let lock_time : UInt64?
    
    public let inputs : [TxInput]
    public let outputs : [TxOutput]
    
    // t -- temp
    public required init?(json: JSON) {
        guard let t_addresses: Array<String> = "addresses" <~~ json ,
                let t_block_hash : String = "block_hash" <~~ json,
                let t_block_height : UInt64 = "block_height" <~~ json,
                let t_block_index : UInt64 = "block_index" <~~ json,
                let t_confirmations : UInt64 = "confirmations" <~~ json,
                let t_lock_time : UInt64 = "lock_time" <~~ json
        else { return nil }
        guard let t_inputs : [TxInput] = "inputs" <~~ json,
                let t_outputs : [TxOutput] = "outputs" <~~ json
        else { return nil }
        self.addresses = t_addresses
        self.block_hash = t_block_hash
        self.block_height = t_block_height
        self.block_index = t_block_index
        self.confirmations = t_confirmations
        self.lock_time = t_lock_time
        self.inputs = t_inputs
        self.outputs = t_outputs
    }
}