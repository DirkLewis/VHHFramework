//
//  Person.swift
//  TestApp
//
//  Created by Dirk Lewis on 5/11/15.
//  Copyright (c) 2015 VHH. All rights reserved.
//

import Foundation
import CoreData

@objc(Person)
class Person: _Person,CoreRepositoryObjectProtocol {
    
    class func entityName() -> String {
        return "Person"
    }
    
    func printDescription()->String{
        return ("\(self.lName), \(self.fName) - \(self.age)")
    }
    
    func objectId() -> NSManagedObjectID{
        return super.objectID
    }
    
    var repository: CoreRepositoryProtocol{
        return  _Person.repository
    }
    
}