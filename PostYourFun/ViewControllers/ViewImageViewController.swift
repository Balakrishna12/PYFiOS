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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userImageDBController.aGetDataDelegate = self
        deviceDBController.aGetDataDelegate = self
        fbController.mDelegate = self
        imageDBController.aGetDataDelegate = self
        parkSocialDBController.aGetDataDelegate = self
        
        userId = NSUserDefaults.standardUserDefaults().objectForKey(kUserId) as? String
    }

    override func viewDidAppear(animated: Bool) {
        userImageDBController.readTransactions(self.userId)
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        selectedImageIndex = -1
    }
    
    func onGetDataSuccess(datas: Array<AnyObject>!, type: Int) {
        if type == USERIMAGE_DB{
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.userImages = datas as! Array<UserImagesMapper>
            self.imageGallery.reloadData()
        }
        if type == IMAGE_DB{
            var images = datas as! Array<ImageMapper>
            var image = images[0]
            deviceDBController.getDevice(image.DeviceId!)
        }
        if type == DEVICE_DB{
            var devices = datas as! Array<DeviceMapper>
            var device = devices[0]
            parkSocialDBController.getParkSocialMediaInfo(device.ParkId!)
        }
        if type == PARK_SOCIAL_DB{
            var results = datas as! Array<ParkSocialMediaMapper>
            var result = results[0]
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            fbController.shareImageToFacebook(self, thumbImage: self.userImages[selectedImageIndex].ImageThumbUrl!, placeId: result.Facebook!, fullImage: self.userImages[selectedImageIndex].ImageUrl!)
        }
    }
    
    func onGetDataFailed(error: String!) {
        print(error, terminator: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ImageGalleryViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("imageGalleryIdentifier", forIndexPath: indexPath) as! ImageGalleryViewCell
        var imageUrl = self.userImages[indexPath.row].ImageThumbUrl
        cell.thumbImage.sd_setImageWithURL(NSURL(string: imageUrl!))
        cell.setActions();
        cell.buttonDelegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let width = screenSize.width
        let height = screenSize.height
        return CGSizeMake((width - 50) / 2, (width - 50) / 2 * 0.6)
    }
    
    func onImageClicked(selectedCell: ImageGalleryViewCell) {
        var checkedPath: NSIndexPath = self.imageGallery.indexPathForCell(selectedCell)!        
        var imageInfo = JTSImageInfo()
        imageInfo.imageURL = NSURL(string: self.userImages[checkedPath.row].ImageUrl!)
        var imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
        imageViewer.showFromViewController(self.parentViewController, transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }
    
    func onRadioClicked(flag: Bool, selectedCell: ImageGalleryViewCell) {
        if flag == true{
            let checkedPath: NSIndexPath = self.imageGallery.indexPathForCell(selectedCell)!
            for section in 0..<self.imageGallery.numberOfSections(){
                if section == checkedPath.section{
                    for row in 0..<self.imageGallery.numberOfItemsInSection(section){
                        let cellPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)
                        let cell: ImageGalleryViewCell = self.imageGallery.cellForItemAtIndexPath(cellPath) as! ImageGalleryViewCell
                        if checkedPath.row != cellPath.row {
                            cell.unCheckRadio()
                        }
                    }
                }
            }
            selectedImageIndex = checkedPath.row
        } else{
            selectedImageIndex = -1
        }
    }
    
    func onSuccess(type: Int, action: Int, userData: AnyObject) {
        
    }
    
    func onFailure(type: Int, action: Int) {
        
    }
    
    @IBAction func shareButtonClicked(sender: AnyObject) {
        if selectedImageIndex == -1{
            var checkAlert = UIAlertController(title: "Select Image", message: "Please select image to share", preferredStyle: UIAlertControllerStyle.Alert)
            checkAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
            }))
            presentViewController(checkAlert, animated: true, completion: nil)
        }else{
            print("Share image on Facebook", terminator: "")
            // Share Image on Facebook
            var progressDg = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.imageDBController.getImage(self.userImages[selectedImageIndex].ImageId)
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

}
