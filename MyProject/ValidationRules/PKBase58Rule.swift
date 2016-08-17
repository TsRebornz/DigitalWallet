import Foundation
import SwiftValidator

public class PKBase58Rule : RegexRule
{
    static let regex = "[[1-9A-Za-z]--[OIl]]+"
    
    convenience init(message : String = "Not a valid Base58"){
        self.init(regex: PKBase58Rule.regex, message: message)
    }
}
