//
//  SwiftPerson.swift
//  TestApp
//
//  Created by Dirk Lewis on 5/2/15.
//  Copyright (c) 2015 VHH. All rights reserved.
//

import Foundation

class SwiftPerson:_Person {
    
    func personDescription()->String{
        return "\(self.fName) \(self.lName), \(self.age)"
    }
    
}