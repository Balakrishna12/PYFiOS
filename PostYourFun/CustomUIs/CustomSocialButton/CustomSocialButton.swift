//
//  CustomSocialButton.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/20/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import UIKit

@IBDesignable class CustomSocialButton: UIView {

    var view: UIView!
    
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBInspectable var iconCharacter: String = "" {
        didSet {
            self.iconButton.setTitle(iconCharacter, forState: .Normal)
        }
    }
    
    @IBInspectable var title: String = "" {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    @IBInspectable var color: UIColor = UIColor()
    @IBInspectable var iconFontName: String = "Socialico" {
        didSet {
            self.iconButton.titleLabel!.font = UIFont(name: iconFontName, size: 40)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let layer = view.layer as CALayer
        layer.masksToBounds = true
        layer.cornerRadius = 4.0
        layer.backgroundColor = color.CGColor
        layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
        layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        view.clipsToBounds = false
    }
    
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "CustomSocialButton", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.alpha = 0.7
        view.layer.shadowOpacity = 0.0
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        self.alpha = 1.0
        view.layer.shadowOpacity = 0.5
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        self.alpha = 1.0
        view.layer.shadowOpacity = 0.5
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
    }

}
