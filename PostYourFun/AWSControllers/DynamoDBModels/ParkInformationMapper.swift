//
//  ParkInformation.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/25/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ParkInformationMapper: AWSDynamoDBObjectModel, AWSDynamoDBModeling{
    var ParkId: String?
    var Email: String?
    var ImageUrl: String?
    var OpeningInformation: String?
    var WebSite: String?
    
    static func dynamoDBTableName() -> String! {
        return "ParkInformation"
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