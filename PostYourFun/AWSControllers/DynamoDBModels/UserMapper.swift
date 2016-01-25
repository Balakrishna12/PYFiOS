//
//  UserMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class UserMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var UserId: String?
    var Email: String?
    var FirstName: String?
    var LastName: String?
    
    static func dynamoDBTableName() -> String! {
        return "User"
    }
    
    static func hashKeyAttribute() -> String! {
        return "UserId"
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    override func `self`() -> Self {
        return self
    }
}