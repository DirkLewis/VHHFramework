//
//  Person.swift
//  
//
//  Created by Dirk Lewis on 5/4/15.
//
//

import Foundation
import CoreData

@objc(_Person)
class _Person: NSManagedObject{
    
    static let repository = TestRepository.createRepository()
    
    struct PersonAttributes {
        var age: String
        var fName: String
        var lName: String
        var entityIdentifier: String
        
    }
    
    struct PersonRelationships{
        var person_address: String
    }

    @NSManaged var age: Int32
    @NSManaged var fName: String
    @NSManaged var lName: String
    @NSManaged var person_address: Set<_Address>
    @NSManaged var entityIdentifier: String
    


}

