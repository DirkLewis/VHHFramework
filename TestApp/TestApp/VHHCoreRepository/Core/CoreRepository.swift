//
//  CoreRepository.swift
//  VHHCoreRepository
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation
import CoreData

let defaultBatchSize = 25
let repositoryErrorDomain = "com.vhh.corerepository"
let repositoryFailCode = -200



class CoreRepository: CoreRepositoryProtocol, BackingstoreDelegate {
    
    var backingstore: BackingstoreProtocol?
    var managedObjectContext: NSManagedObjectContext?
    var delegate: CoreRepositoryDelegate?
    var stateMachine: StateMachine?
    var lastErrors: [NSError]?
    
    required init(backingstore: BackingstoreProtocol){
        self.backingstore = backingstore
        self.backingstore?.delegate = self
        self.stateMachine = CoreRepositoryFactory.createRepositoryStatemachine()
        self.stateMachine?.startMachine()
        self.lastErrors  = [NSError]()
    }
    
    // MARK: - core data helper methods
    
    // MARK: - helper methods
    
    func lastError() -> NSError?{
    
        return self.lastErrors?.first
    }
    
    private func changeStateForEvent(eventName: String)->Bool{
        
        var error: NSError?
        if let success = self.stateMachine?.changeStateForEvent(eventName, userInfo: ["repository":self], error: &error){
            if let currenterror = error{
                self.lastErrors?.append(currenterror)
                self.delegate?.repositoryErrorEmmited(currenterror)
            }
            else{
                return true
            }
        }
        
        return false
    }
    
    // MARK: - protocol methods
    
    func openRepository() -> Bool {
        return self.changeStateForEvent(kOpenRepositoryEvent)
    }
    
    func closeRepository() -> Bool {
        return self.changeStateForEvent(kCloseRepositoryEvent)
    }
    
    func resetRepository() -> Bool {
        return self.changeStateForEvent(kResetRepositoryEvent)
    }
    
    func deleteRepository() -> Bool {
        return self.changeStateForEvent(kDeleteRepositoryEvent)
    }
    
    lazy var repositoryDescription: String = {
        return self.backingstore!.backingstoreDescription
        }()
    
    func currentState() -> String? {
        return self.stateMachine?.currentStateName()
    }
    
    func fetchRequestForEntityNamed(entityName: String, batchsize:Int) -> fetchRequestReturnType{
        var fetchrequest: NSFetchRequest? = nil
        
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            fetchrequest = NSFetchRequest(entityName: entityName)
            fetchrequest!.fetchBatchSize = batchsize
            
            if let request = fetchrequest{
                return fetchRequestReturnType.success(fetchrequest!)
            }
            else{
                return fetchRequestReturnType.failure(NSError(domain: repositoryErrorDomain, code: repositoryFailCode, userInfo: ["message":"FetchRequest failed initialization."]))
            }
        }
        else{
            return fetchRequestReturnType.failure(NSError(domain: repositoryErrorDomain, code: repositoryFailCode, userInfo: ["message":"Repository is closed, please open."]))
        }
    }
    
    func fetchRequestForEntityNamed(entityName: String) -> fetchRequestReturnType{
        return self.fetchRequestForEntityNamed(entityName, batchsize: defaultBatchSize)
    }
    
    func resultsForRequest(request:NSFetchRequest) -> repositoryDataReturnType{
        var error: NSError? = nil
        var results = [AnyObject]()
        
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            self.managedObjectContext!.performBlockAndWait({ () -> Void in
                results = self.managedObjectContext!.executeFetchRequest(request, error: &error)!
                println("\(results)")
            })
        }
        
        if let currenterror = error{
            return repositoryDataReturnType.failure(currenterror)
        }
        return repositoryDataReturnType.success(results)
    }
    
    func resultsForRequestAsync(request:NSFetchRequest, handler:(repositoryDataReturnType) -> ()){
        var error: NSError? = nil
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            self.managedObjectContext!.performBlock({ () -> Void in
                if let results = self.managedObjectContext!.executeFetchRequest(request, error: &error){
                    if let currenterror = error{
                        handler(repositoryDataReturnType.failure(currenterror))
                    }
                    else{
                        handler(repositoryDataReturnType.success(results))
                    }
                }
            })
        }
    }
    
    func deleteManagedObject(managedObject:NSManagedObject){
        self.managedObjectContext!.performBlock { () -> Void in
            self.deleteManagedObject(managedObject)
        }
    }
    
    func saveAsync(handler:(NSError?)->()) {
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            self.managedObjectContext!.performBlock{ () -> Void in
                var error: NSError? = nil
                self.managedObjectContext!.save(&error)
                handler(error!)
            }
        }
    }
    
    func save() -> Bool{
        var saved: Bool = false
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            self.managedObjectContext!.performBlockAndWait{ () -> Void in
                var error: NSError? = nil
                var saved: Bool = self.managedObjectContext!.save(&error)
                if let currenterror = error{
                    self.delegate?.repositoryErrorEmmited(currenterror)
                    self.lastErrors?.append(currenterror)
                }
            }
        }
        return saved
    }
    
    func createNewEntity<T:CoreRepositoryObjectProtocol>() -> T{
        return NSEntityDescription.insertNewObjectForEntityForName(T.entityName(), inManagedObjectContext: self.managedObjectContext!) as! T
    }
    
    func fetchEntityForEntityIdentifier<T: CoreRepositoryObjectProtocol>(identifier:String) -> T?{
    
        switch self.fetchRequestForEntityNamed(T.entityName()){
        case let fetchRequestReturnType.success(request):
            switch self.resultsForRequest(request){
            case let repositoryDataReturnType.success(results):
                if let filtered = (results.filter({($0 as! T).entityIdentifier == identifier as String}).first) as? T{
                    println("\(filtered.printDescription())")
                    return filtered
                }
            case let repositoryDataReturnType.failure(error):
                println("Error: \(error.localizedDescription)")
            }
        case let fetchRequestReturnType.failure(error):
            println("Error: \(error.localizedDescription)")
            
        }
        return nil
    }
    
    func fetchEntityWithFilter<T: CoreRepositoryObjectProtocol>(filter:(includedElement:AnyObject) -> Bool) -> [T]{
    
        switch self.fetchRequestForEntityNamed(T.entityName()){
        case let fetchRequestReturnType.success(request):
            switch self.resultsForRequest(request){
            case let repositoryDataReturnType.success(results):
                let filtered = results.filter(filter)
                println("Count: \(filtered.count)")
                return filtered as! [T]
                //return filtered.map({$0 as! T})
            case let repositoryDataReturnType.failure(error):
                println("Error: \(error.localizedDescription)")
            }
        case let fetchRequestReturnType.failure(error):
            println("Error: \(error.localizedDescription)")
            
        }
        return [T]()
    
    }
    
    // MARK: - core repository delegate
    func backingstoreErrorEmitted(error: NSError) {
        self.lastErrors?.append(error)
    }
    
}