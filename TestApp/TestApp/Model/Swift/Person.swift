//
//  Person.swift
//  
//
//  Created by Dirk Lewis on 5/4/15.
//
//

import Foundation
import CoreData

@objc(Person)
class Person: NSManagedObject, CoreRepositoryObjectProtocol{
    
    struct PersonAttributes {
        var age: String
        var fName: String
        var lName: String
        var entityIdentifier: Int64
        
    }
    
    struct PersonRelationships{
        var person_address: String
    }

    @NSManaged var age: Int32
    @NSManaged var fName: String
    @NSManaged var lName: String
    @NSManaged var person_address: Set<Address>
    @NSManaged var entityIdentifier: Int64
    
    class func entityName() -> String {
        return "Person"
    }
    
    func printDescription()->String{
        return ("\(self.lName), \(self.fName) - \(self.age)")
    }
    
    func objectId() -> NSManagedObjectID{
        return super.objectID
    }
    
    
}

