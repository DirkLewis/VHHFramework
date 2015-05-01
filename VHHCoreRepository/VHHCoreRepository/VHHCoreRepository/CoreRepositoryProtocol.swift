//
//  CoreRepositoryProtocol.swift
//  VHHCoreRepository
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation
import CoreData

protocol CoreRepositoryProtocol{

    init(backingstore: BackingstoreProtocol)

    func resetRepository() -> Bool
    func deleteRepository() -> Bool
    func openRepository() -> Bool
    func closeRepository() -> Bool
    var delegate:CoreRepositoryDelegate?{get set}
    var currentState: String? {get}
    var repositoryDescription: String{get}
    
    func insertNewEntityNamed(entityName: String) -> AnyObject?
    func fetchRequestForEntityNamed(entityName: String, batchsize:Int) -> NSFetchRequest?
    func resultsForRequest(NSFetchRequest, error:NSErrorPointer) -> Array<AnyObject>
    func resultsForRequest(NSFetchRequest) -> Array<AnyObject>
    func deleteManagedObject(NSManagedObject) -> Bool
    func save() -> Bool
    
}