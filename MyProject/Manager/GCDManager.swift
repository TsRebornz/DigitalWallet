//
//  GCDManager.swift
//  MyProject
//
//  Created by username on 28/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation

public class GCDManager {
    static let sharedInstance = GCDManager()
    
    func getQueue(byQoS : DispatchQoS) -> DispatchQueue {
        return DispatchQueue(label: "MP\(String(describing: byQoS))" , qos: byQoS)
    }        
}
