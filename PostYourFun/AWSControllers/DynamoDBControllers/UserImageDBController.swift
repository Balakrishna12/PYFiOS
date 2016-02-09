//
//  UserImageDBController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 8/5/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class UserImageDBController {
    
    var aDelegate: AWSControllerDelegate!
    var aGetDataDelegate: AWSDynamoDBGetDataDelegate!
    var userImage: UserImagesMapper = UserImagesMapper()
    var userTransactions: Array<UserImagesMapper> = Array<UserImagesMapper>()
    
    func registerPayment(userId: String, dateTime: String, imageId: String, imageUrl: String, imageThumbUrl: String!){
        
        self.userImage.TransactionId = NSUUID().UUIDString
        self.userImage.UserId = userId
        self.userImage.DateTime = dateTime
        self.userImage.ImageId = imageId
        self.userImage.ImageUrl = imageUrl
        self.userImage.ImageThumbUrl = imageThumbUrl
        self.userImage.Owned = 1
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        dynamoDBObjectMapper.save(self.userImage).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.result != nil {
                if self.aDelegate != nil{
                    self.aDelegate.onAWSTaskSuccess(USERIMAGE_DB)
                }
                
            } else {
                if ((task.error) != nil) {
                    let error = task.error!.localizedDescription
                    self.aDelegate.onAWSTaskFailed(error)
                }
            }
            return nil
        })
    }
    
    func readTransactions(userId: String!) {
        
        self.userTransactions.removeAll()
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        
        let condition = AWSDynamoDBCondition()
        condition.comparisonOperator = AWSDynamoDBComparisonOperator.EQ
        let user_Id = AWSDynamoDBAttributeValue()
        user_Id.S = userId
        
        condition.attributeValueList = [user_Id]
        
        let scanInput = AWSDynamoDBScanInput()
        
//        scanInput.expressionAttributeNames = ["UserId" : condition]
//        scanInput.expressionAttributeValues = ["UserId" : condition]
        
        scanInput.scanFilter = ["UserId":condition]
        
        queryExpression.filterExpression = scanInput.filterExpression
        
        dynamoDBObjectMapper.scan(UserImagesMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.result != nil {
                let result = task.result as! AWSDynamoDBPaginatedOutput
                for item in result.items as! [UserImagesMapper] {
                    
                    if userId == item.UserId {
                        
                        self.userTransactions.append(item)
                        print(item.TransactionId!)
                    }
                }
                if self.aGetDataDelegate != nil{
                    self.aGetDataDelegate.onGetDataSuccess(self.userTransactions, type: USERIMAGE_DB)
                }
            }
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })
    }
}