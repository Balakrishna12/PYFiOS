//
//  DeviceRatingDBController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/29/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class DeviceRatingDBController {
    var aDelegate: AWSControllerDelegate!
    var deviceRate: DeviceRatingMapper = DeviceRatingMapper()

    func giveRating(userId: String, deviceId: String, speedRate: String, g_forceRate: String, adrenalineRate: String, comment: String) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        self.deviceRate.RatingId = deviceId + "_" + userId
        self.deviceRate.UserId = userId
        self.deviceRate.DeviceId = deviceId
        self.deviceRate.Speed = speedRate
        self.deviceRate.AdrenalineKick = adrenalineRate
        self.deviceRate.Comment = comment
        self.deviceRate.G_force = g_forceRate
        
        dynamoDBObjectMapper.save(deviceRate).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.result != nil{
                if self.aDelegate != nil{
                    self.aDelegate.onAWSTaskSuccess(RATE_DB)
                }
                
            }else{
                if ((task.error) != nil) {
                    var error = task.error!.localizedDescription
                    self.aDelegate.onAWSTaskFailed(error)
                }
            }
            return nil

        })
    }
}