//
//  DeviceDBController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/26/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class DeviceDBController {
    var aGetDataDelegate: AWSDynamoDBGetDataDelegate!
    var all_devices = Array<DeviceMapper>()
    
    func getAllDevices(){
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        
        dynamoDBObjectMapper.scan(DeviceMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
            if task.result != nil{
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                for item in paginatedOutput.items as! [DeviceMapper]{
                    self.all_devices.append(item)
                }
                if self.aGetDataDelegate != nil{
                    self.aGetDataDelegate.onGetDataSuccess(self.all_devices, type: DEVICE_DB)
                }
            }
            
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })
    }
    
    func getDevice(deviceId: String){
        
        var devices = Array<DeviceMapper>()
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        
        let condition = AWSDynamoDBCondition()
        condition.comparisonOperator = AWSDynamoDBComparisonOperator.EQ
        let deviceID = AWSDynamoDBAttributeValue()
        deviceID.S = deviceId
        
        condition.attributeValueList = [deviceID]
        
        let scanInput = AWSDynamoDBScanInput()
        
        scanInput.scanFilter = ["DeviceId":condition]
        
        queryExpression.filterExpression = scanInput.filterExpression
        
        dynamoDBObjectMapper.scan(DeviceMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.result != nil {
                let result = task.result as! AWSDynamoDBPaginatedOutput
                for item in result.items as! [DeviceMapper] {
                    
                    if item.DeviceId == deviceID {
                        devices.append(item)
                    }
                }
                if self.aGetDataDelegate != nil{
                    self.aGetDataDelegate.onGetDataSuccess(devices, type: DEVICE_DB)
                }
            }
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })
        
    }
}
