import XCTest
import Alamofire
import Foundation


@testable import MyProject

class MyProjectTests: TestBase {
    
    var rawDataTransaction: String? = nil
    
    let defaultTimeOut: TimeInterval = 120
    let fastestFee = 150 // per byte
    
    
    let base58TestArr : Array = ["O000000000000000000","l0000000","&*^$&*^$&*^$&*^$&*^$&*^$&*^$","asd;lfj falksdjflj  dslkjflkasj flksdajflj ", "" ]
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testKey() {
        let hui = BRKey(privateKey: "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", testnet: true)
        XCTAssert(hui != nil, "Hui is nil")
        XCTAssert(hui?.address != nil, "Address is nil")
        if hui == nil {
            XCTFail("Something is wrong")
        }
        XCTAssertNotNil(hui, "hui is nil")
    }
    
    func testGetBalance() {
        let adress = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        //Define an expectation
        let expectation = self.expectation(description: "Alamofire send BC.Balance request and handle respnse using the callback closure")
        let request = Alamofire.request("https://api.blockcypher.com/v1/btc/test3/addrs/\(adress)/balance")
        request.validate()
        request.responseJSON { response in
                    XCTAssert(response.result.isSuccess, "Error reqursting balance \(response.result.error)")
                    guard let jsonResp = response.result.value as? [String: AnyObject] else {
                        XCTFail("Balance is not a JSON Type")
                        return
                    }
                        
                    let bal = Balance(json: jsonResp)
                    XCTAssertNotNil(bal, "Error initializing object")
                    
                    XCTAssert(bal!.final_balance != nil, "Balance is nil")
                    print(bal!.final_balance)
            
                    //Exercise the asynchronous code
                    expectation.fulfill()
                }
        
        let timeout = request.task?.originalRequest?.timeoutInterval
        //Wait for the expectation to be fulfilled
        waitForExpectations(timeout: timeout!, handler: { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        })
    }
    
    // FIXME: Test for data validation in PKViewController
    func testBrkeyAdressValidation(){
        //initialize etalon private key
        
        //create brkey
        // compare
    }
    
    func testBrKeyAdressFromPK(){
        let pk = "92eByNE4NdnfpK31XV2o1iD9Bir6eLASeyDqq46YzkogTBb3HZH"
        let testNet = true
        let addressToValidate = "moVeRgCBbJj1w7nhzzoSCffVJTpwH8N8SH"
        let key : BRKey = BRKey(privateKey: pk, testnet: testNet)!
        print("public key \(key.publicKey)\n address \(key.address) \n private_key_wif \(key.privateKey)")
        XCTAssert(key.address == addressToValidate, "Addresses is not match!")
        XCTAssert(key.privateKey == pk, "Pks is not match!")
    }
    
    func testGetFullAdressFunction() {
        //let address = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        let parameters = [
            "includeScript" : true,
            "unspentOnly" : true
        ]

        let testnet = true
        let addressAlwayaWorkable = "moVeRgCBbJj1w7nhzzoSCffVJTpwH8N8SH"
        //let addressAlwayaWorkable = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        
        let expectation = self.expectation(description: "Alamofire send BC.Balance request and handle response using the callback")
        var address : Address!
        
