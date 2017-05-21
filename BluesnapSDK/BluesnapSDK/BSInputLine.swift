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
class BSInputLine: UIControl {

    // MARK: Configurable properties
    
    @IBInspectable var labelText: String! = "Label"
    @IBInspectable var labelTextColor: UIColor = UIColor.darkGray
    @IBInspectable var labelBkdColor: UIColor = UIColor.white
    @IBInspectable var fieldPlaceHolder: String! = ""
    @IBInspectable var fieldIsEditable: String?
    @IBInspectable var image: UIImage?
    @IBInspectable var fieldTextColor: UIColor = UIColor.black
    @IBInspectable var fieldBkdColor: UIColor = UIColor.white
    @IBInspectable var keyboardType : UIKeyboardType = UIKeyboardType.default
    @IBInspectable var errorText: String! = "Please supply a valid value"
    @IBInspectable var delegate: BSInputLineDelegate?
    
    @IBInspectable var cornerRadius: CGFloat = 5.0
    @IBInspectable var borderColor: UIColor = UIColor(red: 248, green: 248, blue: 248, alpha: 1)
    @IBInspectable var borderWidth: CGFloat = 0.5
    private var customBackgroundColor = UIColor.white
    override var backgroundColor: UIColor? {
        didSet {
            customBackgroundColor = backgroundColor!
            super.backgroundColor = UIColor.clear
        }
    }
    @IBInspectable var shadowDarkColor: UIColor = UIColor.lightGray //(red: 100, green: 100, blue: 100, alpha: 1)
    @IBInspectable var shadowRadius: CGFloat = 15.0
    @IBInspectable var shadowOpacity: CGFloat = 0.5
    
    
    // This is just for debug
    @IBInspectable var errorOn: Bool! = false
    
    // MARK: ui elements
    
    internal var label : UILabel! = UILabel()
    internal var textField : UITextField! = UITextField()
    internal var imageButton : UIButton!
    internal var errorLabel : UILabel?
    internal var fieldCoverButton : UIButton?

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
    internal let labelFontSize : CGFloat = 14
    internal let fieldFontSize : CGFloat = 17
    
    
    public func getValue() -> String! {
        return textField.text
    }
    
    public func setValue(_ newValue: String!) {
        textField.text = newValue
    }
    
