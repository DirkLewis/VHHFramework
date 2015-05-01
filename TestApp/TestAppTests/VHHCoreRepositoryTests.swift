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
import Foundation

class VHHCoreRepositoryTests: XCTestCase, CoreRepositoryDelegate {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFetchRequestFetchEntitiesThreaded(){
        
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        
        if (((repository.stateMachine?.isInState(kOpenedRepositoryState)) == true)){
            let description = repository.repositoryDescription
            println("\(description)")
        }
        
        var person = Person.insertInManagedObjectContext(repository.childManagedObjectContext())
        
        person.fName = "dirk"
        person.lName = "Lewis"
        person.age = 50
        
        person = Person.insertInManagedObjectContext(repository.childManagedObjectContext())
        
        person.fName = "donna"
        person.lName = "Lewis"
        person.age = 50
        
        repository.childManagedObjectContext().save(nil)
        
        let result = repository.fetchRequestForEntityNamed(Person.entityName(), batchsize: 25)
        let entities = repository.resultsForRequest(result.1!)
        println("person count: \(entities.count)")
        repository.closeRepository()
        repository.deleteRepository()
    }
    
    func testCurrentState(){
    
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        XCTAssertTrue(repository.stateMachine?.isInState(repository.currentState()!) == true, "wrong state")
        XCTAssertTrue(repository.closeRepository(), "failed to close repository")
        XCTAssertTrue(repository.stateMachine?.isInState(repository.currentState()!) == true, "wrong state")
        XCTAssertTrue(repository.deleteRepository(), "failed to delete repository")
        XCTAssertTrue(repository.stateMachine?.isInState(repository.currentState()!) == true, "wrong state")
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        XCTAssertTrue(repository.stateMachine?.isInState(repository.currentState()!) == true, "wrong state")
    }
    
    func testStateMachine(){
    
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        XCTAssertFalse(repository.deleteRepository(), "should return false")
    }
    
    func testFetchRequestFetchEntities(){
    
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
       
        if (((repository.stateMachine?.isInState(kOpenedRepositoryState)) == true)){
            let description = repository.repositoryDescription
            println("\(description)")
        }
        var person = Person.insertInManagedObjectContext(repository.managedObjectContext)
        
        person.fName = "dirk"
        person.lName = "Lewis"
        person.age = 50
        
        person = Person.insertInManagedObjectContext(repository.managedObjectContext)
        
        person.fName = "donna"
        person.lName = "Lewis"
        person.age = 50
        
        repository.managedObjectContext?.save(nil)
        
        let result = repository.fetchRequestForEntityNamed(Person.entityName(), batchsize: 25)
        let entities = repository.resultsForRequest(result.1!)
        println("person count: \(entities.count)")
        repository.closeRepository()
        repository.deleteRepository()
    }
    
    func testCreateFetchRequestForSuccess(){
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        let result = repository.fetchRequestForEntityNamed(Person.entityName(), batchsize: 25)
        XCTAssertTrue(result.0 == nil, "There was an error")
        XCTAssertTrue(result.1 != nil, "There should be a FetchRequest")

    }
    
    func testCreateFetchRequestForFail(){
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        repository.closeRepository()
        let result = repository.fetchRequestForEntityNamed(Person.entityName())
        XCTAssertTrue(result.0 != nil, "There should have been and error")
        let message = (result.0?.userInfo?["message"] as! String)

        XCTAssertTrue(message == "Repository is closed, please open.", "There should have been and error")
    }
    
    func testInsertingNewEntityIntoRepository(){
    
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")

        let person = Person.insertInManagedObjectContext(repository.managedObjectContext)
        
        person.fName = "dirk"
        person.lName = "Lewis"
        person.age = 50

        repository.managedObjectContext?.save(nil)
        
        if (((repository.stateMachine?.isInState(kOpenedRepositoryState)) == true)){
            let description = repository.repositoryDescription
            println("\(description)")
        }
        
        repository.closeRepository()
        repository.deleteRepository()

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
        let opened = repository.openRepository()
        let deleted = repository.closeRepository()
        if (((repository.stateMachine?.isInState(kOpenedRepositoryState)) == true)){
            let description = repository.repositoryDescription
            println("\(description)")
        }


        XCTAssertTrue(repository.deleteRepository(), "Should return true")
    }
    
    func testRepositoryReset(){
        let bs = SqliteBackingstore(modelName: "TestModel")

        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        let opened = repository.openRepository()
        if (((repository.stateMachine?.isInState(kOpenedRepositoryState)) == true)){
            let description = repository.repositoryDescription
            println("\(description)")
        }
        XCTAssertTrue(repository.closeRepository(), "Should return true")
        XCTAssertTrue(repository.resetRepository(), "Should return true")
    }
    
    func testRepositoryDeleteNotOpen(){
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        if (((repository.stateMachine?.isInState(kOpenedRepositoryState)) == true)){
            let description = repository.repositoryDescription
            println("\(description)")
        }
        
        XCTAssertTrue(repository.deleteRepository(), "Should return true")
    }
    
    // MARK: - delgate methods
    
    func repositoryErrorGenerated(error: NSError) {
        println("\n\n\n\(error.description)\n\n")
    }
    
    func repositoryOpened(context: NSManagedObjectContext?) {
        println("moc: \(context)")
    }
    
    func repositoryClosed() {
        println("repository closed")
    }
    
    func repositoryReset() {
        println("repository reset")
    }
    
    func repositoryDeleted() {
        println("repository deleted")
    }
    
    func backingstoreErrorGenerated(error: NSError) {
        println("error: \(error)")
    }
}
