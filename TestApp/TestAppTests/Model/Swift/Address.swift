//
//  Address.swift
//  
//
//  Created by Dirk Lewis on 5/4/15.
//
//

import Foundation
import CoreData

@objc(Address)
class Address: NSManagedObject, CoreRepositoryObjectProtocol {

    static let repository = TestRepository.createRepository()

    @NSManaged var street: String
    @NSManaged var city: String
    @NSManaged var state: String
    @NSManaged var zip: String
    @NSManaged var address_person: Person
    @NSManaged var entityIdentifier: String
    
    struct AddressAttributes {
        var street: String
        var city: String
        var state: String
        var zip: String
        var entityIdentifier: String
        
    }
    
    struct AddressRelationships{
        var address_person: String
    }
    
    class func entityName() -> String {
        return "Address"
    }
    
    func printDescription()->String{
        return ("\(self.state) \(self.city), \(self.state) \(self.zip)")
    }
    
    func objectId() -> NSManagedObjectID{
        return super.objectID
    }
    
    var repository: CoreRepositoryProtocol{
        return  Address.repository
    }

}
