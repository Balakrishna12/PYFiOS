//
//  ImageQueryMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ImageQueryMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var ImageId: String?
    var DeviceId: String?
    var DateTime: NSInteger?
    var DisplayId: String?
    var ImageType: String?
    
    static func dynamoDBTableName() -> String! {
        return "ImageListQuery"
    }
    static func hashKeyAttribute() -> String! {
        return "ImageId"
    }
    static func rangeKeyAttribute() -> String! {
        return "deviceId"
    }
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    override func `self`() -> Self {
        return self
    }
}