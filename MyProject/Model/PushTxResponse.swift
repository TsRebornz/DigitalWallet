import Foundation
import Gloss
 
public class PushTxResponse : NSObject, Decodable {
    public dynamic var tx : Tx?
    
    public required init?(json: JSON) {
        self.tx = "tx" <~~ json
    }
    
    public override init(){
        self.tx = Tx()
    }
}
