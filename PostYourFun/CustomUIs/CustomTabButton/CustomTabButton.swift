//
//  CustomTabButton.swift
//  PostYourFun
//
//  Created by Simon Weingand on 7/21/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import UIKit

protocol CustomTabButtonDelegate {
    func didSelectTabButton(selected: Bool, identifier: Int)
}
class CustomTabButton: UIButton {

    @IBOutlet var delegate: AnyObject?
    
    var mDelegate: CustomTabButtonDelegate? {
        return delegate as? CustomTabButtonDelegate
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    init(frame: CGRect, title: String, selected: Bool) {
        super.init(frame: frame);
        
        self.setTitle(title, forState: UIControlState.Normal)
        self.initialize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    func initialize() {
        self.addTarget(self, action: "onTouchUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func onTouchUpInside(sender: UIButton) {
        self.selected = true
        mDelegate?.didSelectTabButton(self.selected, identifier: self.tag)
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        selectedTapButton(self.selected)
    }
    
    func selectedTapButton(isSelected: Bool) {
        if isSelected == true
        {
            self.backgroundColor = UIColor(red: 153.0 / 255.0, green: 193.0 / 255.0, blue: 1.0, alpha: 1.0)
        }
        else
        {
            self.backgroundColor = UIColor(red: 0, green: 100.0 / 255.0, blue: 1.0, alpha: 1.0)
        }
    }
}
