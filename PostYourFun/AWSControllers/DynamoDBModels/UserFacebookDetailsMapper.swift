//
//  UserFacebookDetailsMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class UserFacebookMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var FacebookId: String?
    var UserId: String?
    var Email: String?
    
    static func dynamoDBTableName() -> String! {
        return "UserFacebookDetails"
    }
    static func hashKeyAttribute() -> String! {
        return "FacebookId"
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