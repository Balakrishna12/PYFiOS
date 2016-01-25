//
//  UsertwitterDetailMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class UserTwitterMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var TwitterId: String?
    var UserId: String?
    var Email: String?
    
    static func dynamoDBTableName() -> String! {
        return "UserTwitterDetails"
    }
    static func hashKeyAttribute() -> String! {
        return "TwitterId"
    }
    static func rangeKeyAttribute() -> String! {
        return "UserId"
    }
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    override func `self`() -> Self {
        return self
    }
}
