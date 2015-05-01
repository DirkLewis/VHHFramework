//
//  VHHStateMachineTests.swift
//  VHHStateMachineTests
//
//  Created by Dirk Lewis on 3/30/15.
//  Copyright (c) 2015 VITAS. All rights reserved.
//

import UIKit
import XCTest

class VHHStateMachineTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testStateMachineCreation() {
    
        let sm = StateMachine();
        
        let state = SMState(name: "teststate")
        let event = SMEvent(name: "event1", sourcestates: [state], destinationstate: state)
        sm.addStates([state])
        sm.addEvents([event])
        sm.startMachine()
        let isinstate = sm.isInState("teststate")
        sm.stopMachine()
        println("stopper")
    
    }
    
    func testStateCreation(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationHandler:", name: kStateMachineDidChangeStateNotification, object: nil)
    
        let state1 = SMState(name: "state1"){ (statechange) -> () in
            println("state 1 did enter state")
        }
        
        state1.willEnterState = {(statechange)->() in
            println("state 1 will enter state")
        }
        
        state1.willExitState = {(statechange)->() in
            println("state 1 will exit state")
        }
        
        state1.didExitState = {(statechange)->() in
            println("state 1 did exit state")
        }
        
        let state2 = SMState(name: "state2") { (statechange) -> () in
            println("state 2 did enter state")
            let test: AnyObject? = statechange!.userinfo!["person"]

        }
        let state3 = SMState(name: "state3") { (statechange) -> () in
            println("State 3 did enter state")
        }
        XCTAssertNotNil(state1, "should not be nil")
        
        let event1 = SMEvent(name: "transitionState2", sourcestates: [state1], destinationstate: state2)
        let event2 = SMEvent(name: "transitionState3", sourcestates: [state2], destinationstate: state3)
        let event3 = SMEvent(name: "transitionState1", sourcestates: [state3], destinationstate: state1)

        let sm = StateMachine()
        sm.addStates([state1,state2,state3])
        sm.addEvents([event1,event2,event3])
        sm.startMachine()
        let result = sm.isInState(sm.initialState!.name)
        let result2 = sm.isInState("state1")
        let result3 = sm.canChangeStateForEvent("event2")
        let result4 = sm.canChangeStateForEvent("event1")


        var error: NSError? = nil
        let result7 = sm.changeStateForEvent("transitionState2", userInfo: ["person":["dirk", "lewis"]], error: &error)
        println("error: \(error?.description)")

        let result8 = sm.changeStateForEvent("transitionState3", userInfo: ["person":["dirk", "lewis"]], error: &error)
        println("error: \(error?.description)")

        let result9 = sm.changeStateForEvent("transitionState1", userInfo: ["person":["dirk", "lewis"]], error: &error)
        
        println("error: \(error?.description)")
        println("stopper")
        
    }
   
    //observer
    func notificationHandler(notification:NSNotification){
        println("stopper")
    }
    
}
