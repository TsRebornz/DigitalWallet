import Foundation
import Alamofire

public class BlockCypherApi{
    
    static private let bitcoinApi = "https://api.blockcypher.com/v1/btc/"
    
    static private let blockCypherApi = ""
    
    // Need refactoring
    class func getBalanceByAddress(address:String, testnet: Bool, parameters: [String: AnyObject]?, succes: (bal:(Balance)) -> Void ) {
        let testStr = testnet ? "test3" : "main"
        // TO:DO And what about cache?
        let requestStr = "https://api.blockcypher.com/v1/btc/\(testStr)/addrs/\(address)/balance"
            Alamofire.request(.GET, requestStr, parameters: parameters )
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
    }
    
    // FIXME: Need refactoring
    class func getAddress(address: String, testnet: Bool, parameters: [String: AnyObject]?, doAfterRequest: ([String: AnyObject]) -> Void) {
        let testStr = testnet ? "test3" : "main"
        let requestStr = "https://api.blockcypher.com/v1/btc/test3/addrs/mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        //let requestStr = "https://api.blockcypher.com/v1/btc/main/addrs/1DEP8i3QJCsomS4BSMY2RpU1upv62aGvhD"
        // TO:DO And what about cache?
        Alamofire.request(.GET, requestStr, parameters: parameters)
            .validate()
            .responseJSON { response in
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
    }
}
