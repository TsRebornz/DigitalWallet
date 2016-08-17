import Foundation
import Gloss


public class BRSwiftKey  {
    var brkey : BRKey?
    var bool : Bool
    
    public init(privateKey:String , testnet : Bool ){
        self.brkey = BRKey.init(privateKey: privateKey, testnet: testnet)
        self.bool = testnet
        //BRKey(secret: UInt256, compressed: <#T##Bool#>)
    }
}

