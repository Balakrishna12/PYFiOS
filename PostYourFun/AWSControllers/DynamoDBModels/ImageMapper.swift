//
//  ImageMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ImageMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var ImageId: String?
    var DeviceId: String?
    var DateTime: NSInteger?
    var DisplayId: String?
    var Name: String?
    var Region: String?
    var ImageType: String?
    
    static func dynamoDBTableName() -> String! {
        return "ImageList"
    }
    static func hashKeyAttribute() -> String! {
        return "ImageId"
    }
    static func rangeKeyAttribute() -> String! {
        return "DeviceId"
    }
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    override func `self`() -> Self {
        return self
    }
}