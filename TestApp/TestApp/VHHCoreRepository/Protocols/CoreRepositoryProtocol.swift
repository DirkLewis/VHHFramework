//
//  CoreRepositoryProtocol.swift
//  VHHCoreRepository
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation
import CoreData

enum RepositoryTuple: Int{
    case message = 0
    case object = 1
}

protocol CoreRepositoryProtocol{

    init(backingstore: BackingstoreProtocol)

    func resetRepository() -> Bool
    func deleteRepository() -> Bool
    func openRepository() -> Bool
    func closeRepository() -> Bool
    var delegate:CoreRepositoryDelegate?{get set}
    var currentState: String? {get}
    var repositoryDescription: String{get}
    
    func fetchRequestForEntityNamed(entityName: String, batchsize:Int) -> (NSError?, NSFetchRequest?)
    func fetchRequestForEntityNamed(entityName: String) -> (NSError?, NSFetchRequest?)

    func resultsForRequest(request:NSFetchRequest, error:NSErrorPointer) -> Array<AnyObject>
    func resultsForRequest(request:NSFetchRequest) -> Array<AnyObject>
    func deleteManagedObject(managedObject:NSManagedObject) -> Bool
    func save() -> Bool
    
}