//
//  FacebookController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/21/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import Photos

class CustomPhotoAlbum {
    
    static let albumName = "Post Your Fun"
    static let sharedInstance = CustomPhotoAlbum()
    var photo: UIImage = UIImage()
    var firstLoad: Bool = false
    
    
    var assetCollection: PHAssetCollection!
    
    let array = NSMutableArray()
    
    init() {
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            
            let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                
                return collection.firstObject as! PHAssetCollection
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(CustomPhotoAlbum.albumName)
            
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
                
                if (self.firstLoad) {
                    self.saveImage(self.photo)
                    self.firstLoad = false
                }
            }
        }
    }
    
    
    func saveImage(image: UIImage) {
        
        photo = image;
        
        if assetCollection == nil {
            array.removeAllObjects()
            firstLoad = true;
            
            return   // If there was an error upstream, skip the save.
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if (collection.count == 0) {
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                
                PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(CustomPhotoAlbum.albumName)
                
            }) { success, _ in
                
                if success {
                    
                    let fetchOptions = PHFetchOptions()
                    
                    fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
                    
                    let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
                    
                    if let _: AnyObject = collection.firstObject {
                        self.assetCollection = collection.firstObject as! PHAssetCollection
                        
                        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                            
                            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                            
                            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                            
                            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                            
                            albumChangeRequest!.addAssets([assetPlaceholder!])
                            
                            }, completionHandler: nil)
                    }
                }
            }
            
        } else {
        
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                
                let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                
                albumChangeRequest!.addAssets([assetPlaceholder!])
                
                }, completionHandler: nil)
            
        }
    
    }
    
    
    func getAllPhotosFromAlbum() -> NSArray! {
        
        if assetCollection == nil {
            array.removeAllObjects()
            return array
        }
        
        let photoAssets = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
        
        let imageManager = PHCachingImageManager()
        
        photoAssets.enumerateObjectsUsingBlock{(object: AnyObject!, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset{
                let asset = object as! PHAsset
                
                let imageSize = CGSize(width: asset.pixelWidth,
                    height: asset.pixelHeight)
                
                /* For faster performance, and maybe degraded image */
                let options = PHImageRequestOptions()
                options.deliveryMode = .FastFormat
                options.synchronous = true
                imageManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: .AspectFill, options: options,
                    resultHandler: { image, info in
                       self.array.addObject(image!)
                        
                        
                })
            }
        }
        
        return array.copy() as! NSArray;
    }
    

    

}





