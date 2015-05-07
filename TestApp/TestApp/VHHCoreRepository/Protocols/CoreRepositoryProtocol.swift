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


protocol CoreRepositoryProtocol: class{

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

    
    func fetchRequestForEntityNamed(entityName: String, batchsize:Int) -> fetchRequestReturnType
    func fetchRequestForEntityNamed(entityName: String) -> fetchRequestReturnType
    func resultsForRequestAsync(request:NSFetchRequest, handler:(repositoryDataReturnType)->())
    func resultsForRequest(request:NSFetchRequest) -> repositoryDataReturnType
    func fetchEntityForEntityIdentifier<T: CoreRepositoryObjectProtocol>(identifier:String) -> T?
    func fetchEntityWithFilter<T: CoreRepositoryObjectProtocol>(filter:(includedElement:AnyObject) -> Bool) -> [T]
    func deleteManagedObject(managedObject:NSManagedObject)
    func createNewEntity<T: CoreRepositoryObjectProtocol>() -> T
    
    func save() -> Bool
    func saveAsync(handler:(NSError?)->())
}