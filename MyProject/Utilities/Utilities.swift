//
//  Utilities.swift
//  MyProject
//
//  Created by username on 14/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation

public class Utilities {
    class func convertSatoshToFiat(satoshi : Int , rate : Double) -> Float{
        let bitcoins : Double = Double(satoshi) / 100000000
        return Float(bitcoins * rate) 
    }
}
