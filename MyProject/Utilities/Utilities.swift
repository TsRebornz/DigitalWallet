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
        let localRate = Float(bitcoins * rate)
        return round(localRate * 1000) / 1000
    }
    
    class func convertFiatToSatoshi(fiat : Float , rate : Double) -> Int {
        let bitcoins : Double = Double(fiat) / rate
        return Int(bitcoins * 100000000)
    }
    
    
    class func getFiatBalanceString(model : CurrencyPrice?, satoshi : Int , withCode : Bool) -> String{
        if model != nil {
            let rate = convertSatoshToFiat(satoshi: satoshi, rate: Double(model!.rate!))
            return "\(rate)" + (withCode ? " - \(model!.code!)" : "")
        } else {
            return ""
        }                
    }
    
}
