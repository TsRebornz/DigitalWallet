//
//  DataValidationTests.swift
//  MyProject
//
//  Created by username on 16/08/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import XCTest
@testable import MyProject

class DataValidationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsUserPKIsBase58orBase64(){
        //let pat = PKBase58and64hexRule.regex
        let pat = "([[1-9A-Za-z]--[OIl]]{52})|([0-9a-f]){64}"
        let testUserInputs = ["cSF9RngdtVNaKpbsH6eBgWGm8xFNc3ViRXgZpfQddQxaGe2G4uXJ", "8b207b41291057701bcf4a6d6622fb1dfff77c0fef2f56875a80c0a3317a8111"]
        let testPassCount : Int = testUserInputs.count
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        var matchArr : [NSTextCheckingResult] = [NSTextCheckingResult]()
        for usetInput in testUserInputs{
            let matches = regex.matchesInString(usetInput, options: [], range: NSRange(location: 0, length: usetInput.characters.count))
            matchArr += matches
        }
        
        print("Matches count \(matchArr.count)")
        XCTAssert(matchArr.count == testPassCount, "Validation failed!")
    }    
    
    func testCheckCompressedWIFFormatTestNet(){
        let  wifCompressedStandart = "cSF9RngdtVNaKpbsH6eBgWGm8xFNc3ViRXgZpfQddQxaGe2G4uXJ"
        
        let result:WifFormat = BRKey.checkWIFformatPKkey(wifCompressedStandart)
        
        XCTAssert( result == WifCompressedTestNet , "Incorrect WIF Compressed pkFormat" )
    }
    
    func testCheckUnCompressedWIFFormatTestNet(){
        let wifStandart = "92eByNE4NdnfpK31XV2o1iD9Bir6eLASeyDqq46YzkogTBb3HZH"
        let result: WifFormat = BRKey.checkWIFformatPKkey(wifStandart)
        
        XCTAssert(result == WifTestNet , "Incorrect WIF uncompressed pkFormat")
    }
    
}
