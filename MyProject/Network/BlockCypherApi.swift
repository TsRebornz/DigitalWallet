//
//  BlockCypherApi.swift
//  MyProject
//
//  Created by Макаренков Антон Вячеславович on 22/07/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import Alamofire

public class BlockCypherApi{
    
    static private let bitcoinApi = "https://api.blockcypher.com/v1/btc/"
    
    static private let blockCypherApi = ""
    
    
    //public class func getTopAppsDataFromFileWithSuccess(success: (data:(NSData)) -> Void )   {
    // Need refactoring
    class func getBalanceByAddress(address:String, testnet: Bool, succes: (bal:(Balance)) -> Void ) {
        let testStr = testnet ? "test3" : "main"
        var requestStr = "https://api.blockcypher.com/v1/btc/\(testStr)/addrs/\(address)/balance"
            //
        
        do{
            Alamofire.request(.GET, requestStr)
                .validate()
                .responseJSON { (response) -> Void in
                    guard response.result.isSuccess else {
                        print("Error reqursting balance \(response.result.error)")
                        
                        return
                    }
                    guard let jsonResp = response.result.value as? [String: AnyObject]
                        else {
                            print("Balance is not a JSON Type")
                            return
                    }
                    guard let bal = Balance(json: jsonResp) else {
                        print("Error initializing object")
                        return
                    }
                    succes(bal: bal)
                    
            }
        }catch{
            print("Error ocured \(error)")
        }
        
    }
    
    // Need refactoring
    
    class func getFullAdress(address: String, testnet: Bool, doAfterRequest:([String: AnyObject]) -> Void ){
        let testStr = testnet ? "test3" : "main"
        var requestStr = "https://api.blockcypher.com/v1/btc/main/addrs/1DEP8i3QJCsomS4BSMY2RpU1upv62aGvhD/full?before=300000"
        do{
            Alamofire.request(.GET, requestStr)
                .validate()
                .responseJSON { (response) -> Void in
                    guard response.result.isSuccess else {
                        print("Error reqursting full adress \(response.result.error)")
                        
                        return
                    }
                    guard let json = response.result.value as? [String: AnyObject]
                        else {
                            print("Balance is not a JSON Type")
                            return
                    }
                    doAfterRequest(json)
            }
        }catch{
            print("Error ocured \(error)")
        }
        
        
    }
    
    
    
    
}
