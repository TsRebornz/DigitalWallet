import XCTest
import Alamofire
import Foundation


@testable import MyProject

class MyProjectTests: XCTestCase {
    
    let defaultTimeOut: NSTimeInterval = 60
    
    let base58TestArr : Array = ["O000000000000000000","l0000000","&*^$&*^$&*^$&*^$&*^$&*^$&*^$","asd;lfj falksdjflj  dslkjflkasj flksdajflj ", "" ]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        let expectation = expectationWithDescription("Alamofire send BC.Balance request and handle respnse using the callback closure")
        let request = Alamofire.request(.GET, "https://api.blockcypher.com/v1/btc/test3/addrs/\(adress)/balance", parameters: nil)
        request.validate()
        request.responseJSON { response in
                    XCTAssert(response.result.isSuccess, "Error reqursting balance \(response.result.error)")
                    guard let jsonResp = response.result.value as? [String: AnyObject] else {
                        XCTFail("Balance is not a JSON Type")
                        return
                    }
                        
                    let bal = Balance(json: jsonResp)
                    XCTAssertNotNil(bal, "Error initializing object")
                    
                    XCTAssert(bal!.final_balance == 126132857, "Balance not match bal = \(bal!.final_balance)")
                    print(bal!.final_balance)
            
                    //Exercise the asynchronous code
                    expectation.fulfill()
                }
        
        let timeout = request.task.originalRequest?.timeoutInterval
        //Wait for the expectation to be fulfilled
        waitForExpectationsWithTimeout(timeout!, handler: { error in
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
        let pk = "cSF9RngdtVNaKpbsH6eBgWGm8xFNc3ViRXgZpfQddQxaGe2G4uXJ"
        let testNet = true
        let addressToValidate = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        let key : BRKey = BRKey(privateKey: pk, testnet: testNet)!
        XCTAssert(key.address == addressToValidate, "Addresses is not match!")
    }
    
    func testGetFullAdressFunction() {
        //let address = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        let parameters = [
            "includeScript" : true,
            "unspentOnly" : true
        ]

        let testnet = false
        let addressAlwayaWorkable = "1DEP8i3QJCsomS4BSMY2RpU1upv62aGvhD"
        
        
        let expectation = expectationWithDescription("Alamofire send BC.Balance request and handle respnse using the callback")
        var address : Address!
        var f_inputHashes = [AnyObject]()
        var f_inputIndexes = [Any]()
        var f_inputScripts = [AnyObject]()
        
        BlockCypherApi.getAddress(addressAlwayaWorkable, testnet: testnet, parameters: parameters,  doAfterRequest: {json in
            if let t_address = Address(json: json){
                XCTAssertNotNil(t_address, "Bad response from Api")
                address = t_address
            }
            
            for tx_ref in address.txsrefs! {
                //TODO: add validation for nill
                //create input hashes
                f_inputHashes.append( tx_ref.tx_hash! as AnyObject )
                //create inputIndexes
                f_inputIndexes.append( tx_ref.tx_output_n as Any )
                //create inputScripts
                f_inputScripts.append( tx_ref.script! as AnyObject )
            }
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(self.defaultTimeOut, handler: { error in
            if let error = error{
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        })
    }
    
    func testBRTransactionContstructor(){
        //Tx variables
        let testnet = true
        let f_inputHashes : [String] = ["c085e8091cbf24f5aff0571c4becb97d1b7232edfebbcde29e45101a48738b31"]
        let f_inputIndexes : [Int] = [1] // UInt64 in modelMapping
        let f_inputScripts : [String] = ["76a914cf9a336b502919ef652619166a89912a967bfc5588ac"]
        let f_amount : [Int] = [1500]
        let f_outPutAddresses : [String] = ["mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"]
        
      //                                    mhmhRnN58ki9zbRJ63mpNGQXoYvdMXZsXt
        //Private Key in WIF Format
        let privateKeys : [String] = ["cSF9RngdtVNaKpbsH6eBgWGm8xFNc3ViRXgZpfQddQxaGe2G4uXJ"]
        
        //Create your own transaction
        let tx = BRTransaction( inputHashes: f_inputHashes  ,
                                inputIndexes: f_inputIndexes ,
                                inputScripts: f_inputScripts ,
                                outputAddresses: f_outPutAddresses ,
                                outputAmounts: f_amount ,
                                isTesnet: testnet )
        tx.signWithPrivateKeys(privateKeys)
        let txRawData : String = tx.getRawTxDataStr()
    }
    
    func testRawTx(){
        //Rest api variables
        let txRawData = "0100000001318b73481a10459ee2cdbbfeed32721b7db9ec4b1c57f0aff524bf1c09e885c0010000006a4730440220442278bfe049748da56411b7f4186a12e602565f05df2dbd634f042e01ee6bc50220536feeffe451e5419c1fe62cc80c99fa3c634fc546ee5632634652f673cc24b10121026a8412a1d7088b69062c46267eb2830a2f1ec6fd8d85c4a174e0a8e036507d77ffffffff01dc050000000000001976a914cf9a336b502919ef652619166a89912a967bfc5588ac00000000"
        
        let expectation = expectationWithDescription("Alamofire send raw tx check request")
        let parameters = ["tx" : txRawData ]
        let request = Alamofire.request(.POST, "https://api.blockcypher.com/v1/btc/test3/txs/decode?", parameters: parameters, encoding: .JSON )
        request.validate()
        request.responseJSON(completionHandler: { response in
            XCTAssert(response.result.isSuccess , "Error with response \(response.result.error)")
            guard let jsonResponse = response.result.value as? [String : AnyObject] else {
                XCTFail("Json is not valid type")
                return
            }
            let tx = Tx(json: jsonResponse)
            tx?.description()
            //Exercise the asynchronous code
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(self.defaultTimeOut, handler: { error in
            if let error = error{
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        })
    }
}
