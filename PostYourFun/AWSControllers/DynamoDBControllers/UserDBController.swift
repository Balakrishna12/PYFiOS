//
//  UserDBController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/26/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class UserDBController {
    
    var users = Array<UserMapper>()
    var aDelegate: AWSControllerDelegate!
    var aGetDataDelegate: AWSDynamoDBGetDataDelegate!
    
    func insertUser(id: String, email: String, firstName: String, lastName: String){
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        var user = UserMapper()
        
        user.UserId = id
        user.Email = email
        user.FirstName = firstName
        user.LastName = lastName
        
        dynamoDBObjectMapper.save(user).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            if task.result != nil{
                if self.aDelegate != nil{
                    self.aDelegate.onAWSTaskSuccess(USER_DB)
                }
                
            }else{
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                }
            }
            return nil
        })
    }
    
    func getUsers() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        
        users.removeAll()
        
        dynamoDBObjectMapper.scan(UserMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
            if task.result != nil{
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                for item in paginatedOutput.items as! [UserMapper]{
                    self.users.append(item)
                    var userID = item.UserId!
                    print(userID)
                }
                if self.aDelegate != nil{
                    self.aGetDataDelegate.onGetDataSuccess(self.users, type: USER_DB)
                }
            }
            
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })
    }
}