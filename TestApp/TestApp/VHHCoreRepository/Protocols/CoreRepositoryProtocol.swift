//
//  CoreRepositoryProtocol.swift
//  VHHCoreRepository
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation
import CoreData


enum fetchRequestReturnType{
    case failure(NSError)
    case success(NSFetchRequest)
}

enum repositoryDataReturnType{
    case failure(NSError)
    case success([AnyObject])
}


protocol CoreRepositoryProtocol: class, NSManagedObjectQueryProtocol{

    init(backingstore: BackingstoreProtocol)
    
    var managedObjectContext: NSManagedObjectContext? {get}
    func resetRepository() -> Bool
    func deleteRepository() -> Bool
    func openRepository() -> Bool
    func closeRepository() -> Bool
    var delegate:CoreRepositoryDelegate?{get set}
    func currentState() -> String?
    var repositoryDescription: String{get}
    var lastErrors: [NSError]?{get}

    

}