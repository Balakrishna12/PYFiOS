//
//  DeviceMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class DeviceMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var DeviceId: String?
    var ParkId: String?
    var HasMonitor: NSNumber!
    var ImageSold: NSNumber!
    var Name: String?
    var NumberOfColumns: Int?
    var NumberOfMinutes: Int?
    
    static func dynamoDBTableName() -> String! {
        return "Device"
    }
    static func hashKeyAttribute() -> String! {
        return "DeviceId"
    }
    static func rangeKeyAttribute() -> String! {
        return "ParkId"
    }
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    override func `self`() -> Self {
        return self
    }
}