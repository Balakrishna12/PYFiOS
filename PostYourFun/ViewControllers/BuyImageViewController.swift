//
//  BuyImageViewController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/20/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import UIKit
import MBProgressHUD

//protocol ImageDownloadDelegate{
//    func downloadSuccess()
//    func downloadFailed()
//}

class BuyImageViewController: UIViewController, SocialControllerDelegate, AWSDynamoDBGetDataDelegate, AWSControllerDelegate, CustomTextFieldDelegate, PayPalPaymentDelegate, ImageDownloadDelegate {

    @IBOutlet weak var parkTextField: CustomTextField!
    @IBOutlet weak var rideTextField: CustomTextField!
    @IBOutlet weak var imageNumber: CustomTextField!
    @IBOutlet weak var btnGetImage: UIButton!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var btnBuyImage: UIButton!
    @IBOutlet weak var lblImagePrice: UILabel!
    
    var parks: Array<ParkMapper>!
    var rides: Array<DeviceMapper>!
    var parkNames = Array<String>()
    var rideNames = Array<String>()
    
    var selectedParkId: String!
    var selectedDevice: DeviceMapper!
    var freeDownload = false
    
    var selectedDevices = Array<DeviceMapper>()
    var userImages: Array<UserImagesMapper> = Array<UserImagesMapper>()
    var parkSocialInfos = Array<ParkSocialMediaMapper>()
    
    var parkDBController = ParkDBController()
    var deviceDBController = DeviceDBController()
    var imageQueryDBController = ImageQueryDBController()
    var imageDBController = ImageDBController()
    var userImageDBController = UserImageDBController()
    var parkSocialDBController = ParkSocialMediaDBcontroller()
    
    var config = PayPalConfiguration()
    
    var userId: String!
    var gotImage: ImageMapper!
    var selectedImageName: String!
    var selectedImageUrl: String!
    
    var userImageUrls = Array<String>()
    var fbController = FacebookController()
    
    var imageDownloadDelegate: ImageDownloadDelegate!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.parkDBController.aGetDataDelegate = self
        self.deviceDBController.aGetDataDelegate = self
        self.imageQueryDBController.aGetDataDelegate = self
        self.imageDBController.aGetDataDelegate = self
        self.userImageDBController.aGetDataDelegate = self
        self.userImageDBController.aDelegate = self
        self.parkSocialDBController.aGetDataDelegate = self
        
        self.imageDownloadDelegate = self
        self.fbController.mDelegate = self
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
//        selectedImage.image = UIImage(named: "default_image")
        
        userId = NSUserDefaults.standardUserDefaults().objectForKey(kUserId) as? String
        
        parkSocialDBController.getAllParkSocialInfos()
        
