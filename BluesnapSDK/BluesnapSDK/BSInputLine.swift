//
//  BSInputLine.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 17/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

protocol BSInputLineDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidEndEditing(_ textField: UITextField)
}

@IBDesignable
class BSInputLine: UIControl /*UIView*/ {

    // MARK: Configurable properties
    
    @IBInspectable var labelText: String! = "Label"
    @IBInspectable var labelTextColor: UIColor = UIColor.darkGray
    @IBInspectable var labelBkdColor: UIColor = UIColor.white
    @IBInspectable var fieldPlaceHolder: String! = ""
    @IBInspectable var image: UIImage?
    @IBInspectable var fieldTextColor: UIColor = UIColor.black
    @IBInspectable var fieldBkdColor: UIColor = UIColor.white
    @IBInspectable var keyboardType : UIKeyboardType = UIKeyboardType.default
    @IBInspectable var errorText: String! = "Please supply a valid value"
    @IBInspectable var delegate: BSInputLineDelegate?
    // This is just for debug
    @IBInspectable var errorOn: Bool! = false
    
    // MARK: ui elements
    
    internal var label : UILabel! = UILabel()
    internal var textField : UITextField! = UITextField()
    internal var imageView : UIImageView?
    internal var errorLabel : UILabel?

    // MARK: private properties
    
    var shouldSetupConstraints = true

    internal let totalWidth : CGFloat = 375
    internal let totalHeight : CGFloat = 40
    internal let leftMargin : CGFloat = 16
    internal let middleMargin : CGFloat = 8
    internal let rightMargin : CGFloat = 16
    internal let labelWidth : CGFloat = 100
    internal let labelHeight : CGFloat = 17
    internal let fieldHeight : CGFloat = 20
    internal let imageWidth : CGFloat = 21
    internal let imageHeight : CGFloat = 15
    internal let fontName = "Helvetica Neue"
    internal let fontSize : CGFloat = 14
    
    
    public func getValue() -> String! {
        return textField.text
    }
    
    public func setValue(_ newValue: String!) {
        textField.text = newValue
    }
    
    public func showError() {
        
        if errorLabel == nil {
            errorLabel = UILabel()
            self.addSubview(errorLabel!)
        }
        if let errorLabel = errorLabel {
            errorLabel.text = self.errorText
            errorLabel.backgroundColor = UIColor.red
            errorLabel.textColor = UIColor.white
            errorLabel.textAlignment = .right
            resizeError()
        }
    }

    public func hideError() {
        
        if let errorLabel = errorLabel {
            errorLabel.isHidden = true
        }
    }
    
    // MARK:- ---> Textfield Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //print("****************** TextField did begin editing method called")
        sendActions(for: UIControlEvents.editingDidBegin)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print("****************** TextField did end editing method called")
        sendActions(for: UIControlEvents.editingDidEnd)
    }
    func textFieldEditingChanged(_ textField: UITextField) {
        //print("****************** TextField editing changed")
        sendActions(for: UIControlEvents.editingChanged)
    }

    
    // MARK: Internal functions
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        buildElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        buildElements()
    }
    
    private func buildElements() {
        
        // init stuff on the items that needs to run only once (as opposed to sizes that may change)
        self.addSubview(label)
        self.addSubview(textField)
        
        textField.keyboardType = self.keyboardType
        textField.backgroundColor = self.fieldBkdColor
        textField.textColor = self.fieldTextColor
        label.backgroundColor = self.labelBkdColor
        label.textColor = self.labelTextColor
        textField.returnKeyType = UIReturnKeyType.done
        
        textField.addTarget(self, action: #selector(BSInputLine.textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(BSInputLine.textFieldDidEndEditing(_:)), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(BSInputLine.textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    private func resizeElements() {
        
        // To make sure we fit in the givemn size, we set all widths and horizontal margins
        // according to this ratio.
        let hRatio : CGFloat = self.frame.width / totalWidth
        let vRatio : CGFloat = self.frame.height / totalHeight
        NSLog("width=\(self.frame.width), hRatio=\(hRatio), height=\(self.frame.height), vRatio=\(vRatio)")
        
        if let font : UIFont = UIFont(name: self.fontName, size: fontSize*hRatio) {
            label.font = font
            textField.font = font
        }
        
        label.frame = CGRect(x: leftMargin*hRatio, y: (totalHeight-labelHeight)/2*vRatio, width: labelWidth*hRatio, height: labelHeight*vRatio)
        
        if image == nil && imageView != nil {
            print("Need to remove subview")
        }
        if image != nil && imageView == nil {
            self.imageView = UIImageView()
            if let imageView = imageView {
                self.addSubview(imageView)
            }
        }
        if let imageView = imageView {
            imageView.image = image
            imageView.frame = CGRect(x: (totalWidth-rightMargin-imageWidth)*hRatio, y: (totalHeight-imageHeight)/2*vRatio, width: imageWidth*hRatio, height: imageHeight*vRatio)
        }
        
        let fieldWidth : CGFloat = totalWidth - labelWidth - (imageView != nil ? imageWidth : 0) - leftMargin - rightMargin - middleMargin*2
        textField.frame = CGRect(x: (leftMargin + labelWidth + middleMargin)*hRatio, y: (totalHeight-fieldHeight)/2*vRatio, width: fieldWidth*hRatio, height: fieldHeight*vRatio)
        
        resizeError()
        
        // for debug of error
        if self.errorOn == true {
            showError()
        } else {
            hideError()
        }
    }
    
    private func resizeError() {
        if let errorLabel = errorLabel {
            if !errorLabel.isHidden {
                errorLabel.font = self.textField.font
                errorLabel.frame = CGRect(x: textField.frame.minX + textField.frame.width*0.25, y: textField.frame.minY, width: textField.frame.width*0.75, height: textField.frame.height)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        label.text = self.labelText
        textField.placeholder = self.fieldPlaceHolder
        resizeElements()
    }
    
    override func updateConstraints() {
        
        NSLog("updateConstraints, shouldSetupConstraints=\(shouldSetupConstraints)")
        if (shouldSetupConstraints) {
            // AutoLayout constraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    
}
