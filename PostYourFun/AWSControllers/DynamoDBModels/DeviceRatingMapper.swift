//
//  DeviceRatingMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class DeviceRatingMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var RatingId: String?
    var UserId: String?
    var DeviceId: String?
    var Speed: String?
    var G_force: String?
    var AdrenalineKick: String?
    var Comment: String?
    
    static func dynamoDBTableName() -> String! {
        return "DeviceRating"
    }
    static func hashKeyAttribute() -> String! {
        return "RatingId"
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