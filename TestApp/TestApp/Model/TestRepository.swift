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
    
    static var instance: CoreRepositoryProtocol!
    
    private class func createRepository() -> CoreRepositoryProtocol{
    
        let bs = SqliteBackingstore(modelName: "TestModel")
        return CoreRepository(backingstore: bs)
        
    }
    
    class func sharedInstance() -> CoreRepositoryProtocol {
        self.instance = (self.instance ?? TestRepository.createRepository())
        return self.instance
    }
}