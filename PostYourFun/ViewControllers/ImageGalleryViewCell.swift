//
//  ImageGalleryViewCell.swift
//  PostYourFun
//
//  Created by Simon Weingand on 8/10/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import UIKit

protocol CellImageClickDelegate{
    func onImageClicked(selectedCell: ImageGalleryViewCell)
    func onRadioClicked(flag: Bool, selectedCell: ImageGalleryViewCell)
}

class ImageGalleryViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var radioButton: UIButton!
    
    var buttonDelegate: CellImageClickDelegate!
    
    func setActions(){
        let imageTapGesture = UITapGestureRecognizer(target: self, action: "cellImageClicked:")
        thumbImage.addGestureRecognizer(imageTapGesture)
    
        let radioTapGesture = UITapGestureRecognizer(target: self, action: "cellRadioClicked:")
        radioButton.addGestureRecognizer(radioTapGesture)
        
        radioButton.selected = false
    }
    
    func cellImageClicked(sender: AnyObject){
        self.buttonDelegate.onImageClicked(self)
    }
    
    func cellRadioClicked(sender: AnyObject){
        if radioButton.selected != true{
            radioButton.selected = true
            
            if (self.buttonDelegate != nil) {
                self.buttonDelegate.onRadioClicked(true, selectedCell: self)
            }
        } else {
            radioButton.selected = false
            
            if (self.buttonDelegate != nil) {
                self.buttonDelegate.onRadioClicked(false, selectedCell: self)
            }
        }
    }
    
    func unCheckRadio(){
        radioButton.selected = false
    }
}
