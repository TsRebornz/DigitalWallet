//
//  MPCurrencyRate+CoreDataProperties.swift
//  
//
//  Created by username on 15/09/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MPCurrencyRate {

    @NSManaged var code: String?
    @NSManaged var name: String?
    @NSManaged var rate: NSNumber?

}
