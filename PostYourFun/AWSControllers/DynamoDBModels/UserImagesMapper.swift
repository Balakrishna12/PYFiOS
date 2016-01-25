//
//  UserImagesMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class UserImagesMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var TransactionId: String?
    var UserId: String?
    var DateTime: String?
    var ImageId: String?
    var ImageUrl: String?
    var ImageThumbUrl: String?
    var Owned: NSNumber!
    
    static func dynamoDBTableName() -> String! {
        return "UserImages"
    }
    static func hashKeyAttribute() -> String! {
        return "TransactionId"
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
