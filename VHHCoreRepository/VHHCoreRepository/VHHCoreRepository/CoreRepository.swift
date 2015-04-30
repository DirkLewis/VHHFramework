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
            return success
        }
        if error != nil{
            self.delegate?.repositoryErrorGenerated(error!)
        }
        return false
    }
    
    // MARK: - protocol methods
    
    func openBackingstore() -> Bool {
        return self.changeStateForEvent(kOpenRepositoryEvent)
    }
    
    func closeBackingstore() -> Bool {
        return self.changeStateForEvent(kCloseRepositoryEvent)
    }
    
    
    func resetBackingstore() -> Bool {
        return self.changeStateForEvent(kResetRepositoryEvent)
    }
    
    func deleteBackingstore() -> Bool {
        return self.changeStateForEvent(kDeleteRepositoryEvent)
    }
    
    lazy var repositoryDescription: String = {
        return self.backingstore!.backingstoreDescription
        }()
    
    lazy var currentState: String? = {
        return self.stateMachine?.currentStateName()
    }()
    
    // MARK: - core repository delegate
    func backingstoreErrorGenerated(error: NSError) {
        self.delegate?.repositoryErrorGenerated(error)
    }
    
}