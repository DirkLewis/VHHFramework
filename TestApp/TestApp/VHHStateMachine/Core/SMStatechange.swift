//
//  SMStatechange.swift
//  VHHStateMachine
//
//  Created by Dirk Lewis on 3/30/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation

class SMStateChange {
    
    private var event: SMEvent? = nil
    private var sourcestate : SMState? = nil
    private var statemachine : StateMachine? = nil
    var userinfo : [String : AnyObject]? = nil
    
    init(event: SMEvent, state: SMState, statemachine: StateMachine, userinfo: [String : AnyObject]?){
        
        self.event = event
        self.sourcestate = state
        self.statemachine = statemachine
        self.userinfo = userinfo!
    }
    
    init(state: SMState, statemachine: StateMachine, userinfo: [String:AnyObject]?){
        
        self.event = nil
        self.sourcestate = state
        self.statemachine = statemachine
        self.userinfo = userinfo
    }

    
    func destinationState() -> SMState?{
    
        return self.event?.destinationstate!
    }
    
}



