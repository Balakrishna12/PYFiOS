//
//  CustomRatingBar.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/28/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import UIKit

class CustomRatingBar: UIView {
    
    @IBInspectable var ratingMax: CGFloat = 5
    @IBInspectable var numStars = 5
    @IBInspectable var canAnimation = false
    @IBInspectable var animationTimeInterval: NSTimeInterval = 0.2
    @IBInspectable var incomplete = false
    @IBInspectable var isIndicator = false
    @IBInspectable var imageLight: UIImage = UIImage(named: "btn_star_a")!
    @IBInspectable var imageDark: UIImage = UIImage(named: "btn_star_b")!
    
    var foregroundRatingView: UIView!
    var backgroundRatingView: UIView!
    
    var delegate: RatingBarDelegate?
    var isDrew = false
    
    @IBInspectable var rating: CGFloat = 0{
        didSet{
            if 0 > rating {
                rating = 0
            }else if ratingMax < rating{
                rating = ratingMax
            }
            delegate?.ratingDidChange(self, rating: rating)
            self.setNeedsLayout()
        }
    }
    
    func buildView(){
        if isDrew {return}
        isDrew = true
        
        self.backgroundRatingView = self.createRatingView(imageDark)
        self.foregroundRatingView = self.createRatingView(imageLight)
        animationRatingChange()
        self.addSubview(self.backgroundRatingView)
        self.addSubview(self.foregroundRatingView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapRateView:")
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        buildView()
        let animationTimeInterval = self.canAnimation ? self.animationTimeInterval : 0
        
        UIView.animateWithDuration(animationTimeInterval, animations: {self.animationRatingChange()})
    }
    
    func animationRatingChange(){
        let realRatingScore = self.rating / self.ratingMax
        self.foregroundRatingView.frame = CGRectMake(0, 0,self.bounds.size.width * realRatingScore, self.bounds.size.height)
        
    }
    
    func createRatingView(image: UIImage) ->UIView{
        let view = UIView(frame: self.bounds)
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clearColor()
        
        for position in 0 ..< numStars{
            let imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(CGFloat(position) * self.bounds.size.width / CGFloat(numStars), 0, self.bounds.size.width / CGFloat(numStars), self.bounds.size.height)
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            view.addSubview(imageView)
        }
        return view
    }
    
    func tapRateView(sender: UITapGestureRecognizer){
        if isIndicator {return}
        let tapPoint = sender.locationInView(self)
        let offset = tapPoint.x
        
        let realRatingScore = offset / (self.bounds.size.width / ratingMax);
        self.rating = self.incomplete ? realRatingScore : round(realRatingScore)
        
    }
}

protocol RatingBarDelegate{
    func ratingDidChange(ratingBar: CustomRatingBar,rating: CGFloat)
}