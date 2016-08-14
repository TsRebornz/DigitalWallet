import Foundation
import Gloss

public class Fee : Decodable {
    public let fastestFee : Int?
    public let halfHourFee : Int?
    public let hourFee : Int?
    
    public required init?(json: JSON) {
        self.fastestFee = "fastestFee" <~~ json
        self.halfHourFee = "halfHourFee" <~~ json
        self.hourFee = "hourFee" <~~ json
    }
    
    
}