        BlockCypherApi.getAddress(address: addressAlwayaWorkable, testnet: testnet, parameters: parameters as [String : AnyObject]?,  doAfterRequest: {json in
            if let t_address = Address(json: json){
                XCTAssertNotNil(t_address, "Bad response from Api")
                address = t_address
            }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: self.defaultTimeOut, handler: { error in
            if let error = error{
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            print(address)
        })
    }
    
    func testBRTransactionCreateAndPush(){
        let testnet = true
        let privateKey : String = "92eByNE4NdnfpK31XV2o1iD9Bir6eLASeyDqq46YzkogTBb3HZH"
        let brkey : BRKey = BRKey(privateKey: privateKey, testnet: testnet)!
        
        //Tx variables
        let selfAddress = brkey.address //moVeRgCBbJj1w7nhzzoSCffVJTpwH8N8SH
        let sendAddress = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        // mhmhRnN58ki9zbRJ63mpNGQXoYvdMXZsXt
        
        let f_inputHashes : [String] = ["7448e23df0078c53138871d36eb9e120b157c3c7d86661d264fe264c056a6246"]
        let f_inputIndexes : [Int] = [0] // UInt64 in modelMapping
        let f_inputScripts : [String] = ["76a9145781aca39c743a68b97e5f35cee622be3e60a20188ac"]
        let f_outPutAddresses : [String] = [ selfAddress! , selfAddress! ]
    
        //Fee shit
        let outputValue = 100000
        let amount = 50000
        //This is simplest way to determine size of transaction
        let size_in_bytes : Int = 180 * f_inputScripts.count + 34 * f_outPutAddresses.count + 10
        let fee_miner = size_in_bytes * fastestFee
        let fee_yourself = outputValue - amount - fee_miner
        let f_amount : [Int] = [amount, fee_yourself ]
        
        //Create your own transaction
        let tx = BRTransaction( inputHashes: f_inputHashes  ,
                                inputIndexes: f_inputIndexes as [NSNumber]! ,
                                inputScripts: f_inputScripts ,
                                outputAddresses: f_outPutAddresses ,
                                outputAmounts: f_amount as [NSNumber]! ,
                                isTesnet: testnet )
        tx?.sign(withPrivateKeys: [privateKey])
        let txRawDataStr : String = tx!.getRawTxDataStr()
        self.rawDataTransaction = txRawDataStr
        if (nil != self.rawDataTransaction){
//            self.testPushRawTx()
        }
    }
    
    func testDecodeRawTx(){
        //Rest api variables
        let txRawData = "010000000146626a054c26fe64d26166d8c7c357b120e1b96ed3718813538c07f03de24874010000008b4830450221009d967b020d735cbb09f7a1ba1749d3567c20149adb6220c6ae749038b7d32b2a022032ef09cc0f323d46eb2ddaa1685d9fe482626f985112de21671249d51d9604870141041160ff19a135938a82e177784744af3901914e4a253e8694e154f603d2eab3b0e2f4c7ffb649ae424570c2802762b475a3692f4341dcb3cd9e1d1956ef3828dcffffffff02aa860100000000001976a9145781aca39c743a68b97e5f35cee622be3e60a20188ac363c1e01000000001976a9145781aca39c743a68b97e5f35cee622be3e60a20188ac00000000"
                    
        let expectation = self.expectation(description: "Alamofire send raw tx check request")
        let parameters = ["tx" : txRawData as Any ]
        let request = Alamofire.request("https://api.blockcypher.com/v1/btc/test3/txs/decode?", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
        request.validate()
        request.responseJSON(completionHandler: { response in
            //XCTAssert(response.result.isSuccess , "Error with response \(response.result.error)")
            guard let jsonResponse = response.result.value as? [String : AnyObject] else {
                XCTFail("Json is not valid type")
                return
            }
            let tx = Tx(json: jsonResponse)
            XCTAssert(nil != tx?.outputs, "Tx outputs equals nil")            
            //Exercise the asynchronous code
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: self.defaultTimeOut, handler: { error in
            if let error = error{
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        })
    }
    
    func testGetFeeData(){
        let expectation = self.expectation(description: "Alamofire gets Fee Data")
        BlockCypherApi.getFeeData(doWithJson: {json in
            guard let fee : Fee = Fee(json: json) else{
                XCTFail("Wrong FeeData")
                return
            }
            
            XCTAssert( (fee.fastestFee != 0 ) || ( nil != fee.fastestFee )  , "FastestFee can not be nil or 0!" )
            XCTAssert( (fee.halfHourFee != 0 ) || ( nil != fee.fastestFee )  , "HalfHourFee can not be nil or 0!" )
            XCTAssert( (fee.hourFee != 0 ) || ( nil != fee.fastestFee )  , "HourFee can not be nil or 0!" )
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: self.defaultTimeOut, handler: { error in
            if let error = error{
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        })
    }
    
//    func testPushRawTx(){
//        //This test doesnt return full error message
//        let expectation = expectationWithDescription("Alamofire push raw tx to block cypher")
//        let requestStr = "https://api.blockcypher.com/v1/btc/test3/txs/push"
//        let txRawData = ( nil != self.rawDataTransaction ) ? self.rawDataTransaction! : ""
//        let parameters = ["tx" : txRawData ]
//        let request = Alamofire.request(.POST, requestStr, parameters: parameters , encoding: .JSON)
//        request.validate()
//        request.responseJSON(completionHandler: {response in
//            //XCTAssert(response.result.isFailure, "Failed to push raw Transaction \(response.result.error?.localizedDescription)")
//            
//            guard let jsonResp = response.result.value as? [String : AnyObject] else
//            {
//                XCTFail("Wrong json data \(response.result.error?.localizedDescription)")
//                return
//            }
//            
//            let tx: PushTxResponse = PushTxResponse(json: jsonResp)!
//            expectation.fulfill()
//        })
//        
//        waitForExpectationsWithTimeout(defaultTimeOut, handler: { error in
//            if let error = error{
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//        })
//    }
    
}
