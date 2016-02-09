//
//  ImageDBController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/28/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import AWSDynamoDB

class ImageDBController {
    
    var aGetDataDelegate: AWSDynamoDBGetDataDelegate!
    var image = Array<ImageMapper>()
    
    func getImage(imageID: String!){
        self.image.removeAll()
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        
        let condition = AWSDynamoDBCondition()
        condition.comparisonOperator = AWSDynamoDBComparisonOperator.EQ
        let imageId = AWSDynamoDBAttributeValue()
        imageId.S = imageID
        
        condition.attributeValueList = [imageId]
        
        let scanInput = AWSDynamoDBScanInput()
        
//        scanInput.expressionAttributeNames = ["ImageId" : condition]
        scanInput.expressionAttributeValues = ["ImageId" : condition]
        
        queryExpression.filterExpression = scanInput.filterExpression
        
        dynamoDBObjectMapper.scan(ImageMapper.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.result != nil {
                let result = task.result as! AWSDynamoDBPaginatedOutput
                for item in result.items as! [ImageMapper] {
                    self.image.append(item)
                }
                if self.aGetDataDelegate != nil{
                    self.aGetDataDelegate.onGetDataSuccess(self.image, type: IMAGE_DB)
                }
            }
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })

    }
}