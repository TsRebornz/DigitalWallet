//
//  Balance.swift
//  MyProject
//
//  Created by Макаренков Антон Вячеславович on 20/07/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import Gloss

public struct Balance : Decodable {
    public let adress : String?
    public let total_received : UInt64?
    public let total_sent : UInt64?
    public let balance : UInt64?
    public let unconfirmed_balance : UInt64?
    public let final_balance : UInt64
    public let n_tx : UInt32?
    public let unconfirmed_n_tx : UInt32?
    public let final_n_tx : UInt32?
    
    public init?(json: JSON) {
        guard let fin_bal : UInt64 = "final_balance" <~~ json
            else {
                return nil
            }
        
        self.adress = "address" <~~ json
        self.total_received = "total_received" <~~ json
        self.total_sent = "total_sent" <~~ json
        self.balance = "balance" <~~ json
        self.unconfirmed_balance = "unconfirmed_balance" <~~ json
        self.final_balance = fin_bal
        self.n_tx = "n_tx" <~~ json
        self.unconfirmed_n_tx = "unconfirmed_n_tx" <~~ json
        self.final_n_tx = "final_n_tx" <~~ json
    }
}


