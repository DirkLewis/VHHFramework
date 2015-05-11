//
//  NSManagedObjectQueryProtocol.swift
//  TestApp
//
//  Created by Dirk Lewis on 5/11/15.
//  Copyright (c) 2015 VHH. All rights reserved.
//

import Foundation
import CoreData

protocol NSManagedObjectQueryProtocol: class{

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