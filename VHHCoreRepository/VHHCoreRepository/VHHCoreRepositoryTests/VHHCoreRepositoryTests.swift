//
//  VHHCoreRepositoryTests.swift
//  VHHCoreRepositoryTests
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class VHHCoreRepositoryTests: XCTestCase, CoreRepositoryDelegate {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testBackingstoreModelNameInitialization(){
    
        let bs = SqliteBackingstore(modelName: "TestModel")
        let description = bs.backingstoreDescription
        XCTAssertFalse(description.isEmpty, "should have a data")

        println("\(description)")
        
    }
    
    func testBackingstoreFileNameInitialization(){
        
        let bs = SqliteBackingstore(modelName: "TestModel", fileName: "MyFile")
        let description = bs.backingstoreDescription
        XCTAssertFalse(description.isEmpty, "should have a data")

        println("\(description)")
        
    }
    
    func testBackingstoreConfigNameInitialization(){
        
        let bs = SqliteBackingstore(modelName: "TestModel", fileName: "MyFile", configurationName:"System")
        let description = bs.backingstoreDescription
        XCTAssertFalse(description.isEmpty, "should have a data")

        println("\(description)")
        
    }
    
    func testBackingstoreCreateManageObjectContext(){
    
        let bs = SqliteBackingstore(modelName: "TestModel")
        let moc = bs.managedObjectContext
        let description = bs.backingstoreDescription

        XCTAssertFalse(description.isEmpty, "should have a data")
        println("\(description)")
    }
    
    func testRepositoryDelete(){
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        let opened = repository.openBackingstore()
        let deleted = repository.closeBackingstore()
        if (((repository.stateMachine?.isInState(kOpenedRepositoryState)) == true)){
            let description = repository.repositoryDescription
            println("\(description)")
        }


        XCTAssertTrue(repository.deleteBackingstore(), "Should return true")
    }
    
    func testRepositoryReset(){
        let bs = SqliteBackingstore(modelName: "TestModel")

        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        let opened = repository.openBackingstore()
        if (((repository.stateMachine?.isInState(kOpenedRepositoryState)) == true)){
            let description = repository.repositoryDescription
            println("\(description)")
        }
        
        XCTAssertTrue(repository.resetBackingstore(), "Should return true")
    }
    
    func testRepositoryDeleteNotOpen(){
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        if (((repository.stateMachine?.isInState(kOpenedRepositoryState)) == true)){
            let description = repository.repositoryDescription
            println("\(description)")
        }
        
        XCTAssertTrue(repository.deleteBackingstore(), "Should return true")
    }
    
    // MARK: - delgate methods
    
    func repositoryErrorGenerated(error: NSError) {
        println("error: \(error)")
    }
    
    func repositoryOpened(context: NSManagedObjectContext?) {
        println("moc: \(context)")
    }
    
    func repositoryClosed() {
        println("repository closed")
    }
    
    func repositoryDeleted() {
        println("repository deleted")
    }
    
    func backingstoreErrorGenerated(error: NSError) {
        println("error: \(error)")
    }
}
