//
//  GoogleController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/23/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation

class GoogleController: GPPSignInDelegate{

    var signIn = GPPSignIn.sharedInstance()
    var mDelegate: SocialControllerDelegate!
    var userData: AnyObject!
    var credentialProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.EUWest1, identityPoolId: kCognitoIdentityID)
    
    func gPlusLogin(){
        signIn.shouldFetchGooglePlusUser = true
        signIn.clientID = kGoogleClientID
        signIn.shouldFetchGoogleUserEmail = true
        signIn.shouldFetchGoogleUserID = true
        signIn.scopes = [kGTLAuthScopePlusLogin]
        signIn.delegate = self
        signIn.authenticate()
    }
    
    @objc func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
//        self.mDelegate.onSuccess(GOOGLPLUS, action:actionLogin, )
//        self.credentialProvider.logins = ["accounts.google.com": auth.parameters.objectForKey("id_token")]
    }
    
    func getUserData(auth: GTMOAuth2Authentication){
        let user = GPPSignIn.sharedInstance().googlePlusUser
        print(user.name.JSONString(), terminator: "")
    }
}