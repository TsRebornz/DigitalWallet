import Foundation
import Gloss

public class Tx : NSObject , Decodable {
    public let addresses : [String]?
    public let block_hash : String?
    public let block_height : UInt64?
    public let block_index : UInt64?
    public let confirmations : UInt64?
    public let lock_time : UInt64?
    
    public let inputs : [TxInput]?
    public let outputs : [TxOutput]?
    
    public required init?(json: JSON) {
        self.addresses = "addresses" <~~ json
        self.block_hash = "block_hash" <~~ json
        self.block_height = "block_height" <~~ json
        self.block_index = "block_index" <~~ json
        self.confirmations = "confirmations" <~~ json
        self.lock_time = "lock_time" <~~ json
        self.inputs = "inputs" <~~ json
        self.outputs = "outputs" <~~ json
    }
    
    public override init(){
        self.addresses = ["addresses"]
        self.block_hash = "block_hash"
        self.block_height = UInt64(0)
        self.block_index = UInt64(0)
        self.confirmations = UInt64(0)
        self.lock_time = UInt64(0)
        self.inputs = nil
        self.outputs = nil
    }

}
