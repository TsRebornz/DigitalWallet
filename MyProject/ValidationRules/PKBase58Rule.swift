//
//  PKBase54Rule.swift
//  MyProject
//
//  Created by Макаренков Антон Вячеславович on 21/07/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import SwiftValidator

public class PKBase58Rule : RegexRule
{
    static let regex = "[[1-9A-Za-z]--[OIl]]+"
    
    convenience init(message : String = "Not a valid Base58"){
        self.init(regex: PKBase58Rule.regex, message: message)
    }
}
