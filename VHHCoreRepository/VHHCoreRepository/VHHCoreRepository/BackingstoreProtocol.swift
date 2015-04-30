//
//  BackingstoreProtocol.swift
//  VHHCoreRepository
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation
import CoreData

protocol BackingstoreProtocol: AnyObject{

    init(modelName: String, fileName: String?, configurationName: String?)
    var managedObjectContext: NSManagedObjectContext?{get}
    var delegate:BackingstoreDelegate?{get set}
    var backingstoreDescription: String {get}
    func resetPersistentStoreCoordiator(deleteStore: Bool) -> Bool
}