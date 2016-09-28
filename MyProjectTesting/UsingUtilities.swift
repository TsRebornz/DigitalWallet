//
//  UsingUtilities.swift
//  MyProject
//
//  Created by username on 14/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//
import XCTest
import Foundation

@testable import MyProject



open class UsingUtilities : XCTestCase {
    
    let measureFault = 10000
    
    override open func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override open func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConvertionSatoshiToFiat() {
        let rate : Float = 608.01
        let testRate = Utilities.convertSatoshToFiat(satoshi: 100000000, rate: Double(rate) )
        
        XCTAssert(testRate == rate, "Rates doesn't match")
    }
    
    func testConvertionFault(){
        let satoshiBefore : Int = 312312414
        let rate : Float = 608.01
        let toUsd = Utilities.convertSatoshToFiat(satoshi: satoshiBefore, rate: Double(rate) )
        let satoshiAfter = Utilities.convertFiatToSatoshi(fiat: toUsd, rate: Double(rate) )
        let difference = satoshiAfter < satoshiBefore ? satoshiBefore - satoshiAfter : satoshiAfter - satoshiBefore
        XCTAssert( difference < self.measureFault , "Difference after convertion exceed measure falut value" )        
    }
}
