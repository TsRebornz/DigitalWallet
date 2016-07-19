//
//  BRKey.swift
//  MyProject
//
//  Created by Макаренков Антон Вячеславович on 19/07/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import Gloss


public class BRSwiftKey  {
    var brkey : BRKey?
    var bool : Bool
    
    public init(privateKey:String , testnet : Bool ){
        self.brkey = BRKey.init(privateKey: privateKey, testnet: testnet)
        self.bool = testnet
        //BRKey(secret: UInt256, compressed: <#T##Bool#>)
    }
}