        self.freeDownload = false
    }

    override func viewDidAppear(animated: Bool) {
        userImageDBController.readTransactions(self.userId)
    }

    
    func onGetDataSuccess(datas: Array<AnyObject>!, type: Int) {
        
        if type == PARK_SOCIAL_DB {
            self.parkSocialInfos = datas as! Array<ParkSocialMediaMapper>
            self.parkDBController.getAllParks()
        }
        if type == PARK_DB {
            
            self.parks = datas as! Array<ParkMapper>
            print(self.parks.count, terminator: "")
            
            for park in self.parks{
                self.parkNames.append(park.Name!)
            }
            self.deviceDBController.getAllDevices()
        }
        
        if type == DEVICE_DB {
            
            self.rides = datas as! Array<DeviceMapper>
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            self.initView()
            
            let parksData = NSKeyedArchiver.archivedDataWithRootObject(self.parks)
            let rideData = NSKeyedArchiver.archivedDataWithRootObject(self.rides)
            
            NSUserDefaults.standardUserDefaults().setObject(parksData, forKey: kParks)
            NSUserDefaults.standardUserDefaults().setObject(rideData, forKey: kDevices)
        }
        
        if type == IMAGEQUERY_DB {
            var image = datas as! Array<ImageQueryMapper>
            if image.count > 0 {
                self.imageDBController.getImage(image[0].ImageId)
            }
        }
        if type == IMAGE_DB {
            
            let image = datas as! Array<ImageMapper>
            
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ImagesCollectionViewController") as! ImagesCollectionViewController
            
            controller.imagesArray = image
            controller.selectedParkId = self.selectedParkId
            controller.parkSocialInfos = self.parkSocialInfos
            controller.freeDownload = self.freeDownload
            
            self.presentViewController(controller, animated: true, completion: nil)
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
        if type == USERIMAGE_DB{
            self.userImages = datas as! Array<UserImagesMapper>
            self.userImageUrls.removeAll()
            for userImage in self.userImages{
                self.userImageUrls.append(userImage.ImageUrl!)
            }
        }
    }

    func onGetDataFailed(error: String!) {
        
    }
    
    func initView() {
        
        parkTextField.setTextFieldType(.Picker)
        parkTextField.pickerDatas = self.parkNames
        parkTextField.mDelegate = self
        parkTextField.text = parks[0].Name
        
        rideTextField.setTextFieldType(.Picker)
        rideTextField.mDelegate = self

        let selectedPark = parks[0]
        
        if (selectedPark.AllInclusive == 1) {
            self.freeDownload = true
        } else {
            self.freeDownload = false
        }
        
        for ride in self.rides {
            if ride.ParkId == selectedPark.ParkId {
                self.selectedDevices.append(ride)
                self.rideNames.append(ride.Name!)
            }
        }
        rideTextField.changePickerDatas(self.rideNames)
        self.selectedDevice = self.selectedDevices[0]
    }
    
    // MARK: - CustomTextFieldDelegate
    func customTextFieldDidEndEditing(sender: AnyObject)
    {
        let textField = sender as! CustomTextField
        let index = textField.pickerIndex
        
        if parkTextField == textField
        {
            selectedDevices.removeAll()
            rideNames.removeAll()
            
            if index != nil {
                let selectedPark = self.parks[index]
                print(selectedPark.AllInclusive, terminator: "")
                print(selectedPark.Name, terminator: "")
                for ride in self.rides{
                    if ride.ParkId == selectedPark.ParkId{
                        self.selectedDevices.append(ride)
                        self.rideNames.append(ride.Name!)
                    }
                }
                rideTextField.changePickerDatas(self.rideNames)
                self.selectedParkId = self.parks[index].ParkId
                self.selectedDevice = self.selectedDevices[0]
                if (selectedPark.AllInclusive == 1) {
                    self.lblImagePrice.text = ""
                    self.freeDownload = true
                } else{
                    self.lblImagePrice.text = "8 EUR for full quality image"
                    self.freeDownload = false
                }
            }
        } else if rideTextField == textField {
            self.selectedDevice = self.selectedDevices[index]
        }
    }

    @IBAction func getImage(sender: AnyObject) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        if (self.selectedDevice.HasMonitor.boolValue == false) {
            imageQueryDBController.getImageInfoForAllDevices(self.selectedDevices, displayID: "")
        } else {
            imageQueryDBController.getImageInfo(self.selectedDevice, displayID: "")
        }
        
    }
    
    @IBAction func buyImage(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let amount = NSDecimalNumber(string: "8.00")
        print("amount \(amount)", terminator: "")
        
        let payment = PayPalPayment()
        payment.amount = amount
        payment.currencyCode = "EUR"
        payment.shortDescription = self.selectedImageName
        
        if (self.selectedImageName == nil){
            print("Get Image First", terminator: "")
//            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            let checkAlert = UIAlertController(title: "No Image", message: "Please select image", preferredStyle: UIAlertControllerStyle.Alert)
            checkAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                print("no image", terminator: "")
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }))
            presentViewController(checkAlert, animated: true, completion: nil)
        } else if(!self.userImageUrls.contains((IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!)))   {
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
        } else if(self.userImageUrls.contains((IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!))){
            let checkAlert = UIAlertController(title: "Bought Image", message: "Already got this image", preferredStyle: UIAlertControllerStyle.Alert)
            checkAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                print("Got image", terminator: "")
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }))
            presentViewController(checkAlert, animated: true, completion: nil)

        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        self.fbController.logout()
        
        let window = UIApplication.sharedApplication().delegate?.window
        window!!.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
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
    
    //AWS task delegate
    func onAWSTaskSuccess(type: Int) {
        
        if type == USERIMAGE_DB {
            
            print("Buy image", terminator: "")
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            let confirmAlert = UIAlertController(title: "Share Image", message: "Share this image with Facebook", preferredStyle: UIAlertControllerStyle.Alert)
            confirmAlert.addAction(UIAlertAction(title: "Share", style: .Default, handler: { (action: UIAlertAction) -> Void in
                print("Share image", terminator: "")
                var placeId: String = ""
                for index in 0..<self.parkSocialInfos.count{
                    if self.selectedParkId == self.parkSocialInfos[index].ParkId {
                        placeId = self.parkSocialInfos[index].Facebook!
                    }                    
                }
                self.fbController.shareImageToFacebook(self, thumbImage: IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_THUMB_STRING + self.gotImage.Name!, placeId: placeId, fullImage: IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!)
            }))
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) -> Void in
                print("Cancel share image", terminator: "")
            }))
            
            presentViewController(confirmAlert, animated: true, completion: nil)
        }
    }
    func onAWSTaskFailed(error: String!) {
        print(error, terminator: "")
    }
    
    func getDateTime() -> String{
        let todaysDate:NSDate = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let DateInFormat:String = dateFormatter.stringFromDate(todaysDate)
        print(DateInFormat, terminator: "")
        return DateInFormat
    }
    
    func downloadSuccess() {
        print("file saved", terminator: "")
        let imageUrl = IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_FULL_STRING + self.gotImage.Name!
        let date = getDateTime()
        
        let thumbUrl = IMAGE_CONSTANT_URL + self.gotImage.Region! + IMAGE_THUMB_STRING + self.gotImage.Name!
        userImageDBController.registerPayment(userId, dateTime: date, imageId: self.gotImage.ImageId!, imageUrl: imageUrl, imageThumbUrl: thumbUrl)
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
    
    func onSuccess(type: Int, action: Int, userData: AnyObject) {
//        var progressDg = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    func onFailure(type: Int, action: Int) {
        
    }
}
