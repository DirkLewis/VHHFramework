//
//  SMEvent.swift
//  VHHStateMachine
//
//  Created by Dirk Lewis on 3/30/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import Foundation


public func ==(lhs: SMEvent, rhs: SMEvent) -> Bool{
    return lhs.hashValue == rhs.hashValue
}
public class SMEvent: Hashable,Equatable {
    
    private(set) var name : String = ""
    private(set) var sourcestates : [SMState]? = nil
    private(set) var destinationstate : SMState? = nil
    
    var shouldFireEventBlock: eventCallBack
    var willFireEventBlock: eventCallBack
    var didFireEventBlock: eventCallBack
    
    public var hashValue: Int{
        return self.name.hashValue
    }
    
    public init (name: String, sourcestates: [SMState], destinationstate: SMState){
        
        assert(!name.isEmpty, "Name must be provided")
        assert(!destinationstate.name.isEmpty , "Destination must be provided")
        self.name = name
        self.sourcestates = sourcestates
        self.destinationstate = destinationstate
        
    }
    
    func description() -> String{
        return self.name
    }
}