//
//  SMState.swift
//  VHHStateMachine
//
//  Created by Dirk Lewis on 3/30/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation

public func ==(lhs: SMState, rhs: SMState) -> Bool{
    return lhs.hashValue == rhs.hashValue
}
public class SMState: Hashable, Equatable {
     
    var name: String = ""
    var willEnterState : stateCallback
    public var didEnterState : stateCallback
    var willExitState : stateCallback
    var didExitState : stateCallback
    
    public var hashValue: Int{
        return self.name.hashValue
    }
    
    public init (name:String){
    
        if (name.isEmpty) {
            NSException(name: NSInvalidArgumentException, reason: "The 'name' can not be blank", userInfo: nil).raise()
        }
        self.name = name
        self.didEnterState = nil;
        
    }
    
    public init (name:String, didEnterState:stateCallback){
        
        if (name.isEmpty) {
            NSException(name: NSInvalidArgumentException, reason: "The 'name' can not be blank", userInfo: nil).raise()
        }
        
        self.name = name
        
        if let block = didEnterState {
            self.didEnterState = block
        }
        
        
    }
    
    func description() -> String{
        return self.name
    }
}