//
//  MainViewController.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/20/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, CustomTabButtonDelegate, BuyImageViewControllerDelegate {

    @IBOutlet weak var containerView: UIView!
    
    var rateViewController: RateViewController!
    var buyViewController: BuyImageViewController!
    var viewImageViewController: ViewImageViewController!
    
    var currentViewController: UIViewController!
    var currentTabIdentifier: Int!
    
    var currentSelectedDevice: DeviceMapper!
    var currentSelectedParkID: String!
    var currentSelectedParkName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentViewController == nil
        {
            didSelectTabButton(true, identifier: tagBuyTab)
        }
    }
    
    //MARK: Buy Image View Controller Delegate
    
    func buyImageViewControllerDidChangePark(parkID: String, parkName: String, device: DeviceMapper) {
        //print("PARK_ID:" + parkID + "/DEVICE_ID:" + device.DeviceId!)
        
        self.currentSelectedParkID = parkID
        self.currentSelectedDevice = device
        self.currentSelectedParkName = parkName
    }
    
    //MARK: Actions

    func didSelectTabButton(selected: Bool, identifier: Int) {
        for tag in tagBuyTab...tagViewTab
        {
            let tabButton = self.view.viewWithTag(tag) as! CustomTabButton
            if tag != identifier
            {
                tabButton.selected = false
            }
            else
            {
                tabButton.selected = true
            }
        }
        
        changeViewController(identifier)
    }
    
    func changeViewController(identifier: Int) {
        if currentTabIdentifier != nil && identifier == currentTabIdentifier
        {
            return
        }
        
        if identifier == tagBuyTab
        {
            if buyViewController == nil
            {
                buyViewController = self.storyboard?.instantiateViewControllerWithIdentifier("buyImageViewController") as! BuyImageViewController
                buyViewController.delegate = self
            }
            
            animationWithViewController(buyViewController, identifier: identifier)
        }
        else if identifier == tagRateTab
        {
            if rateViewController == nil
            {
                rateViewController = self.storyboard?.instantiateViewControllerWithIdentifier("rateViewController") as! RateViewController
            }
            
            rateViewController.selectedDevice = currentSelectedDevice
            rateViewController.selectedParkID = currentSelectedParkID
            rateViewController.selectedParkName = currentSelectedParkName
            
            animationWithViewController(rateViewController, identifier: identifier)
        }
        else
        {
            if viewImageViewController == nil
            {
                viewImageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("viewImageViewController") as! ViewImageViewController
            }
            
            animationWithViewController(viewImageViewController, identifier: identifier)
        }
    }
    
    func animationWithViewController(viewController: UIViewController!, identifier: Int)
    {
        if viewController == nil
        {
            return
        }
        
        let space = 142.0 as CGFloat
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height - space
        
        if currentViewController == nil
        {
            containerView.addSubview(viewController.view)
            self.addChildViewController(viewController)
            viewController.view.frame = CGRectMake(0, 0, width, height)
            
            viewController.didMoveToParentViewController(self)
            
            self.currentTabIdentifier = identifier
            self.currentViewController = viewController
        }
        else
        {
            if currentTabIdentifier < identifier
            {
                viewController.view.frame = CGRectMake(width, 0, width, height)
            }
            else
            {
                viewController.view.frame = CGRectMake(-width, 0, width, height)
            }
            
            containerView.addSubview(viewController.view)
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                    if self.currentTabIdentifier < identifier
                    {
                        if (identifier - self.currentTabIdentifier == 1) {
                            self.currentViewController.view.frame = CGRectMake(-width, 0, width, height)
                        } else {
                            self.currentViewController.view.frame = CGRectMake(-width*2, 0, width, height)
                        }
                    }
                    else
                    {
                        if (self.currentTabIdentifier - identifier == 1){
                            self.currentViewController.view.frame = CGRectMake(width, 0, width, height)
                        } else {
                            self.currentViewController.view.frame = CGRectMake(width*2, 0, width, height)
                        }
                    }
                    viewController.view.frame = CGRectMake(0, 0, width, height)
                    
                }, completion: { (Bool) -> Void in
                    
                    self.currentViewController.view.removeFromSuperview()
                    self.currentViewController.removeFromParentViewController()
                    
                    self.containerView.addSubview(viewController.view)
                    self.addChildViewController(viewController)
                    viewController.didMoveToParentViewController(self)
                    
                    self.currentTabIdentifier = identifier
                    self.currentViewController = viewController
                })
        }
    }
}
