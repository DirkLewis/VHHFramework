//
//  Person.swift
//  TestApp
//
//  Created by Dirk Lewis on 5/2/15.
//  Copyright (c) 2015 VHH. All rights reserved.
//

import Foundation

@objc(Person)
class Person:_Person {
    
    func personDescription()->String{
        return "\(self.fName) \(self.lName), \(self.age)"
    }
}
