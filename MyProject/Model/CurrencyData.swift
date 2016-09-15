//
//  CurrencyData.swift
//  MyProject
//
//  Created by username on 15/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import Gloss

public class CurrencyData : Decodable {
    
    let data : [CurrencyPrice]?
    
    public required init?(json: JSON) {
        self.data = "data" <~~ json
    }
}
