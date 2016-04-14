//
//  ImagesCollectionViewController.swift
//  PostYourFun
//
//  Created by Yuri Rudenya on 1/15/16.
//  Copyright © 2016 Simon Weingand. All rights reserved.
//

import UIKit
import MBProgressHUD
import JTSImageViewController
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import SDWebImage
import AssetsLibrary


protocol ImageDownloadDelegate{
    func downloadSuccess()
    func downloadFailed()
}


class ImagesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, AWSDynamoDBGetDataDelegate, PayPalPaymentDelegate, AWSControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imagesArray: [AnyObject] = []
    
    var parkSocialInfos: [ParkSocialMediaMapper] = []
    var freeDownload : Bool = false
    var selectedParkId: String!
    var userID: String!
    
    var userImagesArray: Array<UserImagesMapper> = []
    var userImageUrls: Array<String> = []
    var userImageDBController: UserImageDBController = UserImageDBController()
    
    var selectedImageName: String!
    var gotImage: ImageMapper!
    var selectedImageUrl: String!
    var selectedImageIndex: Int!
    
    var config = PayPalConfiguration()
    
    var imageDownloadDelegate: ImageDownloadDelegate!
    
    let reuseIdentifier = "ImageCollectionCell"
    
    var selectedImageView: UIImageView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getUserImages()
    }
    
    //MARK: Internal
    
    func getUserImages() {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        self.userID = NSUserDefaults.standardUserDefaults().objectForKey(kUserId) as! String
        
        userImageDBController.aGetDataDelegate = self
        userImageDBController.aDelegate = self
        userImageDBController.readTransactions(self.userID)
    }
    
    func savePictureInPhotoAlbum(picture: UIImage!) {
        
       let customPhotoAlbum = CustomPhotoAlbum.sharedInstance
        customPhotoAlbum.saveImage(picture);

    }
    
    func saveToTemporaryFileWithImageURL(imageURL: NSURL!, completion: (result: Bool) -> Void){
            
        let document = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let writePath = document.stringByAppendingString("/" + self.gotImage.Name!)
        
        if (NSFileManager.defaultManager().fileExistsAtPath(writePath)) {
            print("There is such Photo in Library")
            
            completion(result: true)
            
        } else {
            print("There is not such Photo. Will save it")
            
            getDataFromUrl(imageURL) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    guard let data = data where error == nil else { return }
                    
                    data.writeToFile(writePath, atomically: true)
                    
                    let image = UIImage(data: data)
                    
                    if image != nil {
                        CustomPhotoAlbum.sharedInstance.saveImage(image!)
                    }
                    
                    completion(result: true)
                }
            }
        }
    }

    
    func getDataFromUrl(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
        
    }
    
    func onGetDataSuccess(datas: Array<AnyObject>!, type: Int) {
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        self.userImagesArray = datas as! Array<UserImagesMapper>
        
        self.userImageUrls.removeAll()
        for userImage in self.userImagesArray { 
            self.userImageUrls.append(userImage.ImageUrl!)
        }
    }
    
    func onGetDataFailed(error: String!) {
        self.getUserImages()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionCell
        
        cell.backgroundColor = UIColor.blackColor()
        
        let image = self.imagesArray[indexPath.row] as! ImageMapper
        
        let imageUrl = NSURL(string: IMAGE_CONSTANT_URL + image.Region! + IMAGE_THUMB_STRING + image.Name!)
        
        if let imageView = cell.imageView {
            imageView.sd_setImageWithURL(imageUrl);
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        selectedImageIndex = indexPath.row
        
        let image = self.imagesArray[indexPath.row] as! ImageMapper
        
        let imageUrl = NSURL(string: IMAGE_CONSTANT_URL + image.Region! + IMAGE_THUMB_STRING + image.Name!)
        
        self.selectedImageName = image.Name
        self.gotImage = image
        
        var frame = CGRectZero

        frame.size.width  = CGRectGetWidth(self.view.frame)
        frame.size.height = CGRectGetHeight(self.view.frame)
        
        let imageView = UIImageView.init(frame: frame)
        
        imageView.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        imageView.userInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: imageView, action: #selector(UIView.removeFromSuperview)))
        
        imageView.sd_setImageWithURL(imageUrl);
        
        
        frame = CGRectZero
        
        frame.size.width  = 200.0
        frame.size.height = 30.0
        frame.origin.x = (CGRectGetWidth(imageView.frame) - CGRectGetWidth(frame)) / 2.0
        frame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(frame) - 20
        
        let button = UIButton.init(type: UIButtonType.Custom)
        
        button.frame = frame
        button.setTitle("Download and Share", forState: UIControlState.Normal)
        button.backgroundColor = UIColor.init(red: 0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        button.addTarget(self, action: #selector(ImagesCollectionViewController.buyImage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        imageView.addSubview(button)
        
        self.view.addSubview(imageView)
        self.selectedImageView = imageView
        
    }
    
    @IBAction func didPressCancelButton(sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Buy image
    
    @IBAction func buyImage(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let amount = NSDecimalNumber(string: "8.00")
        print("amount \(amount)", terminator: "")
        
        let payment = PayPalPayment()
        payment.amount = amount
        payment.currencyCode = "EUR"
        payment.shortDescription = self.selectedImageName
        
        
        if (self.selectedImageName == nil) {
        
            let checkAlert = UIAlertController(title: "No Image", message: "Please select image", preferredStyle: UIAlertControllerStyle.Alert)
            
            checkAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }))
            presentViewController(checkAlert, animated: true, completion: nil)
            
        } else if (!self.userImageUrls.contains((IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!))) {
            
            let savedImage = self.imagesArray[selectedImageIndex] as! ImageMapper
            
            let savedImageURL = NSURL(string: IMAGE_CONSTANT_URL + savedImage.Region! + IMAGE_FULL_STRING + savedImage.Name!)
            
            self.saveToTemporaryFileWithImageURL(savedImageURL, completion: { (result) in
                
                if (self.freeDownload) {
                    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    
                    self.selectedImageUrl = IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!
                    
                    self.downloadSuccess()
                    
                }else{
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    
                    if (!payment.processable) {
                        print("You messed up!", terminator: "")
                        
                    } else {
                        print("Payment start", terminator: "")
                        let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: self.config, delegate: self)
                        self.presentViewController(paymentViewController!, animated: false, completion: nil)
                        
                    }
                }
                
            })
            
        } else if (self.userImageUrls.contains((IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!))) {
            
            let checkAlert = UIAlertController(title: "Bought Image", message: "Already got this image", preferredStyle: UIAlertControllerStyle.Alert)
            checkAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                print("Got image", terminator: "")
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }))
            presentViewController(checkAlert, animated: true, completion: nil)
            
        }
    }
    
    func getDateTime() -> String{
        let todaysDate:NSDate = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let DateInFormat:String = dateFormatter.stringFromDate(todaysDate)
        print(DateInFormat, terminator: "")
        return DateInFormat
    }
    
    //PayPalPayment Delegate
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController) {
        print("User canceled payment", terminator: "")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController, didCompletePayment completedPayment: PayPalPayment) {
        print("Payment Success", terminator: "")
        self.dismissViewControllerAnimated(true, completion: nil)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        downloadFile(IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!)
    }
    
    
    func downloadSuccess() {
        
        print("file saved", terminator: "")
        
        let imageUrl = IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!
        
        let date = getDateTime()
        
        let thumbUrl = IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_THUMB_STRING + self.gotImage.Name!
        
        userImageDBController.registerPayment(self.userID as String, dateTime: date, imageId: self.gotImage.ImageId!, imageUrl: imageUrl, imageThumbUrl: thumbUrl)

    }
    
    
    func downloadFailed() {
        print("error saving file", terminator: "")
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    func downloadFile(imageUrl: String){
        if let audioUrl = NSURL(string: imageUrl) {
            // create your document folder url
            let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
            // your destination file url
            
            let imagePath = audioUrl.absoluteString.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let destinationUrl = documentsUrl!.URLByAppendingPathComponent(imagePath)
            print(destinationUrl, terminator: "")
            // check if it exists before downloading it
            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
                print("The file already exists at path", terminator: "")
                let confirmAlert = UIAlertController(title: "Warning", message: "This image have been already bought", preferredStyle: UIAlertControllerStyle.Alert)
                
                confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) -> Void in
                    confirmAlert.dismissViewControllerAnimated(true, completion: nil)
                }))
                
                self.presentViewController(confirmAlert, animated: true, completion: nil)
                    
