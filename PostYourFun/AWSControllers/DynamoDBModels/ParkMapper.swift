//
//  ParkMapper.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ParkMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var ParkId: String?
    var HasMonitors: NSNumber!
    var Name: String?
    var Lattitude: String?
    var Longitude: String?
    var AllInclusive: NSNumber!
    
    static func dynamoDBTableName() -> String! {
        return "Park"
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
