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
    
    class func getFiatBalanceString(model : CurrencyPrice?, satoshi : Int) -> String{
        if model != nil {
            let rate = convertSatoshToFiat(satoshi, rate: Double(model!.rate!))
            return "( \(rate) - \(model!.code!) )"
        } else {
            return ""
        }                
    }
    
}
