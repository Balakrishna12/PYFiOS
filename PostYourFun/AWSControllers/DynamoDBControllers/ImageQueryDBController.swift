//
//  ImageQueryDBController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/28/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ImageQueryDBController {
    
    var aGetDataDelegate: AWSDynamoDBGetDataDelegate!
    var imageQuery = Array<ImageQueryMapper>()
    
    func getImageInfo(device: DeviceMapper, displayID: String) {

        self.imageQuery.removeAll()
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()

        let condition = AWSDynamoDBCondition()
        condition.comparisonOperator = AWSDynamoDBComparisonOperator.EQ
        let deviceId = AWSDynamoDBAttributeValue()
        let displayId = AWSDynamoDBAttributeValue()
        
        deviceId.S = device.DeviceId
        displayId.S = displayID
        
        condition.attributeValueList = [displayId]
        
//        queryExpression.scanFilter = ["DisplayId":condition]
        
        let scanInput = AWSDynamoDBScanInput()
        
        scanInput.expressionAttributeNames = ["DisplayId" : condition]
        scanInput.expressionAttributeValues = ["DisplayId" : condition]
        
        queryExpression.filterExpression = scanInput.filterExpression
        
        
        dynamoDBObjectMapper.scan(ImageQueryMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.result != nil {
                let result = task.result as! AWSDynamoDBPaginatedOutput
                for item in result.items as! [ImageQueryMapper] {
                    if item.DeviceId == device.DeviceId {
                        self.imageQuery.append(item)
                    }
                }
                if self.aGetDataDelegate != nil{
                    self.aGetDataDelegate.onGetDataSuccess(self.imageQuery, type: IMAGEQUERY_DB)
                }
            }
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })
    }
    
    func getImageInfoForAllDevices(devices:Array<DeviceMapper>, displayID: String) {
        
        self.imageQuery.removeAll()
        
        for device:DeviceMapper in devices {
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            let queryExpression = AWSDynamoDBScanExpression()
            
            let condition = AWSDynamoDBCondition()
            condition.comparisonOperator = AWSDynamoDBComparisonOperator.EQ
            let deviceId = AWSDynamoDBAttributeValue()
            let displayId = AWSDynamoDBAttributeValue()
            
            deviceId.S = device.DeviceId
            displayId.S = displayID
            
            condition.attributeValueList = [displayId]
            
            let scanInput = AWSDynamoDBScanInput()
            
            scanInput.expressionAttributeNames = ["DisplayId" : condition]
            scanInput.expressionAttributeValues = ["DisplayId" : condition]
            
            queryExpression.filterExpression = scanInput.filterExpression
            
            
            dynamoDBObjectMapper.scan(ImageQueryMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
                
                if task.result != nil {
                    let result = task.result as! AWSDynamoDBPaginatedOutput
                    for item in result.items as! [ImageQueryMapper] {
                        if item.DeviceId == device.DeviceId {
                            self.imageQuery.append(item)
                        }
                    }
                    if self.aGetDataDelegate != nil{
                        self.aGetDataDelegate.onGetDataSuccess(self.imageQuery, type: IMAGEQUERY_DB)
                    }
                }
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                }
                return nil
            })
        }
    }
}