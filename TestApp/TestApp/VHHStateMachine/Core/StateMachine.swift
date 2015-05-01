//
//  StateMachine.swift
//  VHHStateMachine
//
//  Created by Dirk Lewis on 3/30/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

typealias eventCallBack = ((statechange:SMStateChange)-> Bool)?
typealias stateCallback = ((statechange:SMStateChange?)->())?


enum SMErrorCode: Int{
    case SMInvalidTransitionError = -100
    case SMTransitionDeclinedError = -101
}

let kSMErrorDomain = "com.vhh.statemachine.errors"
let kStateMachineDidChangeStateNotification = "statemachinedidchangestatenotification"
let kStateMachineDidChangeStateOldStateUserInfoKey = "old"
let kStateMachineDidChangeStateNewStateUserInfoKey = "new"
let kStateMachineDidChangeStateEventUserInfoKey = "event"
let kStateMachineIsImmutableException = "statemachineisimmutableexception"

class StateMachine {

    private(set) var states: Set<SMState>? = nil
    private(set) var initialState: SMState? = nil
    
    private var mutableStates = Set<SMState>()
    private var mutableEvents = Set<SMEvent>()
    private var isRunning: Bool = false
    private(set) var currentState: SMState? = nil
    private let lock = NSRecursiveLock()
    
    
    // MARK: General
    init(){}

    class func stateMachine() -> StateMachine {
        return StateMachine()
    }
    
    func raiseExceptionIfRunning(isRunning:Bool, operation:String){
        if(isRunning == self.isRunning){NSException(name: kStateMachineIsImmutableException, reason: "Unable to perform operation \(operation). statemachine.isRunning is \(self.isRunning)", userInfo: nil).raise()}
    }

    func description()->String{
        let separator = "."
        return "\(_stdlib_getDemangledTypeName(self).componentsSeparatedByString(separator).last!), \(self.mutableEvents.count)"
    }
    
    //MARK: Add Methods
    private func addMachineObject<T>(machineobject:T){
    
        raiseExceptionIfRunning(true, operation: "add machine objects")
        
        if (machineobject is SMState){
        
            let state = (machineobject as! SMState)
            if ((self.stateNamed(state.name)) != nil){
                NSException(name: NSInvalidArgumentException, reason: "State with \(state.name) already exists", userInfo: nil).raise()
            }
            
            if (self.initialState == nil){
                self.initialState = state
            }
            
            self.mutableStates.insert(state)
        }
        else if (machineobject is SMEvent){
        
            let event = (machineobject as! SMEvent)
            if let sourceStates = event.sourcestates{
                for state in sourceStates{
                    if(!self.mutableStates.contains(state)){
                        NSException(name: NSInternalInconsistencyException, reason: "Cannot add event \(event.name) to the state machine: the event references a state \(state.name) that has not been added to the state machine", userInfo: nil).raise()
                    }
                }
                self.mutableEvents.insert(event)
            }
            
        }
        else{
        
        }
    }
    
    func addStates(states:Array<SMState>){
        for state in states{
            self.addMachineObject(state)
        }
    }
    
    func addEvents(events:Array<SMEvent>){
        for event in events{
            self.addMachineObject(event)
        }
    }
    
    //MARK: State Methods
    
    func currentStateName() -> String?{
        return self.currentState?.name
    }
    
    func stateNamed(name:String)->SMState?{
        
        for state in self.mutableStates{
            if state.name == name{
                return state
            }
        }
        
        return nil
    }
    
    func isInState(stateName:String) -> Bool{
        raiseExceptionIfRunning(false, operation: "is in state")
        
        var currentState: SMState? = self.stateNamed(stateName)!
        
        if (currentState == nil) {
            NSException(name: NSInvalidArgumentException, reason: "State named: \(stateName) not found.", userInfo: nil).raise()
        }
        let result = self.currentState == currentState
        return result
    }
    
    
    //MARK: Event Methods
    func events()->Set<SMEvent>?{
        return Set(self.mutableEvents)
    }
    
    func eventNamed(name:String)->SMEvent?{
    
        for event in self.mutableEvents{
        
            if event.name == name{
            
                return event
            }
        }
        return nil
    }
    
    //MARK: State Machine Methods
    
    func setInitialState(initialState:SMState){
        self.initialState = initialState
    }
    
