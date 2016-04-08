//
//  FacebookController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/21/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class FacebookController {
    
    var mDelegate: SocialControllerDelegate!
    var userData: AnyObject!
//    var dataset: AWSCognitoDataset
    
    var credentialProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.EUWest1, identityPoolId: kCognitoIdentityID)
    
    func fbLogin(){
        
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logOut()
        
        fbLoginManager.logInWithPublishPermissions(["publish_actions"]) { (result, error) -> Void in
            
            if error == nil {
                let fbLoginResult: FBSDKLoginManagerLoginResult = result
                    if self.mDelegate != nil
                    {
                        self.credentialProvider.logins = ["graph.facebook.com": fbLoginResult.token.tokenString]
                        self.getFBUserData()
                    }
                }
        }
    }
    
    
    func logout() {
        FBSDKLoginManager().logOut()
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kUserId)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getFBUserData() {
        if (FBSDKAccessToken.currentAccessToken()) != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({(connection, result, error) -> Void in
                
                if error == nil {
                    print(result)
                    self.userData = result
                    let id = self.userData.objectForKey("id") as! String
                    print(id)
                    if self.mDelegate != nil
                    {
                        self.mDelegate.onSuccess(FACEBOOK, action: actionGetUserData, userData: result)
                    }
                }
            })
        }
    }
    
    func shareToFacebook(viewController: UIViewController, description: String!, parkName: String!, parkUrl: String!, imageUrl: String!, placeId: String!){
        let shareContent = FBSDKShareLinkContent()
        shareContent.contentURL = NSURL(string: parkUrl)
        shareContent.contentTitle = parkName
        shareContent.imageURL = NSURL(string: imageUrl)
        shareContent.contentDescription = description
        shareContent.placeID = placeId
        
        FBSDKShareDialog.showFromViewController(viewController, withContent: shareContent, delegate: nil)
    }
    
    func shareImageToFacebook(viewController: UIViewController, thumbImage: String, placeId: String, fullImage: String) {
        
        let shareLink: FBSDKShareLinkContent = FBSDKShareLinkContent()

        shareLink.imageURL = NSURL(string: thumbImage)
        shareLink.contentURL = NSURL(string: fullImage)
        shareLink.placeID = placeId
        shareLink.contentTitle = "Post Your Fun Image Share"
        
        FBSDKShareDialog.showFromViewController(viewController, withContent: shareLink, delegate: nil)
    }
    
    
    func shareImage(viewController: UIViewController, sharedImage: UIImage?) {
        
        let sharePhoto: FBSDKSharePhoto = FBSDKSharePhoto()
        
        sharePhoto.image = sharedImage
        sharePhoto.caption = "Post Your Fun Image Share"
        sharePhoto.userGenerated = true
        
        let content = FBSDKSharePhotoContent()
        content.photos = [ sharePhoto ]

        
        
        //FBSDKShareAPI.shareWithContent(content, delegate: nil)
        
        FBSDKShareDialog.showFromViewController(viewController, withContent: content, delegate: nil)
        
        
    }
    
}