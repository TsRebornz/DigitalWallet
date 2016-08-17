import Foundation
import SwiftValidator


public class PKBase58 : RegexRule
{
    static let regex = "[[1-9A-Za-z]--[OIl]]+"

    convenience init(message : String = "Not a valid Base58"){
        self.init(regex: PKBase58.regex, message: message)
    }
}
