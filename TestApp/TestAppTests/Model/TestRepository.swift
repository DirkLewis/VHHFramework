//
//  TestRepository.swift
//  TestApp
//
//  Created by Dirk Lewis on 5/5/15.
//  Copyright (c) 2015 VHH. All rights reserved.
//

import Foundation
import CoreData

class TestRepository {
    
    //private static let _bs = SqliteBackingstore(modelName: "TestModel")
    
    class func createRepository() -> CoreRepositoryProtocol{
        let _bs = SqliteBackingstore(modelName: "TestModel")
        return CoreRepository(backingstore: _bs)
    }
    

}