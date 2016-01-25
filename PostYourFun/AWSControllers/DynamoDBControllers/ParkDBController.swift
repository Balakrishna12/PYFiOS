//
//  ParkDBController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/26/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ParkDBController {
    
    var aGetDataDelegate: AWSDynamoDBGetDataDelegate!
    
    func getAllParks(){
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        var parks = Array<ParkMapper>()
        dynamoDBObjectMapper.scan(ParkMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
            if task.result != nil {
                
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                
                for item in paginatedOutput.items as! [ParkMapper] {
                    
                    parks.append(item)
                    
                    print(item)
                }
                
                if self.aGetDataDelegate != nil {
                    self.aGetDataDelegate.onGetDataSuccess(parks, type: PARK_DB)
                }
            }
            
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })
    }
}