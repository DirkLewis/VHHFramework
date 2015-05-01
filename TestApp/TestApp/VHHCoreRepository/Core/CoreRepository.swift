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
    
//    lazy var currentState: String? = {
//        return self.stateMachine?.currentStateName()
//    }()
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
    
    func resultsForRequest(request:NSFetchRequest, error:NSErrorPointer) -> Array<AnyObject>{
        if self.stateMachine?.isInState(kOpenedRepositoryState) == true{
            if let results = self.managedObjectContext?.executeFetchRequest(request, error: error){
                return results
            }
        }
        
        return [AnyObject]()
    }
    
    func resultsForRequest(request:NSFetchRequest) -> Array<AnyObject>{
        return self.resultsForRequest(request, error: nil)
    }
    
    func deleteManagedObject(managedObject:NSManagedObject) -> Bool{
        return false
    }
    
    func save() -> Bool{
        return false
    }
    
    // MARK: - core repository delegate
    func backingstoreErrorGenerated(error: NSError) {
        self.delegate?.repositoryErrorGenerated(error)
    }
    
}