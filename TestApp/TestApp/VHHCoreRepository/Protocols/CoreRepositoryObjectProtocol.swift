//
//  CoreRepositoryObjectProtocol.swift
//  VHHCoreRepository
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation
import CoreData

protocol CoreRepositoryObjectProtocol: AnyObject{

    static func entityName() -> String
    func printDescription()-> String
    func objectId() -> NSManagedObjectID
    var entityIdentifier: String {get}
    
    //static var repository: CoreRepositoryProtocol {get}
    var repository: CoreRepositoryProtocol {get}
}