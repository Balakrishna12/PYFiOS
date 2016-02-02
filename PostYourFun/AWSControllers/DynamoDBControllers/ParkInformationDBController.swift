//
//  ParkInformationDBController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/29/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ParkInformationDBController {
    var aGetDataDelegate: AWSDynamoDBGetDataDelegate!
    var parkInfos = Array<ParkInformationMapper>()
    
    func getParkInfo(parkID: String){
        
        self.parkInfos.removeAll()
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        
        var condition = AWSDynamoDBCondition()
        condition.comparisonOperator = AWSDynamoDBComparisonOperator.EQ
        var parkId = AWSDynamoDBAttributeValue()
        parkId.S = parkID
        
        condition.attributeValueList = [parkId]
        
       let scanInput = AWSDynamoDBScanInput()
        
        scanInput.scanFilter = ["ParkId":condition]
        
        queryExpression.filterExpression = scanInput.filterExpression
        
//        queryExpression.scanFilter = ["ParkId":condition]
        
        dynamoDBObjectMapper.scan(ParkInformationMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.result != nil {
                let result = task.result as! AWSDynamoDBPaginatedOutput
                for item in result.items as! [ParkInformationMapper]{
                    self.parkInfos.append(item)
                    print(item.ImageUrl!)
                }
                if self.aGetDataDelegate != nil{
                    self.aGetDataDelegate.onGetDataSuccess(self.parkInfos, type: PARK_INFO_DB)
                }
            }
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })
    }
}