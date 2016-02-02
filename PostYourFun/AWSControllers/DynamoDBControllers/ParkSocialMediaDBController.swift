//
//  ParkSocialMediaDBController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/29/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ParkSocialMediaDBcontroller {
    var aGetDataDelegate: AWSDynamoDBGetDataDelegate!
    var parkSocialinfos = Array<ParkSocialMediaMapper>()
    
    func getAllParkSocialInfos(){
        
        self.parkSocialinfos.removeAll()
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        
        dynamoDBObjectMapper.scan(ParkSocialMediaMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
            if task.result != nil {
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                for item in paginatedOutput.items as! [ParkSocialMediaMapper]{
                    let parkId = item.ParkId!
                    self.parkSocialinfos.append(item)
                }
                if self.aGetDataDelegate != nil{
                    self.aGetDataDelegate.onGetDataSuccess(self.parkSocialinfos, type: PARK_SOCIAL_DB)
                }
            }
            
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })

    }
    
    func getParkSocialMediaInfo(parkID: String){
        
        self.parkSocialinfos.removeAll()
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        
        let condition = AWSDynamoDBCondition()
        condition.comparisonOperator = AWSDynamoDBComparisonOperator.EQ
        let parkId = AWSDynamoDBAttributeValue()
        parkId.S = parkID
        
        condition.attributeValueList = [parkId]
        
//        queryExpression.scanFilter = ["ParkId":condition]
        
        let scanInput = AWSDynamoDBScanInput()
        
        scanInput.scanFilter = ["DisplayId":condition]
        
        queryExpression.filterExpression = scanInput.filterExpression
        
        dynamoDBObjectMapper.scan(ParkSocialMediaMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.result != nil {
                let result = task.result as! AWSDynamoDBPaginatedOutput
                for item in result.items as! [ParkSocialMediaMapper]{
                    self.parkSocialinfos.append(item)
                    print(item.Facebook!)
                }
                if self.aGetDataDelegate != nil{
                    self.aGetDataDelegate.onGetDataSuccess(self.parkSocialinfos, type: PARK_SOCIAL_DB)
                }
            }
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })
    }
}