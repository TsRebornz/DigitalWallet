import Foundation
import Gloss


public class BRSwiftKey  {
    var brkey : BRKey?
    
    
    public init(privateKey:String , testnet : Bool) {
        self.brkey = BRKey(privateKey: privateKey, testnet: testnet)        
    }
    
}

