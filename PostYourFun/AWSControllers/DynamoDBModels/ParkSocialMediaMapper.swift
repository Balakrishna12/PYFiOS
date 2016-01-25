//
//  ParkSocialMediaMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ParkSocialMediaMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var ParkId: String?
    var Facebook: String?
    
    static func dynamoDBTableName() -> String! {
        return "ParkSocialMedia"
    }
    static func hashKeyAttribute() -> String! {
        return "ParkId"
    }
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    override func `self`() -> Self {
        return self
    }
}