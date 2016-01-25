//
//  SocialControllerDelegate.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/23/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation

let FACEBOOK = 1
let GOOGLPLUS = 2
let TWITTER = 3

let actionLogin = 1
let actionLogout = 2
let actionGetUserData = 3

protocol SocialControllerDelegate {
    func onSuccess(type: Int, action: Int, userData: AnyObject)
    func onFailure(type: Int, action: Int)
}