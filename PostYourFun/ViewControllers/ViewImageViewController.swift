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
            
//            let document = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//            let writePath = document.stringByAppendingString("/" + image.ImageId! + ".JPG")
//            
//            if (NSFileManager.defaultManager().fileExistsAtPath(writePath)) {
//                print("There is such photo in library")
//            } else {
//                print("There is not such photo in library")
//            }
            
            
            fbController.shareImageToFacebook(self, thumbImage: image.ImageThumbUrl!, placeId: result.Facebook!, fullImage: image.ImageUrl!)
            
        }
    }
    
    
    
    func downloadFile(imageUrl: String) {

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
