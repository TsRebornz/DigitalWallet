//
//  CurrencyPrice.swift
//  MyProject
//
//  Created by username on 15/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import Gloss

public class CurrencyPrice : NSObject, Decodable {
    let code : String?
    let name : String?
    var rate : Float?
    
    public required init?(json: JSON) {
        self.code = "code" <~~ json
        self.name = "name" <~~ json
        self.rate = "rate" <~~ json
    }
    
}
