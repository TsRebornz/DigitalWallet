import XCTest
import Alamofire


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
                    XCTAssertNotNil(jsonResp, "Balance is not a JSON Type" )
                        
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
    
    func testGetFullAdressFunction() {
        //let address = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        let parameters = [
            "includeScript" : true,
            "unspentOnly" : true
        ]

        let testnet = false
        let addressAlwayaWorkable = "1DEP8i3QJCsomS4BSMY2RpU1upv62aGvhD"
        let outPutAddress : String = "mzSetpsidLwd2nhwSTeBv8uNVuGQDs3wdY"
        let amount = 1500
        let expectation = expectationWithDescription("Alamofire send BC.Balance request and handle respnse using the callback")
        var address : Address!
        var f_inputHashes : [AnyObject] = []
        var f_inputIndexes : [AnyObject] = []
        var f_inputScripts : [AnyObject] = []
        
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
                f_inputIndexes.append( tx_ref.tx_output_n! as AnyObject )
                //create inputScripts
                f_inputScripts.append( tx_ref.script! as AnyObject )
            }
            //Create your own transaction
            let tx = BRTransaction(inputHashes: f_inputHashes, inputIndexes: f_inputIndexes, inputScripts: f_inputScripts, outputAddresses: [outPutAddress], outputAmounts: [amount])
            //tx.addInputHashStr(f_inputHashes[0], index: f_inputIndexes[0], script: f_inputScripts)
            tx.debugDescription
            tx.description
            
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(self.defaultTimeOut, handler: { error in
            if let error = error{
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        })
    }
}
