//
//  UserFacebookDBController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/30/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class UserFacebookDBController {
    
    var fbUsers = Array<UserFacebookMapper>()
    
    var aDelegate: AWSControllerDelegate!
    var aGetDataDelegate: AWSDynamoDBGetDataDelegate!
    
    func checkFacebookUser(facebookId: String){
        self.fbUsers.removeAll()
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        
        let condition = AWSDynamoDBCondition()
        condition.comparisonOperator = AWSDynamoDBComparisonOperator.EQ
        let fbId = AWSDynamoDBAttributeValue()
        fbId.S = facebookId
        
        condition.attributeValueList = [fbId]
        
//        queryExpression.scanFilter = ["FacebookId": condition]
        
        let scanInput = AWSDynamoDBScanInput()
        
        scanInput.scanFilter = ["FacebookId":condition]
        
        queryExpression.filterExpression = scanInput.filterExpression
        
        dynamoDBObjectMapper.scan(UserFacebookMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.result != nil {
                let result = task.result as! AWSDynamoDBPaginatedOutput
                for item in result.items as! [UserFacebookMapper] {
                    
                    if item.FacebookId == facebookId {
                        
                        self.fbUsers.append(item)
                        print(item.FacebookId!)
                    }
                }
                
                if self.aGetDataDelegate != nil {
                    self.aGetDataDelegate.onGetDataSuccess(self.fbUsers, type: FACEBOOK_USER_DB)
                }
            }
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })

    }
    
    func insertFacebookUser(facebookId: String, userId: String, email: String){
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        let fbUser = UserFacebookMapper()
        
        fbUser.FacebookId = facebookId
        fbUser.UserId = userId
        fbUser.Email = email
        
        dynamoDBObjectMapper.save(fbUser).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            if task.result != nil{
                if self.aDelegate != nil{
                    self.aDelegate.onAWSTaskSuccess(FACEBOOK_USER_DB)
                }
                
            }else{
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                }
            }
            return nil
        })

    }
}