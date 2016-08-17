import Foundation
import Gloss

public class TxOutput : Decodable {
    public let addresses : Array<String>
    public let script : String?
    public let script_type : String?
    public let value : UInt64?
    
    public required init?(json: JSON) {
        guard let t_addresses : Array<String> = "addresses" <~~ json,
              let t_script : String = "script" <~~ json,
              let t_script_type : String = "script_type" <~~ json,
              let t_value : UInt64 = "value" <~~ json
       	else { return nil }
        self.addresses = t_addresses
        self.script = t_script
        self.script_type = t_script_type
        self.value = t_value
    }
    
}

