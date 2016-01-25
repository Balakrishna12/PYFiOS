//
//  AWSDynamoDBGetDataDelegate.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/26/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation

let USER_DB = 1
let PARK_DB = 2
let DEVICE_DB = 3
let IMAGEQUERY_DB = 4
let IMAGE_DB = 5
let PARK_INFO_DB = 6
let PARK_SOCIAL_DB = 7
let RATE_DB = 8
let FACEBOOK_USER_DB = 9
let USERIMAGE_DB = 10

protocol AWSDynamoDBGetDataDelegate {
    func onGetDataSuccess(datas: Array<AnyObject>!, type: Int)
    func onGetDataFailed(error: String!)
}