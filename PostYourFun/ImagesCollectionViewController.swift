//
//  ImagesCollectionViewController.swift
//  PostYourFun
//
//  Created by Yuri Rudenya on 1/15/16.
//  Copyright © 2016 Simon Weingand. All rights reserved.
//

import UIKit
import MBProgressHUD

class ImagesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, AWSDynamoDBGetDataDelegate, PayPalPaymentDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imagesArray: [AnyObject] = []
    var freeDownload : Bool = false
    
    var userID: String!
    
    var userImagesArray: Array<UserImagesMapper> = []
    var userImageUrls: Array<String> = []
    var userImageDBController: UserImageDBController = UserImageDBController()
    
    var selectedImageName: String!
    var gotImage: ImageMapper!
    var selectedImageUrl: String!
    
    var config = PayPalConfiguration()
    
    var imageDownloadDelegate: ImageDownloadDelegate!
    
    let reuseIdentifier = "ImageCollectionCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getUserImages()
    }
    
    func getUserImages() {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        self.userID = NSUserDefaults.standardUserDefaults().objectForKey(kUserId) as! String
        
        userImageDBController.aGetDataDelegate = self
        userImageDBController.readTransactions(self.userID)
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
        imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: imageView, action: "removeFromSuperview"))
        
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
        button.addTarget(self, action: "buyImage:", forControlEvents: UIControlEvents.TouchUpInside)
        
        imageView.addSubview(button)
        
        self.view.addSubview(imageView)
        
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
        
        if (self.selectedImageName == nil){
        
            let checkAlert = UIAlertController(title: "No Image", message: "Please select image", preferredStyle: UIAlertControllerStyle.Alert)
            
            checkAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }))
            presentViewController(checkAlert, animated: true, completion: nil)
            
        } else if(!self.userImageUrls.contains((IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!))) {
            if (freeDownload){
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.selectedImageUrl = IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!
                downloadFile(self.selectedImageUrl)
            }else{
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                if (!payment.processable) {
                    print("You messed up!", terminator: "")
                } else {
                    print("Payment start", terminator: "")
                    let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: config, delegate: self)
                    self.presentViewController(paymentViewController!, animated: false, completion: nil)
                }
            }
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
            let destinationUrl = documentsUrl!.URLByAppendingPathComponent(audioUrl.lastPathComponent!)
            print(destinationUrl, terminator: "")
            // check if it exists before downloading it
            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
                print("The file already exists at path", terminator: "")
                self.imageDownloadDelegate.downloadFailed()
            } else {
                //  if the file doesn't exist
                //  just download the data from your url
                if let myAudioDataFromUrl = NSData(contentsOfURL: audioUrl){
                    // after downloading your data you need to save it to your destination url
                    if myAudioDataFromUrl.writeToURL(destinationUrl, atomically: true) {
                        self.imageDownloadDelegate.downloadSuccess()
                    } else {
                        self.imageDownloadDelegate.downloadFailed()
                    }
                }
            }
        }
    }
    

}
