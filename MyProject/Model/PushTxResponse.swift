import Foundation
import Gloss

public class PushTxResponse : Decodable{
    public let tx : Tx?
    public required init?(json: JSON) {
        self.tx = "tx" <~~ json
    }
}
