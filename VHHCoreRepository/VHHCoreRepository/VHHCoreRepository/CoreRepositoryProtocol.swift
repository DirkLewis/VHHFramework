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

    func resetBackingstore() -> Bool
    func deleteBackingstore() -> Bool
    func openBackingstore() -> Bool
    func closeBackingstore() -> Bool
    var delegate:CoreRepositoryDelegate?{get set}
    var currentState: String? {get}
    var repositoryDescription: String{get}
    
    func insertNewEntityNamed(String) -> NSManagedObject
    func fetchRequestForEntityNamed(String, batchsize:Int) -> NSFetchRequest
    func resultsForRequest(NSFetchRequest, error:NSErrorPointer) -> Array<AnyObject>
    func resultsForRequest(NSFetchRequest) -> Array<AnyObject>
}