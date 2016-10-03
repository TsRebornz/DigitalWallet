//
//  MPCoreDataManager.swift
//  MyProject
//
//  Created by username on 30/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//


import CoreData
import Foundation

public class MPCoreDataManager {
    public enum EntityName: String {
        case currencyRate = "MPCurrencyRate"
        case settings = "MPSettings"
    }
    
    static let modelName: String = "DataModel"
    static let storeName: String = "DataModel.sqlite"
    
    static let sharedInstance = MPCoreDataManager()
    
    let managedObjectContext : NSManagedObjectContext
    
    public init(){
        //CoreData Stack here
        
        //Init
        guard let modelURL = Bundle.main.url(forResource: MPCoreDataManager.modelName, withExtension: "momd") else {
            fatalError("Error MPCoreDataManager can not load model from main bundle")
        }
        
        let mom = NSManagedObjectModel(contentsOf: modelURL )!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        /* StoreTypes for CoreData
         
         NSSQLiteStoreType
         NSXMLStoreType
         NSBinaryStoreType
         NSInMemoryStoreType
         
        */
        
        DispatchQueue.main.async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex - 1]
            let storeUrl : URL = docURL.appendingPathComponent(MPCoreDataManager.storeName)
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)                
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
        
    func create() {
        let currencyRate = NSEntityDescription.insertNewObject(forEntityName: EntityName.currencyRate.rawValue, into: managedObjectContext) as! MPCurrencyRate
        currencyRate.code = "USD"
        currencyRate.name = "American Dollar"
        currencyRate.rate = 605.05
        saveAll()
    }
    
    func read() {
        
    }
    
    func update() {
        
    }
    
    func delete() {
        
    }
    
    func saveAll() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failed to save core data context: \(error)")
        }
    }
    
    
}
