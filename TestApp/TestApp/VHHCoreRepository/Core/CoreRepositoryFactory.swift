//
//  CoreRepositoryStateMachineFactory.swift
//  VHHCoreRepository
//
//  Created by Dirk Lewis on 4/29/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation

let kClosedRepositoryState = "closedrepositorystate"
let kOpenedRepositoryState = "openedrepositorystate"
let kResetRepositoryState = "resetrepositorystate"
let kDeletedRepositoryState = "deletedrepositorystate"

let kOpenRepositoryEvent = "openrepositoryevent"
let kCloseRepositoryEvent = "closerepositoryevent"
let kResetRepositoryEvent = "resetrepositoryevent"
let kDeleteRepositoryEvent = "deleterepositoryevent"

class CoreRepositoryFactory {
    
    //MARK: - Repository State Machine
    
    class func createRepositoryStatemachine()-> StateMachine {
    
        let statemachine = StateMachine()

        let closedrepositorystate = SMState(name: kClosedRepositoryState){(statechange) -> () in
            println("did enter closed state")
            if let repository = (statechange!.userinfo?["repository"] as? CoreRepository) {
                repository.managedObjectContext = nil
                repository.delegate?.repositoryClosed!()
            }
        }
        
        let openedrepositorystate = SMState(name: kOpenedRepositoryState){ (statechange) -> () in
            println("did enter opened state")
            if let repository = (statechange!.userinfo!["repository"] as? CoreRepository) {
                repository.managedObjectContext = repository.backingstore?.managedObjectContext
                repository.delegate?.repositoryOpened(repository.managedObjectContext)
            }
        }
        
        let resetrepositorystate = SMState(name: kResetRepositoryState) {(statechange) -> () in
            println("did enter reset state")
            if let repository = (statechange!.userinfo!["repository"] as? CoreRepository) {
                repository.backingstore?.resetPersistentStoreCoordiator(false)
                repository.delegate?.repositoryReset!()
            }
        }

        let deletedrepositorystate = SMState(name: kDeletedRepositoryState) {(statechange) -> () in
            println("did enter deleted state")
            if let repository = (statechange!.userinfo!["repository"] as? CoreRepository) {
                repository.backingstore?.resetPersistentStoreCoordiator(true)
                repository.delegate?.repositoryDeleted!()
            }
        }
        
        let closerepositoryevent = SMEvent(name: kCloseRepositoryEvent, sourcestates: [openedrepositorystate], destinationstate: closedrepositorystate)
        let openrepositoryevent = SMEvent(name: kOpenRepositoryEvent, sourcestates: [closedrepositorystate,deletedrepositorystate,resetrepositorystate], destinationstate: openedrepositorystate)
        let resetrepositoryevent = SMEvent(name: kResetRepositoryEvent, sourcestates: [closedrepositorystate], destinationstate: resetrepositorystate)
        let deleterepositoryevent = SMEvent(name: kDeleteRepositoryEvent, sourcestates: [closedrepositorystate], destinationstate: deletedrepositorystate)

        statemachine.addStates([closedrepositorystate,openedrepositorystate,resetrepositorystate, deletedrepositorystate])
        statemachine.addEvents([closerepositoryevent, openrepositoryevent,resetrepositoryevent,deleterepositoryevent])
        statemachine.setInitialState(closedrepositorystate)
        
        return statemachine
    }
    
    //MARK: - Repository creation
    
}