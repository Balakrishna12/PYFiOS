//
//  ViewImageViewController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/21/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import UIKit
import MBProgressHUD
import JTSImageViewController
import SDWebImage

class ViewImageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, AWSDynamoDBGetDataDelegate, CellImageClickDelegate, SocialControllerDelegate {

    @IBOutlet weak var imageGallery: UICollectionView!
    @IBOutlet weak var shareWithFriends: UIButton!
    
    var userImageDBController: UserImageDBController = UserImageDBController()
    var userImages: Array<UserImagesMapper> = Array<UserImagesMapper>()
    var userId: String!
    var selectedImageIndex = -1
    
    var deviceDBController: DeviceDBController = DeviceDBController()
    var parkSocialDBController: ParkSocialMediaDBcontroller = ParkSocialMediaDBcontroller()
    var imageDBController: ImageDBController = ImageDBController()
    
    var fbController = FacebookController()
    
    var selectedImagesArray: Array<AnyObject> = Array<AnyObject>()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.userImageDBController.aGetDataDelegate = self
        
//        deviceDBController.aGetDataDelegate = self
//        fbController.mDelegate = self
//        imageDBController.aGetDataDelegate = self
//        parkSocialDBController.aGetDataDelegate = self
        
        userId = NSUserDefaults.standardUserDefaults().objectForKey(kUserId) as? String
    }

    override func viewDidAppear(animated: Bool) {
        userImageDBController.readTransactions(self.userId)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        selectedImageIndex = -1
    }
    
    func onGetDataSuccess(datas: Array<AnyObject>!, type: Int) {
        if type == USERIMAGE_DB {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.userImages = datas as! Array<UserImagesMapper>
            
            self.selectedImagesArray.removeAll()
            
            for _ in self.userImages {
                
//                if let imageURL = image.ImageUrl {
                
//                   let downloader = SDWebImageDownloader.sharedDownloader()
//                    
//                    downloader.downloadImageWithURL(NSURL(string: imageURL), options: .ContinueInBackground, progress: { (progress, download) -> Void in
//                        
//                        }, completed: { (image, data, error, finished) -> Void in
//                            
//                            self.downloadFile(imageURL)
//                    })
//                }
                
                self.selectedImagesArray.append(false)
            }
            
            self.imageGallery.reloadData()
        }
        if type == IMAGE_DB {
            var images = datas as! Array<ImageMapper>
            let image = images[0]
            self.deviceDBController.aGetDataDelegate = self
            self.deviceDBController.getDevice(image.DeviceId!)
        }
        if type == DEVICE_DB{
            var devices = datas as! Array<DeviceMapper>
            
            if devices.count > 0 {
                
                let device = devices[0]
                self.parkSocialDBController.aGetDataDelegate = self
                parkSocialDBController.getParkSocialMediaInfo(device.ParkId!)
                
            } else {
                
                self.parkSocialDBController.aGetDataDelegate = self
                parkSocialDBController.getAllParkSocialInfos()
            }
        }
        if type == PARK_SOCIAL_DB {
            var results = datas as! Array<ParkSocialMediaMapper>
            let result = results[0]
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            let image = self.userImages[self.selectedImageIndex]
            
//            let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
            
//            let imagePath = image.ImageUrl!.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
//            let destinationUrl = documentsUrl!.URLByAppendingPathComponent(imagePath)
            
//            let imageData = NSData.init(contentsOfURL: destinationUrl)
            
            
            
//            if imageData != nil {
//                
//                FacebookController().shareImageFileToFacebook(UIImage.init(data: imageData!)!, placeID: "", complition: { (connection, response, error) -> Void in
//                    
//                    if error == nil {
//                        
//                        let checkAlert = UIAlertController(title: "Success", message: "Image have been posted", preferredStyle: UIAlertControllerStyle.Alert)
//                        checkAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
//                            
//                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
//                        }))
//                        self.presentViewController(checkAlert, animated: true, completion: nil)
//                        
//                    } else {
//                        
//                        let checkAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
//                        checkAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
//                            
//                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
//                        }))
//                        self.presentViewController(checkAlert, animated: true, completion: nil)
//                    }
//                })
//                
//            } else {
            
                fbController.shareImageToFacebook(self, thumbImage: image.ImageThumbUrl!, placeId: result.Facebook!, fullImage: image.ImageUrl!)
//            }
            
        }
    }
    
    
    
    func downloadFile(imageUrl: String) {
        
//        if let audioUrl = NSURL(string: imageUrl) {
//            
//            let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
//            
//            let imagePath = audioUrl.absoluteString.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//            
//            let destinationUrl = documentsUrl!.URLByAppendingPathComponent(imagePath)
//            print(destinationUrl, terminator: "")
//            
//            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
//                
//                print("The file already exists at path", terminator: "")
//            } else {
//
//                if let myAudioDataFromUrl = NSData(contentsOfURL: audioUrl){
//                    
//                    if myAudioDataFromUrl.writeToURL(destinationUrl, atomically: true) {
//                        
//                    } else {
//                        
//                    }
//                }
//            }
//        }
    }
    
    
    func onGetDataFailed(error: String!) {
        print(error, terminator: "")
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ImageGalleryViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("imageGalleryIdentifier", forIndexPath: indexPath) as! ImageGalleryViewCell
        
        let imageUrl = self.userImages[indexPath.row].ImageThumbUrl
        
        if imageUrl != nil {
            cell.thumbImage.sd_setImageWithURL(NSURL(string: imageUrl!))
        }
        cell.setActions();
        cell.buttonDelegate = self
        cell.radioButton.selected = self.selectedImagesArray[indexPath.row] as! Bool
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let width = screenSize.width
//        let height = screenSize.height
        return CGSizeMake((width - 50) / 2, (width - 50) / 2 * 0.6)
    }
    
    func onImageClicked(selectedCell: ImageGalleryViewCell) {
        
        let checkedPath: NSIndexPath = self.imageGallery.indexPathForCell(selectedCell)!
        let imageInfo = JTSImageInfo()
        imageInfo.imageURL = NSURL(string: self.userImages[checkedPath.row].ImageUrl!)
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
        imageViewer.showFromViewController(self.parentViewController, transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }
    
    func onRadioClicked(flag: Bool, selectedCell: ImageGalleryViewCell) {
        
        let checkedPath: NSIndexPath = self.imageGallery.indexPathForCell(selectedCell)!
        
        self.selectedImagesArray = Array.init(count: self.userImages.count, repeatedValue: false)
        
        self.selectedImagesArray[checkedPath.row] = true
        
        self.imageGallery.reloadData()
        
//        if flag == true {
//            
//            if selectedImageIndex != -1 {
//                
//                
//            }
//            
////            for section in 0..<self.imageGallery.numberOfSections(){
////                if section == checkedPath.section{
////                    for row in 0..<self.imageGallery.numberOfItemsInSection(section){
////                        let cellPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)
////                        let cell = try self.imageGallery.cellForItemAtIndexPath(cellPath) as! ImageGalleryViewCell
////                        if checkedPath.row != cellPath.row {
////                            cell.unCheckRadio()
////                        }
////                    }
////                }
////            }
//
//        } else {
//            
//            selectedImageIndex = -1
//        }
        
        selectedImageIndex = checkedPath.row
    }
    
    func onSuccess(type: Int, action: Int, userData: AnyObject) {
        
    }
    
    func onFailure(type: Int, action: Int) {
        
    }
    
    @IBAction func shareButtonClicked(sender: AnyObject) {
        if selectedImageIndex == -1 {
            let checkAlert = UIAlertController(title: "Select Image", message: "Please select image to share", preferredStyle: UIAlertControllerStyle.Alert)
            checkAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
            }))
            presentViewController(checkAlert, animated: true, completion: nil)
        } else {
            print("Share image on Facebook", terminator: "")
            // Share Image on Facebook
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.imageDBController.aGetDataDelegate = self
            self.imageDBController.getImage(self.userImages[selectedImageIndex].ImageId)
        }
    }

}
