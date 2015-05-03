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
protocol CoreRepositoryProtocol{

    init(backingstore: BackingstoreProtocol)

    func resetRepository() -> Bool
    func deleteRepository() -> Bool
    func openRepository() -> Bool
    func closeRepository() -> Bool
    var delegate:CoreRepositoryDelegate?{get set}
    func currentState() -> String?
    var repositoryDescription: String{get}
    
    
    func fetchRequestForEntityNamed(entityName: String, batchsize:Int) -> fetchRequestReturnType
    func fetchRequestForEntityNamed(entityName: String) -> fetchRequestReturnType
    func resultsForRequestAsync(request:NSFetchRequest)
    func resultsForRequest(request:NSFetchRequest) -> repositoryDataReturnType
    func deleteManagedObject(managedObject:NSManagedObject)
    
    func save() -> Bool
    func saveAsync()
}