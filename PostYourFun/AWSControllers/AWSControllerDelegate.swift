//
//  AWSControllerDelegate.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/26/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation

protocol AWSControllerDelegate {
    func onAWSTaskSuccess(type: Int)
    func onAWSTaskFailed(error: String!)
}