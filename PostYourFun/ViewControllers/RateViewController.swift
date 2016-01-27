//
//  RateViewController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/21/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import UIKit
import MBProgressHUD

class RateViewController: UIViewController, CustomTextFieldDelegate, SocialControllerDelegate, AWSDynamoDBGetDataDelegate, AWSControllerDelegate {

    @IBOutlet weak var parkSelector: CustomTextField!
    @IBOutlet weak var rideSelector: CustomTextField!
    @IBOutlet weak var commentTextfield: UITextField!
    @IBOutlet weak var shareToFB: CustomSocialButton!
    
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var gForceRating: CustomRatingBar!
    @IBOutlet weak var adrenalinRating: CustomRatingBar!
    @IBOutlet weak var speedRating: CustomRatingBar!
    
    var parks: Array<ParkMapper>!
    var rides: Array<DeviceMapper>!
    var parkNames = Array<String>()
    var rideNames = Array<String>()
    
    var userId: String!
    
    var selectedParkId: String!
    var selectedDeviceId: String!
    var rateLabelText = "Rate your fun at the "
    var selectedDevices = Array<DeviceMapper>()
    
    var fbController = FacebookController()
    
    var deviceRatingDBController = DeviceRatingDBController()
    var parkInformationDBController = ParkInformationDBController()
    var parkSocialMediaDBController = ParkSocialMediaDBcontroller()
    
    var delegatecount = 0
    var selectedParkInfo: ParkInformationMapper!
    var selectedparkSocialInfo: ParkSocialMediaMapper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbController.mDelegate = self
        
        parkInformationDBController.aGetDataDelegate = self
        parkSocialMediaDBController.aGetDataDelegate = self
        
        let parkData = NSUserDefaults.standardUserDefaults().objectForKey(kParks) as? NSData
        let rideData = NSUserDefaults.standardUserDefaults().objectForKey(kDevices) as? NSData
        parks = NSKeyedUnarchiver.unarchiveObjectWithData(parkData!) as? Array<ParkMapper>
        rides = NSKeyedUnarchiver.unarchiveObjectWithData(rideData!) as? Array<DeviceMapper>
        
        userId = NSUserDefaults.standardUserDefaults().objectForKey(kUserId) as? String
        
        for park in self.parks{
            self.parkNames.append(park.Name!)
        }
        for ride in self.rides{
            self.rideNames.append(ride.Name!)
        }
        initView()
        // Do any additional setup after loading the view.
        setActions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView(){
        parkSelector.setTextFieldType(.Picker)
        parkSelector.changePickerDatas(self.parkNames)
        parkSelector.mDelegate = self
        
        rideSelector.setTextFieldType(.Picker)
        rideSelector.mDelegate = self
        rideNames.removeAll()
        let selectedPark = parks[0]
        for ride in self.rides{
            if ride.ParkId == selectedPark.ParkId{
                self.selectedDevices.append(ride)
                self.rideNames.append(ride.Name!)
            }
        }
        self.selectedParkId = self.parks[0].ParkId
        rideSelector.changePickerDatas(self.rideNames)
        self.selectedDeviceId = self.selectedDevices[0].DeviceId
        rateLabel.text = rateLabelText + rideSelector.text! + " in " + parkSelector.text!
    }

    func customTextFieldDidEndEditing(sender: AnyObject) {
        var textField = sender as! CustomTextField
        var index = textField.pickerIndex
        
        if parkSelector == textField
        {
            selectedDevices.removeAll()
            rideNames.removeAll()
            if index != nil{
                var selectedPark = parks[index]
                for ride in self.rides{
                    if ride.ParkId == selectedPark.ParkId{
                        self.selectedDevices.append(ride)
                        self.rideNames.append(ride.Name!)
                    }
                }
                rideSelector.changePickerDatas(self.rideNames)
                rateLabel.text = rateLabelText + rideSelector.text! + " in " + parkSelector.text!
            }
            self.selectedParkId = self.parks[index].ParkId
            self.selectedDeviceId = self.selectedDevices[0].DeviceId
        }else if rideSelector == textField{
            self.selectedDeviceId = self.rides[index].DeviceId
            rateLabel.text = rateLabelText + rideSelector.text! + " in " + parkSelector.text!
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func setActions(){
        let fbShareTapGesture = UITapGestureRecognizer(target: self, action: "shareWithFacebook:")
        shareToFB.addGestureRecognizer(fbShareTapGesture)
    }
    
    func shareWithFacebook(sender: AnyObject){
        parkInformationDBController.getParkInfo(self.selectedParkId)
        parkSocialMediaDBController.getParkSocialMediaInfo(self.selectedParkId)
    }
    
    func onSuccess(type: Int, action: Int, userData: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    func onFailure(type: Int, action: Int) {
        
    }
    
    func onGetDataSuccess(datas: Array<AnyObject>!, type: Int) {
        if type == PARK_INFO_DB{
            self.delegatecount++
            self.selectedParkInfo = datas[0] as! ParkInformationMapper
        }else if type == PARK_SOCIAL_DB{
            self.delegatecount++
            self.selectedparkSocialInfo = datas[0] as! ParkSocialMediaMapper
        }
        
        if self.delegatecount == 2{
            self.delegatecount = 0
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            let speedRate = Int(self.speedRating.rating)
            let g_force = Int(self.gForceRating.rating)
            let adrenaline = Int(self.adrenalinRating.rating)
            //Share to Facebook
            
//            FacebookController().shareToFacebook(self, description: generalFbShareText + self.rideSelector.text + " in " + self.parkSelector.text +
//                ". Speed " + String(speedRate) + "/5, G-Force " + String(g_force) + "/5 and Adrenaline kick " + String(adrenaline) + "/5." , parkName: self.parkSelector.text, parkUrl: self.selectedParkInfo.WebSite, imageUrl: self.selectedParkInfo.ImageUrl, placeId: self.selectedparkSocialInfo.Facebook)
            
            let description = generalFbShareText + self.rideSelector.text! + " in " + self.parkSelector.text! + ". Speed " + String(speedRate) + "/5, G-Force " + String(g_force) + "/5 and Adrenaline kick " + String(adrenaline) + "/5."
            
            FacebookController().shareToFacebook(self, description: description, parkName: self.parkSelector.text, parkUrl: self.selectedParkInfo.WebSite, imageUrl: self.selectedParkInfo.ImageUrl, placeId: self.selectedparkSocialInfo.Facebook)
            //Give Rating on AWS
            self.deviceRatingDBController.giveRating(self.userId, deviceId: self.selectedDeviceId, speedRate: String(speedRate), g_forceRate: String(g_force), adrenalineRate: String(adrenaline), comment: self.commentTextfield.text!)
        }
    }
    
    func onGetDataFailed(error: String!) {
        
    }
    
    func onAWSTaskSuccess(type: Int) {
        if type == RATE_DB{
        }
    }
    
    func onAWSTaskFailed(error: String!) {
        print(error, terminator: "")
    }
}
