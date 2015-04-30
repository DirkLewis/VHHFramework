//
//  SMStatechange.swift
//  VHHStateMachine
//
//  Created by Dirk Lewis on 3/30/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation

public class SMStateChange {
    
    private var event: SMEvent? = nil
    private var sourcestate : SMState? = nil
    private var statemachine : StateMachine? = nil
    public var userinfo : [String : AnyObject]? = nil
    
    public init(event: SMEvent, state: SMState, statemachine: StateMachine, userinfo: [String : AnyObject]?){
        
        self.event = event
        self.sourcestate = state
        self.statemachine = statemachine
        self.userinfo = userinfo!
    }
    
    public init(state: SMState, statemachine: StateMachine, userinfo: [String:AnyObject]?){
        
        self.event = nil
        self.sourcestate = state
        self.statemachine = statemachine
        self.userinfo = userinfo
    }

    
    func destinationState() -> SMState?{
    
        return self.event?.destinationstate!
    }
    
}



