//
//  TwitterController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/23/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterController{
    
    var mDelegate: SocialControllerDelegate!
    var userData: AnyObject!
    var credentialProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.EUWest1, identityPoolId: kCognitoIdentityID)
    
    func twitterLogIn(){
        Twitter.sharedInstance().logInWithCompletion{ (session, error) -> Void in
            if session != nil{
                self.getTwitterUserData(session)
                let value = session!.authToken + ";" + session!.authTokenSecret
                self.credentialProvider.logins = ["api.twitter.com": value]
            }
        }
        print("Login Twitter Button", terminator: "")
    }
    
    func getTwitterUserData(session: TWTRSession!){
        if session != nil{
            print(session.userName)
            self.mDelegate.onSuccess(TWITTER, action: actionLogin, userData: session)
        }
        
    }
}