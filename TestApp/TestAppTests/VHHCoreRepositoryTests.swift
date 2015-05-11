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
    
    var openexpectation: XCTestExpectation? = nil
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
    
    func testQueryExtension(){
    
        let repository = TestRepository.createRepository()
        repository.openRepository()
        println("\(repository.repositoryDescription)")
        var person:Person = repository.createNewEntity()
        
        person.fName = "hailey"
        person.lName = "lewis"
        person.age = 11
        person.entityIdentifier = "abc"
        

        
        repository.save()
        
        var address:Address = person.createNewEntity()
        address.street = "2211 vero beach lane"
        address.entityIdentifier    = "abc"
        address.address_person = person
        
        var address2:Address = person.createNewEntity()
        address2.street = "207 N. Christine"
        address2.entityIdentifier = "def"
        
        repository.save()
        
        let address3:Address = person.fetchEntityForEntityIdentifier("def")!
        address3.address_person = person
        repository.save()
        
        repository.closeRepository()
        repository.deleteRepository()
    
    }
    
    func testEntitySpecificRepository(){
    
        Person.repository.openRepository()
        Address.repository.openRepository()
        
        self.createTwoPersons(Person.repository)
        let person:Person = Person.repository.fetchEntityForEntityIdentifier("1")!
        let address:Address = Person.repository.createNewEntity()
        address.street = "101 street"
        address.address_person = person
        person.repository.save()

        person.repository.closeRepository()
        
        let person2:Person = Address.repository.fetchEntityForEntityIdentifier("1")!
        let address2:Address = Address.repository.createNewEntity()
        address2.street = "102 street"
        address2.address_person = person2
        address2.repository.save()
        address2.repository.closeRepository()
        
        address2.repository.deleteRepository()
        
    }
    
    func testbundel(){
        
        let modelName = "TestModel"
        
        let bundle = NSBundle(forClass: VHHCoreRepositoryTests.self)
        println("\(NSBundle.allBundles())")
        
        for modelpath in bundle.pathsForResourcesOfType("momd", inDirectory: nil){
            
            if let pathArray = NSURL.fileURLWithPath(modelpath as! String)?.pathComponents?.filter({ (name) -> Bool in
                return name as! String == "\(modelName).momd"
            }){
                
                let momdURL = NSURL.fileURLWithPath(modelpath as! String)
                println("\(bundle)")
            }
        }
        
    }
    
    func testFetchByEntityIdentifier(){
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        println("\(repository.repositoryDescription)")
        self.createTwoPersons(repository)
        
        let person:Person? = repository.fetchEntityForEntityIdentifier("1")
        
        let fetched:[Person] = repository.fetchEntityWithFilter({($0 as! Person).fName == "dirk"})
        
        let fetchedagain:[Person] = repository.fetchEntityWithFilter(){a in
            return a.fName == "dirk"
        }
        
        XCTAssertTrue(person?.fName == "dirk", "wrong person")
        XCTAssertTrue(fetched.count == 1 && fetched[0].fName == "dirk", "should only be one person")
        XCTAssertTrue(fetchedagain.count == 1, "should only be one person")

        repository.closeRepository()
        repository.deleteRepository()
        
    }
    
    func testAsyncFetch(){
        
        let expectation = self.expectationWithDescription("asyncfetch")
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        
        self.createTwoPersons(repository)
        
        switch repository.fetchRequestForEntityNamed(Person.entityName(), batchsize: 25){
        case let fetchRequestReturnType.success(request):
            repository.resultsForRequestAsync(request, handler: { (dataresult) -> () in
                switch dataresult{
                case let repositoryDataReturnType.success(entities):
                    println("person count: \(entities.count)")
                    XCTAssertTrue(entities.count == 2, "wrong number of persons")
                    if let filtered = (entities.filter({($0 as! Person).fName == "donna"}).first) as? Person{
                        XCTAssertTrue(filtered.age == 50, "failed update")
                        println("\(filtered.printDescription())")
                    }
                    
                    repository.closeRepository()
                    repository.deleteRepository()
                    expectation.fulfill()
                case let repositoryDataReturnType.failure(error):
                    println("Error: \(error.description)")
                }
            })
    
        case let fetchRequestReturnType.failure(error):
            println("Error: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: { (error) -> Void in
            println("wait fullfilled")
        })
    }
    
    func testDelegateOpen(){
        
        self.openexpectation = self.expectationWithDescription("open")
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        repository.closeRepository()
        repository.deleteRepository()
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
        
        self.createPersonWithAddress(repository)
        
        switch repository.fetchRequestForEntityNamed(Person.entityName()){
        case let fetchRequestReturnType.success(request):
            switch repository.resultsForRequest(request){
            case let repositoryDataReturnType.success(entities):
                println("person count: \(entities.count)")
                XCTAssertTrue(entities.count == 1, "wrong number of persons")
                if let filtered = (entities.filter({($0 as! Person).fName == "dirk"}).first) as? Person{
                    let address = filtered.person_address.first
                    XCTAssertTrue(address?.street == "101 first", "wrong address found")
                    println("\(filtered.printDescription())")
                }
                
            case let repositoryDataReturnType.failure(error):
                println("Error: \(error.description)")
                
            }
        case let fetchRequestReturnType.failure(error):
            println("Error: \(error.localizedDescription)")
        }
        
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
        repository.managedObjectContext!.performBlock { () -> Void in
            self.createTwoPersons(repository)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        switch repository.fetchRequestForEntityNamed(Person.entityName(), batchsize: 25){
        case let fetchRequestReturnType.success(request):
            switch repository.resultsForRequest(request){
            case let repositoryDataReturnType.success(entities):
                println("person count: \(entities.count)")
                XCTAssertTrue(entities.count == 2, "wrong number of persons")
                if let filtered = (entities.filter({($0 as! Person).fName == "donna"}).first) as? Person{
                    XCTAssertTrue(filtered.age == 50, "failed update")
                    println("\(filtered.printDescription())")
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
        
        repository.closeRepository()
        repository.deleteRepository()
        
    }
    
    func testStateMachine(){
        
        let bs = SqliteBackingstore(modelName: "TestModel")
        let repository = CoreRepository(backingstore: bs)
        repository.delegate = self
        XCTAssertTrue(repository.openRepository(), "failed to open backingstore")
        XCTAssertFalse(repository.deleteRepository(), "should return false")
        repository.closeRepository()
        repository.deleteRepository()
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
        var person:Person = repository.createNewEntity()
        
        person.fName = "dirk"
        person.lName = "Lewis"
        person.age = 50
        person.entityIdentifier = "1"
        person = repository.createNewEntity()
        
        person.fName = "donna"
        person.lName = "Lewis"
        person.age = 50
        person.entityIdentifier = "2"
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
        
        let person:Person = repository.createNewEntity()
        
        person.fName = "dirk"
        person.lName = "Lewis"
        person.age = 50
        person.entityIdentifier = "1"
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
    
    func repositoryErrorEmmited(error: NSError) {
        println("Error: \(error.localizedDescription)")
    }
    
    func repositorySaveResults(results: Bool) {
        println("Save was: \(results)")
    }
    
    func repositoryOpened(context: NSManagedObjectContext?) {
        println("moc: \(context)")
        self.openexpectation?.fulfill()
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
    
    // MARK: - Data Creation Helpers
    
    func fetchAPerson(repository:CoreRepository) -> AnyObject?{
    
        switch repository.fetchRequestForEntityNamed(Person.entityName()){
        case let fetchRequestReturnType.success(request):
            switch repository.resultsForRequest(request){
            case let repositoryDataReturnType.success(results):
                if results.count > 0{
                    
                    var x: AnyObject = results.first!
                    
                    println("")
                    return x
                }
            case let repositoryDataReturnType.failure(error):
                println("Error: \(error.localizedDescription)")
            }
        case let fetchRequestReturnType.failure(error):
            println("Error: \(error.localizedDescription)")
            
        }
        return nil
    }
    
    func createPersonWithAddress(repository:CoreRepository){
    
        let person:Person = repository.createNewEntity()
        person.fName = "dirk"
        person.lName = "lewis"
        person.age = 50
        person.entityIdentifier = "1"
        
        let address:Address = repository.createNewEntity()
        address.street = "101 first"
        address.city = "Home Town"
        address.address_person = person
        address.entityIdentifier = "1"
        
        repository.save()
        
    }
    
    func createTwoPersons(repository:CoreRepositoryProtocol){
        var person: Person
        
        person = repository.createNewEntity()
        person.entityIdentifier = "1"
        person.age = 50
        person.fName = "dirk"
        person.lName = "Lewis"
        person = repository.createNewEntity()
        person.entityIdentifier = "2"
        person.fName = "donna"
        person.lName = "Lewis"
        person.age = 50
        
        repository.save()
    }
}
