//
//  AddressRule.swift
//  MyProject
//
//  Created by username on 24/08/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import SwiftValidator

public class AddressRule : RegexRule
{
    static let regex = "([[1-9A-Za-z]--[OIl]]{34})"//([1mn]{1}
    
    convenience init(message : String = "Not a valid Address"){
        self.init(regex: AddressRule.regex, message: message)
    }
}