//                self.imageDownloadDelegate.downloadFailed()
                self.downloadFailed()
            } else {
                //  if the file doesn't exist
                //  just download the data from your url
                if let myAudioDataFromUrl = NSData(contentsOfURL: audioUrl){
                    // after downloading your data you need to save it to your destination url
                    if myAudioDataFromUrl.writeToURL(destinationUrl, atomically: true) {
//                        self.imageDownloadDelegate.downloadSuccess()
                        self.downloadSuccess()
                    } else {
//                        self.imageDownloadDelegate.downloadFailed()
                        self.downloadFailed()
                    }
                }
            }
        }
    }
    
 
    //AWS task delegate
    func onAWSTaskSuccess(type: Int) {
        
        if type == USERIMAGE_DB {
            
            print("Buy image", terminator: "")
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
//                var placeId = ""
//                
//                for parkInfo: ParkSocialMediaMapper in self.parkSocialInfos {
//                    if self.selectedParkId == parkInfo.ParkId {
//                        placeId = parkInfo.Facebook!
//                    }
//                }
            
            //let imagePath = IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!
            
            let document = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let writePath = document.stringByAppendingString("/" + self.gotImage.Name!)
            
            let image = UIImage(contentsOfFile: writePath)
            
            if image != nil {
                FacebookController().sharePicture(self, sharedImage: image)
            }
        }
    }
    
    func onAWSTaskFailed(error: String!) {
        
        print(error, terminator: "")
        
        let checkAlert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        checkAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }))
        presentViewController(checkAlert, animated: true, completion: nil)
    }
    
}
