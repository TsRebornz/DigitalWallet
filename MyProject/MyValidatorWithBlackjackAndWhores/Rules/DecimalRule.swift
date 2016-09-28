//
//  DecimalRule.swift
//  MyProject
//
//  Created by username on 21/09/16.
//  Copyright © 2016 BCA. All rights reserved.

//FIXME Validation rules

import Foundation
import SwiftValidator

public class DecimalRule : RegexRule //DjigitRule :P
{
    static let regex = "^\\d*\\.?\\d*$"
    
    convenience init(message : String = "Not number value"){
        self.init(regex: DecimalRule.regex, message: message)
    }
}