    public func showError(_ errorText : String) {
        
        self.errorText = errorText
        showError()
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
            errorLabel.isHidden = false
            resizeError()
        }
    }

    public func hideError() {
        
        if let errorLabel = errorLabel {
            errorLabel.isHidden = true
        }
    }
    
    public func closeKeyboard() {
        
        self.textField.resignFirstResponder()
        self.resignFirstResponder()
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
    
    override func draw(_ rect: CGRect) {
        
        // set item attributes
        
        label.text = self.labelText
        textField.placeholder = self.fieldPlaceHolder
        resizeElements()
        
        // set rounded corners
        
        customBackgroundColor.setFill()
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).fill()
        
        // set shadow
        
        let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
        borderColor.setStroke()
        borderPath.lineWidth = borderWidth
        borderPath.stroke()
        //UIColor.clear.setStroke()
        //self.layer.shouldRasterize = true
        
    }
    
    private func shouldCoverTextField()-> Bool {
        return self.fieldIsEditable != nil
    }
    
    private func buildElements() {
        
        // init stuff on the items that needs to run only once (as opposed to sizes that may change)
        self.addSubview(label)
        self.addSubview(textField)
        
        textField.addTarget(self, action: #selector(BSInputLine.textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(BSInputLine.textFieldDidEndEditing(_:)), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(BSInputLine.textFieldEditingChanged(_:)), for: .editingChanged)
        
        self.imageButton = UIButton(type: UIButtonType.custom)
        self.addSubview(imageButton)
        imageButton.addTarget(self, action: #selector(BSInputLine.imageTouchUpInside(_:)), for: .touchUpInside)
        imageButton.contentVerticalAlignment = .fill
        imageButton.contentHorizontalAlignment = .center
        //imageButton.backgroundColor = UIColor.yellow
        
        setElementAttributes()
    }
    
    private func setElementAttributes() {
        
        // set stuff for shadow
        layer.shadowColor = shadowDarkColor.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = Float(shadowOpacity)
        super.backgroundColor = UIColor.clear

        //self.layer.cornerRadius = cornerRadius

        label.backgroundColor = self.labelBkdColor
        label.shadowColor = UIColor.clear
        label.shadowOffset = CGSize.zero
        label.layer.shadowRadius = 0
        label.layer.shadowColor = UIColor.clear.cgColor
        label.textColor = self.labelTextColor
        
        textField.keyboardType = self.keyboardType
        textField.backgroundColor = self.fieldBkdColor
        textField.textColor = self.fieldTextColor
        textField.returnKeyType = UIReturnKeyType.done
        textField.borderStyle = .none
    }
    
    override func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        setElementAttributes()
        resizeElements()
    }

    private func resizeElements() {
        
        NSLog("in resizeElements")
        
        // To make sure we fit in the givemn size, we set all widths and horizontal margins
        // according to this ratio.
        let hRatio : CGFloat = self.frame.width / totalWidth
        let vRatio : CGFloat = self.frame.height / totalHeight
        NSLog("width=\(self.frame.width), hRatio=\(hRatio), height=\(self.frame.height), vRatio=\(vRatio)")
        
        if let labelFont : UIFont = UIFont(name: self.fontName, size: labelFontSize*vRatio) {
            label.font = labelFont
        }
        
        if let fieldFont : UIFont = UIFont(name: self.fontName, size: fieldFontSize*vRatio) {
            textField.font = fieldFont
        }
        
        label.frame = CGRect(x: leftMargin*hRatio, y: (totalHeight-labelHeight)/2*vRatio, width: labelWidth*hRatio, height: labelHeight*vRatio)
        
        if image == nil {
            imageButton.isHidden = true
        } else {
            imageButton.isHidden = false
            imageButton.setImage(image, for: UIControlState.normal)
            imageButton.frame = CGRect(x: (totalWidth-rightMargin-imageWidth)*hRatio, y: (totalHeight-imageHeight)/2*vRatio, width: imageWidth*hRatio, height: imageHeight*vRatio)
        }
        
        let actualFieldWidth : CGFloat = (totalWidth - labelWidth - (image != nil ? imageWidth : 0) - leftMargin - rightMargin - middleMargin*2) * hRatio
        let fieldX = (leftMargin + labelWidth + middleMargin) * hRatio
        let fieldY = (totalHeight-fieldHeight)/2*vRatio
        let actualFieldHeight = self.fieldHeight * vRatio
        textField.frame = CGRect(x: fieldX, y: fieldY, width: actualFieldWidth, height: actualFieldHeight)
        
        if shouldCoverTextField() == true {
            buildFieldCoverButton()
        }
        if let fieldCoverButton = fieldCoverButton {
            fieldCoverButton.frame = CGRect(x: fieldX, y: fieldY, width: actualFieldWidth, height: actualFieldHeight)
        }
        
        resizeError()
        
        // for debug of error
        if self.errorOn == true {
            showError()
        } else {
            hideError()
        }
    }
    
    private func buildFieldCoverButton() {
        
        if shouldCoverTextField() == false {
            if let fieldCoverButton = fieldCoverButton {
                fieldCoverButton.isHidden = true
                textField.isUserInteractionEnabled = true
            }
        } else {
            if fieldCoverButton == nil {
                fieldCoverButton = UIButton()
                if let fieldCoverButton = fieldCoverButton {
                    fieldCoverButton.backgroundColor = UIColor.clear
                    //fieldCoverButton.alpha = 0.3
                    self.addSubview(fieldCoverButton)
                    fieldCoverButton.addTarget(self, action: #selector(BSInputLine.fieldCoverButtonTouchUpInside(_:)), for: .touchUpInside)
                }
            }
            if let fieldCoverButton = fieldCoverButton {
                fieldCoverButton.isHidden = false
                textField.isUserInteractionEnabled = false
            }
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
    
    override func updateConstraints() {
        
        NSLog("updateConstraints, shouldSetupConstraints=\(shouldSetupConstraints)")
        if (shouldSetupConstraints) {
            // AutoLayout constraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    
    // MARK:- ---> Action methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //print("****************** TextField did begin editing method called")
        hideError()
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
    
    func imageTouchUpInside(_ sender: Any) {
        //print("****************** Image click")
        sendActions(for: UIControlEvents.touchUpInside)
    }
    
    func fieldCoverButtonTouchUpInside(_ sender: Any) {
        //print("****************** field cover click")
        sendActions(for: UIControlEvents.touchUpInside)
    }
    
}