    func startMachine(){
    
        raiseExceptionIfRunning(true, operation: "Start StateMachine")
        self.lock.lock()
        
        self.isRunning = true
        
        self.currentState = self.initialState
        if let didEnterState = self.initialState?.didEnterState{
            didEnterState(statechange: SMStateChange(state: self.currentState!, statemachine: self, userinfo: nil))
        }
        else{
            if(self.mutableStates.count == 0 || self.mutableEvents.count == 0){
                NSException(name: NSInternalInconsistencyException, reason: "This state machine does not have states or event configured.", userInfo: nil).raise()
            }
        }
        self.lock.unlock()
    }
    
    func stopMachine(){
        raiseExceptionIfRunning(false, operation: "Stop StateMachine")
        self.lock.lock()
        
        self.isRunning = false
        self.mutableStates.removeAll(keepCapacity: false)
        self.mutableEvents.removeAll(keepCapacity: false)
        self.currentState = nil
        
        self.lock.unlock()
    }
    
    func canChangeStateForEvent(eventName:String) -> Bool{
        
        if let states = self.eventNamed(eventName)?.sourcestates?.filter({$0.name == self.currentState?.name}){
            return states.count > 0
        }
        return false
    }
    
    
    func changeStateForEvent(eventName:String, userInfo:Dictionary<String,AnyObject>?, error:NSErrorPointer) -> Bool{
    
        self.lock.lock()
        var currentEvent: SMEvent?
        
        if (!self.isRunning){self.startMachine()}
        
        currentEvent = self.eventNamed(eventName)
        
        if (currentEvent == nil){NSException(name: NSInternalInconsistencyException, reason: "Cannot find an event named \(eventName)", userInfo: nil).raise()}
        
        if (!self.canChangeStateForEvent(eventName)){
            let string = currentEvent!.sourcestates?.map{return $0.name}
            let failureReason = "An attempt was made to fire the '\(currentEvent?.name)' while in the state \(self.currentState?.name), but the event can only be fired from the following states: \(string)."
            let userInfo = [NSLocalizedDescriptionKey:"The event cannot be fired from the current state.", NSLocalizedFailureReasonErrorKey:failureReason]
            error.memory = NSError(domain: kSMErrorDomain, code: SMErrorCode.SMInvalidTransitionError.rawValue, userInfo: userInfo)
            self.lock.unlock()
            return false
        }
        
        var stateChange = SMStateChange(event: currentEvent!, state: self.currentState!, statemachine: self, userinfo: userInfo)
        
        if let shouldFireEvent = currentEvent?.shouldFireEventBlock{
            if (!shouldFireEvent(statechange: stateChange)){
                let failureReason = "Attempt to fire the \(currentEvent!.name) event was declined because 'shouldFireEventBlock' failed."
                let userInfo = [NSLocalizedDescriptionKey:"The event declined to be fired.", NSLocalizedFailureReasonErrorKey:failureReason]
                error.memory = NSError(domain: kSMErrorDomain, code: SMErrorCode.SMTransitionDeclinedError.rawValue, userInfo: userInfo)
                self.lock.unlock()
                return false
            }
        }
        
        let oldstate = self.currentState
        let newstate = currentEvent?.destinationstate
        
        if let willFireEvent = currentEvent?.willFireEventBlock{
            willFireEvent(statechange: stateChange)
        }
        
        if let state = oldstate,  willExitState = oldstate!.willExitState{
            willExitState(statechange: stateChange)
        }
        
        if let state = newstate, willEnterState = newstate!.willEnterState{
            willEnterState(statechange: stateChange)
        }
        self.currentState = newstate

        if let state = oldstate, didExitState = oldstate!.didExitState{
            didExitState(statechange: stateChange)
        }
        
        if let state = newstate, didEnterState = newstate!.didEnterState{
        
            didEnterState(statechange: stateChange)
        }
        
        if let didFireEvent = currentEvent!.didFireEventBlock{
            didFireEvent(statechange: stateChange)
        }
        
        self.lock.unlock()
        var notificationInfo: Dictionary<String,AnyObject>
        if let userinfo = userInfo{
            notificationInfo = userinfo
        }
        else{
            notificationInfo = Dictionary()
        }
        
        notificationInfo.update([kStateMachineDidChangeStateOldStateUserInfoKey : oldstate!, kStateMachineDidChangeStateNewStateUserInfoKey : newstate!, kStateMachineDidChangeStateEventUserInfoKey : currentEvent!])
        
        NSNotificationCenter.defaultCenter().postNotificationName(kStateMachineDidChangeStateNotification, object: self, userInfo: notificationInfo)
        
        return true

    }
    

}









