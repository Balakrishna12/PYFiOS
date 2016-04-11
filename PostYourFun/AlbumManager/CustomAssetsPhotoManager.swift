//
//  CustomAssetsPhotoManager.swift
//  PostYourFun
//
//  Created by Dasha Ruto on 11.04.16.
//  Copyright © 2016 Simon Weingand. All rights reserved.
//

import Foundation
import AssetsLibrary

class CustomAssetsPhotoManager{

    static let sharedInstance = CustomAssetsPhotoManager()
    
    static let albumName: NSString = "Post Your Fun"
    
    var assetsLibrary: ALAssetsLibrary = ALAssetsLibrary()
    
    var isAlbum: Bool = false
    
    //let currentAssetsGroup: ALAssetsGroup
    var currentAssetsGroup: ALAssetsGroup!
    
    
    init () {
        
        assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAlbum, usingBlock: { (group, stop) in
            
            print("GROUP: %@", group)
            
            let propertyName = group.valueForProperty(ALAssetsGroupPropertyName) as! NSString
            
            if (propertyName.isEqualToString(CustomAssetsPhotoManager.albumName as String)) {
                self.isAlbum = true
                self.currentAssetsGroup = group
            }
            
//            if stop.memory {
//                
//            }
            
            }) { (error) in
                 print("failed to enumerate albums:\nError: %@", error);
        }
        
        if !isAlbum {
        
            self.assetsLibrary.addAssetsGroupAlbumWithName(CustomAssetsPhotoManager.albumName as String, resultBlock: { (group) in
                print("added album: PYF");
                self.currentAssetsGroup = group
                
            }) { (error) in
                print("error adding album %@", error);
            }
            
        }
    
        
    }
    
    func saveImageWithName(photoImage: UIImage!, imageName: NSString) {
        
        if (currentAssetsGroup == nil) {
            return;
        }
        
        assetsLibrary.writeImageToSavedPhotosAlbum(photoImage.CGImage, orientation: ALAssetOrientation(rawValue: photoImage.imageOrientation.rawValue)!) { (assetURL, error) in
            
             if (error.code == 0) {
                print("saved image completed:\nurl: %@", assetURL);
                
             } else {
                print("saved image failed.\nError: %@", error);
                
            }
            
            
        }
        
        
    }
    

    
    

    
}