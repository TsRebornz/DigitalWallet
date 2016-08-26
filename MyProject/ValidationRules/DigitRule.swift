//
//  DigitRule.swift
//  MyProject
//
//  Created by username on 26/08/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import SwiftValidator

public class DigitRule : RegexRule //DjigitRule :P
{
    static let regex = "[0-9]+"
    
    convenience init(message : String = "Not number value"){
        self.init(regex: DigitRule.regex, message: message)
    }
}
