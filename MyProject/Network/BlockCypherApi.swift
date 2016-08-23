import Foundation
import Alamofire

public class BlockCypherApi{
    
    public enum RequestType: String{
        case TestNet = "https://api.blockcypher.com/v1/btc/test3"
        case MainNet = "https://api.blockcypher.com/v1/btc/main"
        case TestNetPushTx = "https://api.blockcypher.com/v1/btc/test3/txs/push?"
        case MainNetPushTx = "https://api.blockcypher.com/v1/bcy/test/txs/push?"
        case Fee = "https://bitcoinfees.21.co/api/v1/fees/recommended"
    }
    
    static private let bitcoinApi = "https://api.blockcypher.com/v1/btc/"
    
    static private let blockCypherApi = ""
    
    // Need refactoring
    class func getBalanceByAddress(address:String, testnet: Bool, parameters: [String: AnyObject]?, succes: (bal:(Balance)) -> Void ) {
        // TO:DO And what about cache?
        let requestType = testnet ? RequestType.TestNet.rawValue : RequestType.MainNet.rawValue
        let requestStr = "\(requestType)/addrs/\(address)/balance"
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
        let requestType = testnet ? RequestType.TestNet.rawValue : RequestType.MainNet.rawValue
        let requestStr = "\(requestType)/addrs/\(address)"
        
        //let requestStr = "https://api.blockcypher.com/v1/btc/test3/addrs/mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        //let requestStr = "https://api.blockcypher.com/v1/btc/test3/addrs/moVeRgCBbJj1w7nhzzoSCffVJTpwH8N8SH"
        //let requestStr = "https://api.blockcypher.com/v1/btc/test3/addrs/mqMi3XYqsPvBWtrJTk8euPWDVmFTZ5jHuK"
        
        
        // TODO: And what about cache?
        Alamofire.request(.GET, requestStr, parameters: parameters)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error reqursting full adress \(response.result.error)")
                    return
                }
                
                guard let json = response.result.value as? [String: AnyObject] else {
                    print("Balance is not a JSON Type")
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    doAfterRequest(json)
                })
            }
    }
    
    class func getFeeData(doWithJson: ([String : AnyObject]) -> Void ){
        let url : String = RequestType.Fee.rawValue
        let request = Alamofire.request(.GET, url)
        request.validate()
        request.responseJSON(completionHandler: { response in
            guard response.result.isSuccess else {
                print("Error reqursting full adress \(response.result.error)")
                return
            }
            
            guard let json = response.result.value as? [String: AnyObject] else {
                print("Balance is not a JSON Type")
                return
            }
            doWithJson(json)
        })
    }
    
    public class func getTopAppsDataFromFileWithSuccess(fileName : String, success: ((data: NSData) -> Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType:"json")
            let data = try! NSData(contentsOfFile:filePath!,
                options: NSDataReadingOptions.DataReadingUncached)
            success(data: data)
        })
    }
        
    //TODO: Use it in methods above, make your code DRY(Dont repeat yourself)!
    func responseDataGetAndCheck(response:Response<AnyObject, NSError> ) {//-> [String: AnyObject] {
        guard response.result.isSuccess else {
            print("Error reqursting full adress \(response.result.error)")
            return //["Error": "Error"]
        }
        
//        guard let json = response.result.value as? [String: AnyObject] else {
//            print("Balance is not a JSON Type")
//            return //["Error": "Error"]
//        }
    }
}
