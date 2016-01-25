//
//  LoginViewController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/20/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import UIKit
import AWSDynamoDB
import MBProgressHUD

class LoginViewController: UIViewController, SocialControllerDelegate, AWSDynamoDBGetDataDelegate, AWSControllerDelegate{

    @IBOutlet weak var loginWithFacebookButton: CustomSocialButton!    
//    @IBOutlet weak var loginWithTwitterButton: CustomSocialButton!
//    @IBOutlet weak var loginWithGoogleButton: CustomSocialButton!
    
    var fbController = FacebookController()
//    var twitterController = TwitterController()
//    var googleController = GoogleController()
    
    var userDBController = UserDBController()
    var userFacebookDBController = UserFacebookDBController()
    
    var email: String!
    var facebookId: String!
    var firstName: String!
    var lastName: String!
    var userId: String!
    
    var delegateCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().objectForKey(kUserId) != nil
        {
            gotoNext()
        }
        
        fbController.mDelegate = self
//        twitterController.mDelegate = self
//        googleController.mDelegate = self
        
        userDBController.aDelegate = self
        userDBController.aGetDataDelegate = self
        
        userFacebookDBController.aDelegate = self
        userFacebookDBController.aGetDataDelegate = self
        
        setActions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setActions() {
        let fbTapGesture = UITapGestureRecognizer(target: self, action: "loginWithFacebook:")
        loginWithFacebookButton.addGestureRecognizer(fbTapGesture)
        
//        var twitterTapGesture = UITapGestureRecognizer(target: self, action: "loginWithTwitter:")
//        loginWithTwitterButton.addGestureRecognizer(twitterTapGesture)
//        
//        var googleTapGesture = UITapGestureRecognizer(target: self, action: "loginWithGoogle:")
//        loginWithGoogleButton.addGestureRecognizer(googleTapGesture)
    }
    
//    func loginWithTwitter(sender: AnyObject){
//        twitterController.twitterLogIn()
//    }
//    
//    func loginWithGoogle(sender: AnyObject){
//        googleController.gPlusLogin()
//    }
    
    func loginWithFacebook(sender: AnyObject) {
        fbController.fbLogin()
    }
    //Social Controller Delegate
    func onSuccess(type: Int, action: Int, userData: AnyObject) {
        self.email = userData.objectForKey("email") as! String
        self.facebookId = userData.objectForKey("id") as! String
        self.firstName = userData.objectForKey("first_name") as! String
        self.lastName = userData.objectForKey("last_name") as! String
        
        var progressDg = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        self.userFacebookDBController.checkFacebookUser(self.facebookId)
    }
    
    func onFailure(type: Int, action: Int) {
        print("Login Failure", terminator: "")
    }
    
    //AWSDBGetData Delegate
    func onGetDataSuccess(datas: Array<AnyObject>!, type: Int) {
        if type == USER_DB{
            print("User count: " + String(datas.count), terminator: "")
            self.userId = String(datas.count + 1)
            self.userDBController.insertUser(String(datas.count + 1), email: self.email, firstName: self.firstName, lastName: self.lastName)
            self.userFacebookDBController.insertFacebookUser(self.facebookId, userId: String(datas.count + 1), email: self.email)
        }
        if type == FACEBOOK_USER_DB && datas.count > 0{
            let fbUser = datas[0] as! UserFacebookMapper
            NSUserDefaults.standardUserDefaults().setObject(fbUser.UserId, forKey: kUserId)
            gotoNext()
        }else if type == FACEBOOK_USER_DB && datas.count == 0{
            userDBController.getUsers()
        }
    }
    func onGetDataFailed(error: String!) {
        
    }
    
    //AWS Controller Delegate
    func onAWSTaskSuccess(type: Int) {
        if type == USER_DB{
            self.delegateCount++
            NSUserDefaults.standardUserDefaults().setObject(self.userId, forKey: kUserId)
        }
        if type == FACEBOOK_USER_DB{
            self.delegateCount++
        }
        if self.delegateCount == 2{
            self.delegateCount = 0
            gotoNext()
        }
    }
    func onAWSTaskFailed(error: String!) {
        
    }
    
    func gotoNext(){
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        
        var window = UIApplication.sharedApplication().delegate?.window
        window!!.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("mainviewcontroller") as! MainViewController
    }

}