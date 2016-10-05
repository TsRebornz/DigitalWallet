//
//  UsingCoreData.swift
//  MyProject
//
//  Created by username on 04/10/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import XCTest
import CoreData
@testable import MyProject

class UsingCoreData: TestBase {
    
    var moc : NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
        //moc = MPCoreDataManager.sharedInstance.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCRUD() {
        let currencyModel = createTestCurrencyPrice()
        currencyModel.rate = 605.54
        MPCoreDataManager.sharedInstance.createAndInsertObjectBy(entityName: MPCurrencyRate.entityName, model: currencyModel)
        MPCoreDataManager.sharedInstance.saveAll()
        var objects : [NSManagedObject]? = MPCoreDataManager.sharedInstance.getObjects(byEntity: MPCurrencyRate.entityName, withPredicate: NSPredicate(format: "code = %s", "USD") )
        let testObj = objects?[0] as! MPCurrencyRate?
        XCTAssert(testObj != nil && testObj?.code == "USD" && testObj?.name == "US Dollar" && testObj?.rate == 605.54, "Object not created")
        MPCoreDataManager.sharedInstance.delete(byId: (testObj?.objectID)!)
        MPCoreDataManager.sharedInstance.saveAll()
    }
    
    func testExample() {
    
    }
    
}
