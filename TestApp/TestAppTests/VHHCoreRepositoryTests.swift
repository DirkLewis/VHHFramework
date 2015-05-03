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
    
    func testPersonAddress(){
        
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        
        if (((repository.stateMachine?.isInState(kOpenedRepositoryState)) == true)){
            let description = repository.repositoryDescription
            println("\(description)")
        }
        
        let person = Person.insertInManagedObjectContext(repository.managedObjectContext)
        person.fName = "dirk"
        person.lName = "lewis"
        person.age = 50
        
        let address = Address.insertInManagedObjectContext(repository.managedObjectContext)
        address.street = "101 first"
        address.city = "Home Town"
        address.address_person = person
        
        repository.managedObjectContext?.save(nil)
        
        repository.closeRepository()
        repository.deleteRepository()
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
        
        let expectation = self.expectationWithDescription("context threading")
        var person: Person? = nil
        repository.managedObjectContext!.performBlock { () -> Void in
            person = Person.insertInManagedObjectContext(repository.managedObjectContext)
            
            person!.fName = "dirk"
            person!.lName = "Lewis"
            person!.age = 50
            person = Person.insertInManagedObjectContext(repository.managedObjectContext)
            person!.fName = "donna"
            person!.lName = "Lewis"
            person!.age = 50
            repository.managedObjectContext!.save(nil)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        person!.age = 60
        repository.managedObjectContext!.reset()
        switch repository.fetchRequestForEntityNamed(Person.entityName(), batchsize: 25){
        case let fetchRequestReturnType.success(request):
            switch repository.resultsForRequest(request){
                case let repositoryDataReturnType.success(entities):
                    println("person count: \(entities.count)")
                    XCTAssertTrue(entities.count == 2, "wrong number of persons")
                    if let filtered:AnyObject = (entities.filter(){ $0.fName == "donna"}.first){
                        XCTAssertTrue(filtered.age == 50, "failed update")
                        println("\(filtered.personDescription())")
                    }
                case let repositoryDataReturnType.failure(error):
                    println("Error: \(error.description)")
                
            }
            

        case let fetchRequestReturnType.failure(error):
            println("Error: \(error.description)")
        }
        
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
        
        switch repository.fetchRequestForEntityNamed(Person.entityName(), batchsize: 25){
        case let fetchRequestReturnType.success(request):
            switch repository.resultsForRequest(request){
            case let repositoryDataReturnType.success(entities):
                println("person count: \(entities.count)")
                
            case let repositoryDataReturnType.failure(error):
                println("Error: \(error.description)")
            }
        case let fetchRequestReturnType.failure(error):
            println("Error: \(error.description)")
            
            
        }
        
        repository.closeRepository()
        repository.deleteRepository()
    }
    
    func testCreateFetchRequestForSuccess(){
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        switch repository.fetchRequestForEntityNamed(Person.entityName(), batchsize: 25){
        case let fetchRequestReturnType.success(request):
            XCTAssertTrue(true, "should have been a success")
            
        case let fetchRequestReturnType.failure(error):
            XCTAssertTrue(false, "should not have failed")
            println("Error: \(error.description)")
        }
        
    }
    
    func testCreateFetchRequestForFail(){
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        repository.closeRepository()
        switch repository.fetchRequestForEntityNamed(Person.entityName()){
        case let fetchRequestReturnType.success(result):
            XCTAssertTrue(false, "should not have suceeded.")
        case let fetchRequestReturnType.failure(error):
            XCTAssertTrue(true, "There should have been and error")
            XCTAssertTrue((error.userInfo?["message"] as! String) == "Repository is closed, please open.", "There should have been and error")
            
        }
        
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
        bs.resetPersistentStoreCoordiator(true)
        
    }
    
    func testBackingstoreConfigNameInitialization(){
        
        let bs = SqliteBackingstore(modelName: "TestModel", fileName: "MyFile", configurationName:"System")
        let description = bs.backingstoreDescription
        XCTAssertFalse(description.isEmpty, "should have a data")
        println("\(description)")
        bs.resetPersistentStoreCoordiator(true)
        
    }
    
    func testBackingstoreCreateManageObjectContext(){
        
        let bs = SqliteBackingstore(modelName: "TestModel")
        let moc = bs.managedObjectContext
        let description = bs.backingstoreDescription
        XCTAssertFalse(description.isEmpty, "should have a data")
        println("\(description)")
        bs.resetPersistentStoreCoordiator(true)
        
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
    func repositorySaveResults(results: Bool) {
        println("Save was: \(results)")
    }
    func repositoryFetchResults(results: [AnyObject]) {
        println("\(results)")
    }
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
