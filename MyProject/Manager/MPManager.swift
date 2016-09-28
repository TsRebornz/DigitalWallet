//
//  MPManager.swift
//  MyProject
//
//  Created by username on 16/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation

protocol MediatorProtocol : class {
    func valueChanged(whatValue : String, value : AnyObject)
    func sendData(byString : String) -> AnyObject?
}

public class MPManager : MediatorProtocol {
            
    static let localCurrency = "localCurrency"
    static let sharedInstance = MPManager()
    
    var settingsVC:SettingsViewController?
    
    // settingsDictionary["localCurrency"] = object as CurrencyPrice
    private var settingsDictionary : Dictionary<String, AnyObject> = [:]
    
    //let settingsVC
    
    //MARK: - MediatorProtocol
    func valueChanged(whatValue : String, value : AnyObject) {
        if settingsDictionary.index(forKey: whatValue) != nil {
            self.settingsDictionary.updateValue(value, forKey: whatValue)
        }else {
            self.settingsDictionary[whatValue] = value
        }
        
    }
    
    public func sendData(byString : String) -> AnyObject? {        
        if settingsDictionary.index(forKey: byString) != nil {
            //FIXME: Change to switch - case statement
            
            
            return settingsDictionary[byString]!
        }
        return nil
    }
    //MARK: -
    
}
