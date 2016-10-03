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
        saveAll()
    }
    
    // Gets all with an specified predicate.
    // Predicates examples:
    // - NSPredicate(format: "name == %@", "Juan Carlos")
    // - NSPredicate(format: "name contains %@", "Juan")
//    func get(withPredicate queryPredicate: NSPredicate) -> [Person]{
//        let fetchRequest = NSFetchRequest(entityName: Person.entityName)
//        
//        fetchRequest.predicate = queryPredicate
//        
//        do {
//            let response = try context.executeFetchRequest(fetchRequest)
//            return response as! [Person]
//            
//        } catch let error as NSError {
//            // failure
//            print(error)
//            return [Person]()
//        }
//    }
    func read(withPredicate queryPridicate: NSPredicate) {
        
    }
    
//    // Gets a person by id
//    func getById(id: NSManagedObjectID) -> Person? {
//        return context.objectWithID(id) as? Person
//    }
    
    // Updates a person
    func update(updatedPerson: Person){
        if let person = getById(updatedPerson.objectID){
            person.name = updatedPerson.name
            person.age = updatedPerson.age
        }
    }
    
    func update() {
        
    }
    
//    // Deletes a person
//    func delete(id: NSManagedObjectID){
//        if let personToDelete = getById(id){
//            context.deleteObject(personToDelete)
//        }
//    }
    
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
