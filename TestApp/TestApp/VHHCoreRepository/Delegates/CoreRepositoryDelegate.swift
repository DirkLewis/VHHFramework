//
//  CoreRepositoryDelegate.swift
//  VHHCoreRepository
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation
import CoreData
@objc protocol CoreRepositoryDelegate{

    func repositoryOpened(context: NSManagedObjectContext?)
    func repositoryErrorEmmited(error: NSError)
    optional func repositorySaveResults(results:Bool)
    optional func repositoryClosed()
    optional func repositoryReset()
    optional func repositoryDeleted()

}