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
//    public enum EntityName: String {
//        case currencyRate = "MPCurrencyRate"
//        case settings = "MPSettings"
//    }
    
    static let modelName: String = "DataModel"
    static let storeName: String = "DataModel.sqlite"
    
    static let sharedInstance = MPCoreDataManager()
    
    let managedObjectContext : NSManagedObjectContext

    //MARK: - Initializers
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
    //Mark: -
    
    //Mark: - CRUD
    //Create object
    func createAndInsertObjectBy(entityName: String , model: NSObject  ) {
        let obj = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext) as! MPCurrencyRate
        switch model {
        case is CurrencyPrice:
            let currencyPrice = model as! CurrencyPrice
            obj.code = currencyPrice.code
            obj.name = currencyPrice.name
            obj.rate = currencyPrice.rate as NSNumber?
        default :
            print("xyu")
        }
    }
    
    // Gets all with an specified predicate.
    // Predicates examples:
    // - NSPredicate(format: "name == %@", "Usd")
    // - NSPredicate(format: "name contains %@", "Euro")
    func read(withPredicate queryPridicate: NSPredicate) -> [MPCurrencyRate] {
        let fetchRequest : NSFetchRequest = NSFetchRequest<MPCurrencyRate>(entityName: MPCurrencyRate.entityName)
        fetchRequest.predicate = queryPridicate
        do {
            let response = try managedObjectContext.fetch(fetchRequest)
            return response 
        } catch {
            print(error)
            return [MPCurrencyRate]()
        }
    }
    
    // Gets a managed object by id
    func getById(id: NSManagedObjectID) -> NSManagedObject? {
        return managedObjectContext.object(with: id) as? NSManagedObject
    }
    
    // Updates a managed object
    func update(object : NSManagedObject, by newModel: NSObject) {
        switch newModel {
        case is CurrencyPrice:
            let cpObj = object as! MPCurrencyRate
            let newCpObj = newModel as! CurrencyPrice
            cpObj.code = newCpObj.code
            cpObj.name = newCpObj.name
            cpObj.rate = newCpObj.rate as NSNumber?
        default:
            break
        }
    }
    
//    // Deletes a person
//    func delete(id: NSManagedObjectID){
//        if let personToDelete = getById(id){
//            context.deleteObject(personToDelete)
//        }
//    }
    
    func delete(byId: NSManagedObjectID) {
        if let objToDelete = getById(id: byId) {
            managedObjectContext.delete(objToDelete)
        }
    }
    
    func saveAll() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failed to save core data context: \(error)")
        }
    }
    
    //MARK: -
    
    
}
