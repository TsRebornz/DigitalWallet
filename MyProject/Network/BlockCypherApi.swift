import Foundation
import Alamofire

public class BlockCypherApi {
    
    static let ratesRequest = "https://bitpay.com/rates"
    static let ratesRequestReserve = "https://api.breadwallet.com/rates"
    
    public enum RequestType: String {
        case TestNet = "https://api.blockcypher.com/v1/btc/test3"
        case MainNet = "https://api.blockcypher.com/v1/btc/main"
        case TestNetPushTx = "https://api.blockcypher.com/v1/btc/test3/txs/push?"
        case MainNetPushTx = "https://api.blockcypher.com/v1/btc/main/txs/push?"
        case Fee = "https://bitcoinfees.21.co/api/v1/fees/recommended"
        case RatesRequest = "https://bitpay.com/rates"
        case RatesRequestReserve = "https://api.breadwallet.com/rates"
    }
    
    static private let bitcoinApi = "https://api.blockcypher.com/v1/btc/"
    
    static private let blockCypherApi = ""
    
    // Need refactoring
    class func getBalanceByAddress(address:String, testnet: Bool, parameters: [String: AnyObject]?, succes: @escaping (Balance) -> Void ) {
        // TO:DO And what about cache?
        let requestType = testnet ? RequestType.TestNet.rawValue : RequestType.MainNet.rawValue
        let requestStr = "\(requestType)/addrs/\(address)/balance"
        Alamofire.request(requestStr, method: .get,  parameters: parameters )
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
                    succes(bal)                    
            }
    }
    
    // FIXME: Need refactoring
    class func getAddress(address: String, testnet: Bool, parameters: [String: AnyObject]?, doAfterRequest: @escaping ([String: AnyObject]) -> Void) {
        let requestType = testnet ? RequestType.TestNet.rawValue : RequestType.MainNet.rawValue
        let requestStr = "\(requestType)/addrs/\(address)"
        
        //let requestStr = "https://api.blockcypher.com/v1/btc/test3/addrs/mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        //let requestStr = "https://api.blockcypher.com/v1/btc/test3/addrs/moVeRgCBbJj1w7nhzzoSCffVJTpwH8N8SH"
        //let requestStr = "https://api.blockcypher.com/v1/btc/test3/addrs/mqMi3XYqsPvBWtrJTk8euPWDVmFTZ5jHuK"
        
        
        // TODO: And what about cache?
        Alamofire.request(requestStr, method: .get, parameters: parameters)
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
                DispatchQueue.main.async {
                    doAfterRequest(json)
                }
            }
    }
    
    class func getFeeData(doWithJson: @escaping ([String : AnyObject]) -> Void ) {
        let url : String = RequestType.Fee.rawValue
        let request = Alamofire.request(url)
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
    
    public class func getCurrencyData( doWithJson: @escaping ([String : AnyObject] ) -> Void )  {
        let url = RequestType.RatesRequest.rawValue
        let request = Alamofire.request(url)
        request.validate()
        request.responseJSON(completionHandler: { response in
            guard response.result.isSuccess else {
                print("Error reqursting full adress \(response.result.error)")
                return
            }
            
            guard let jsonResp = response.result.value as? [String : AnyObject] else {
                print("Failes to get CurrencyData")
                return
            }
            doWithJson(jsonResp)
        })
    }
    
}
