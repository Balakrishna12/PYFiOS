//
//  CustomTextField.swift
//  ProFlyt
//
//  Created by Simon Weingand on 7/11/15.
//  Copyright (c) 2015 Simon Weingand. All rights reserved.
//

import Foundation
import UIKit

enum TextFieldType: Int {
    case Normal, Email, Date, DateAndTime, Picker
}

protocol CustomTextFieldDelegate {
    func customTextFieldDidEndEditing(sender: AnyObject)
}

class CustomTextField: UITextField, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var mDelegate: CustomTextFieldDelegate! = nil
    var enableEmpty: Bool = true
    var type: TextFieldType = .Normal
    var cornerRadius: CGFloat = 4.0
    var borderWidth: CGFloat = 1.0
    var borderColor: UIColor = UIColor(red: 193.0 / 255.0, green: 196.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
    var datePicker: UIDatePicker! = UIDatePicker()
    var picker: UIPickerView! = UIPickerView()
    var pickerDatas: Array<String>!
    var pickerIndex: Int!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
    }
    
    func initialize() {
        self.delegate = self
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 5)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 5)
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        layer.borderWidth = borderWidth
    }
    
    func setTextFieldEnableEmpty(enable: Bool) {
        self.enableEmpty = enable
    }
    
    func setTextFieldCornerRadius(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        self.layer.cornerRadius = cornerRadius
    }
    
    func setTextFieldBorderColor(borderColor:UIColor) {
        self.borderColor = borderColor
        self.layer.borderColor = borderColor.CGColor
    }
    
    func setTextFieldBorderWidth(borderWidth: CGFloat) {
        self.borderWidth = borderWidth
        self.layer.borderWidth = borderWidth
    }
    
    func setTextFieldType(textFieldType: TextFieldType) {
        type = textFieldType
        if type == .DateAndTime
        {
            datePicker.datePickerMode = UIDatePickerMode.DateAndTime
            datePicker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
            datePicker.minimumDate = NSDate()
            datePickerValueChanged(nil)
            self.inputView = datePicker
        }
        else if type == .Picker
        {
            picker = UIPickerView(frame: CGRectMake(0, 50, 100, 150))
            picker.dataSource = self
            picker.delegate = self
            picker.showsSelectionIndicator = true
            self.inputView = picker
        }
    }
    
    func setMinimumDateAndTime(var date: NSDate) {
        let now = NSDate()
        if date.compare(now) == .OrderedAscending
        {
            date = now
        }
        
        if datePicker.date.compare(date) == .OrderedAscending
        {
            datePicker.date = date
            datePickerValueChanged(nil)
        }
        datePicker.minimumDate = date
    }
    
    func setValid(valid:Bool) {
        if valid == true {
            self.layer.borderColor = borderColor.CGColor
        }
        else {
            self.layer.borderColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0).CGColor
        }
    }
    
    func checkValid() -> Bool {
        if enableEmpty == true && self.text!.isEmpty == false {
            if type == .Email {
                let emailRegEx =
                    "(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
                    "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
                    "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
                    "z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
                    "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
                    "9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
                    "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
                
                let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
                if emailTest.evaluateWithObject(self.text) == false {
                    self.setValid(false)
                    return false
                }
            }
            else if type == .DateAndTime && datePicker.date.compare(NSDate()) == .OrderedAscending {
                self.setValid(false)
                return false
            }
            self.setValid(true)
            return true
        }
        self.setValid(false)
        return false
    }
    
    func changePickerDatasWithIndex(datas: Array<String>, index: Int) {
        self.pickerDatas = datas
        self.picker.reloadAllComponents()
        self.pickerView(picker, didSelectRow:index, inComponent:0)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(sender: UITextField) {
        self.layer.borderColor = borderColor.CGColor
    }
    
    func textFieldDidEndEditing(sender: UITextField) {
        self.checkValid()
        if mDelegate != nil
        {
            mDelegate.customTextFieldDidEndEditing(self)
        }
    }
    
    func datePickerValueChanged(sender: AnyObject!) {
        if datePicker == nil
        {
            self.text = ""
        }
        else {
            let df = NSDateFormatter()
            df.dateFormat = "dd MMM, YYYY HH:mm a"
            self.text = df.stringFromDate(datePicker.date)
        }
    }
    
    
    // MARK: - UIPickerViewDataSource
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDatas.count;
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDatas[row] as String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = pickerDatas[row] as String
        pickerIndex = row
    }
    
    func changePickerDatas(datas: Array<String>) {
        self.pickerDatas = datas
        self.picker.reloadAllComponents()
        self.pickerView(picker, didSelectRow:0, inComponent:0)
    }
    

}
