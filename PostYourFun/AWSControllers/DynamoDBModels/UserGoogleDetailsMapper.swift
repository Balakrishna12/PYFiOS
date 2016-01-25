//
//  UserGoogleDetailsMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class UserGoogleMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var GoogleId: String?
    var UserId: String?
    var Email: String?
    
    static func dynamoDBTableName() -> String! {
        return "UserGoogleDetails"
    }
    static func hashKeyAttribute() -> String! {
        return "GoogleId"
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
