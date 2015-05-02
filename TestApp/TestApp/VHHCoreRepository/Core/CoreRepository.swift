//
//  CoreRepository.swift
//  VHHCoreRepository
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation
import CoreData
import VHHStateMachine

let defaultBatchSize = 25
let repositoryErrorDomain = "com.vhh.corerepository"
let repositoryFailCode = -200

class CoreRepository: CoreRepositoryProtocol, BackingstoreDelegate {
    
    var backingstore: BackingstoreProtocol?
    var managedObjectContext: NSManagedObjectContext?
    var delegate: CoreRepositoryDelegate?
    var stateMachine: StateMachine?
    
    required init(backingstore: BackingstoreProtocol){
        self.backingstore = backingstore
        self.backingstore?.delegate = self
        
        self.stateMachine = CoreRepositoryFactory.createRepositoryStatemachine()
        self.stateMachine?.startMachine()
    }
    
    // MARK: - core data helper methods
    
    // MARK: - helper methods
    
    func childManagedObjectContext() -> NSManagedObjectContext {
        
        let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.parentContext = self.managedObjectContext
        
        return privateContext
    }
    
    func changeStateForEvent(eventName: String) -> Bool{
        
        var error: NSError?
        if let success = self.stateMachine?.changeStateForEvent(eventName, userInfo: ["repository":self], error: &error){
            if error != nil{
                self.delegate?.repositoryErrorGenerated(error!)
            }
            return success
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
    
    func fetchRequestForEntityNamed(entityName: String, batchsize:Int) -> (NSError?, NSFetchRequest?){
        var fetchrequest: NSFetchRequest? = nil
        
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            fetchrequest = NSFetchRequest(entityName: entityName)
            fetchrequest!.fetchBatchSize = batchsize
            
            if let request = fetchrequest{
                return (nil,fetchrequest)
            }
            else{
                return (NSError(domain: repositoryErrorDomain, code: repositoryFailCode, userInfo: ["message":"FetchRequest failed initialization."]), fetchrequest)
            }
        }
        else{
            return (NSError(domain: repositoryErrorDomain, code: repositoryFailCode, userInfo: ["message":"Repository is closed, please open."]), fetchrequest)
        }
    }
    
    func fetchRequestForEntityNamed(entityName: String) -> (NSError?, NSFetchRequest?){
        return self.fetchRequestForEntityNamed(entityName, batchsize: defaultBatchSize)
    }
    
    func resultsForRequest(request:NSFetchRequest) -> [AnyObject]{
        var error: NSError? = nil
        var results = [AnyObject]()
        
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            self.managedObjectContext!.performBlockAndWait({ () -> Void in
                results = self.managedObjectContext!.executeFetchRequest(request, error: &error)!
                if let currenterror = error{
                    self.delegate!.repositoryErrorGenerated(currenterror)
                }
            })
        }
        
        return results
    }
    
    func resultsForRequestAsync(request:NSFetchRequest){
        var error: NSError? = nil
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            self.managedObjectContext!.performBlock({ () -> Void in
                if let results = self.managedObjectContext!.executeFetchRequest(request, error: &error){
                    if let currenterror = error{
                        self.delegate!.repositoryErrorGenerated(currenterror)
                    }
                    self.delegate?.repositoryFetchResults?(results)
                }
                
            })
        }
    }
    
    func deleteManagedObject(managedObject:NSManagedObject){
        self.managedObjectContext!.performBlock { () -> Void in
            self.deleteManagedObject(managedObject)
        }
    }
    
    func saveAsync() {
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            self.managedObjectContext!.performBlock{ () -> Void in
                var error: NSError? = nil
                let result = self.managedObjectContext!.save(&error)
                if error != nil{
                    self.delegate?.repositoryErrorGenerated(error!)
                }
                self.delegate?.repositorySaveResults?(result)
            }
        }
    }
    
    func save() -> Bool{
        var saved: Bool = false
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            self.managedObjectContext!.performBlockAndWait{ () -> Void in
                var error: NSError? = nil
                var saved: Bool = self.managedObjectContext!.save(&error)
                if error != nil{
                    self.delegate?.repositoryErrorGenerated(error!)
                }
            }
        }
        return saved
    }
    
    // MARK: - core repository delegate
    func backingstoreErrorGenerated(error: NSError) {
        self.delegate?.repositoryErrorGenerated(error)
    }
    
}