//
//  UsingBrKeyTests.swift
//  MyProject
//
//  Created by username on 18/08/16.
//  Copyright © 2016 BCA. All rights reserved.
//
import XCTest
@testable import MyProject



class UsingBrKeyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateCompressedTestNetKey(){
        let wifStandart : String = "cSF9RngdtVNaKpbsH6eBgWGm8xFNc3ViRXgZpfQddQxaGe2G4uXJ"
        let key = BRKey(privateKey: wifStandart, testnet: true)
        
        XCTAssert(key?.privateKey == wifStandart, "Wif not compressed and testnet")
        print("key privateKey \(key?.privateKey) wifStandart \(wifStandart)")
    }
    
    func testCreateUcompressedTestNetKey(){
        let wifStandart : String = "92eByNE4NdnfpK31XV2o1iD9Bir6eLASeyDqq46YzkogTBb3HZH"
        let key = BRKey(privateKey: wifStandart, testnet: true)
        
        XCTAssert(key?.privateKey == wifStandart, "Wif not uncompressed and testnet")
        print("key privateKey \(key?.privateKey) wifStandart \(wifStandart)")
    }
    
    

}
