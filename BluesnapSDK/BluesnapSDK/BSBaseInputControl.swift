//
//  BSBaseInputControl.swift
//  BluesnapSDK
//
//  Base control with one text field, one image button showing on a white
//  strip with a shadow. The field can be editable or not.
//
//  Created by Shevie Chen on 22/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

@IBDesignable
class BSBaseInputControl: UIControl, UITextFieldDelegate {

    // MARK: Configurable properties
    
    @IBInspectable var fieldPlaceHolder: String! = "" {
        didSet {
            textField.placeholder = fieldPlaceHolder
        }
    }
    @IBInspectable var fieldIsEditable: String?
    @IBInspectable var image: UIImage? {
        didSet {
            imageButton.imageView?.image = image
        }
    }
    @IBInspectable var fieldTextColor: UIColor = UIColor.black
    @IBInspectable var fieldBkdColor: UIColor = UIColor.white
    @IBInspectable var fieldKeyboardType : UIKeyboardType = UIKeyboardType.default {
        didSet {
            textField.keyboardType = fieldKeyboardType
            if fieldKeyboardType == .numberPad {
                self.setNumericKeyboard()
            } else {
                self.removeNumericKeyboard()
            }
        }
    }
    
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
    
    
    // MARK: UI elements
    
    internal var textField : UITextField! = UITextField()
    internal var imageButton : UIButton!
    internal var errorLabel : UILabel?
    internal var fieldCoverButton : UIButton?
    
    // MARK: private properties
    
    var shouldSetupConstraints = true
    
    internal let totalWidth : CGFloat = 335
    internal let totalHeight : CGFloat = 43
    internal let leftMargin : CGFloat = 16
    internal let middleMargin : CGFloat = 8
    internal let rightMargin : CGFloat = 16
    internal let fontName = "Helvetica Neue"

    internal let fieldHeight : CGFloat = 20
    internal let fieldFontSize : CGFloat = 17
    
    internal let imageWidth : CGFloat = 21
    internal let imageHeight : CGFloat = 15
    
    internal var errorText: String! = "Please supply a valid value"
    internal var errorHeight : CGFloat! = 12
    internal var errorFontSize : CGFloat! = 10
    internal var errorColor : UIColor! = UIColor.red
    internal var errorField : UITextField?

    internal var hRatio : CGFloat = 1.0
    internal var vRatio : CGFloat = 1.0

    // MARK: public functions
    
    public func getValue() -> String! {
        return textField.text
    }
    
    public func setValue(_ newValue: String!) {
        textField.text = newValue
    }
    
    public func showError(_ errorText : String?) {
        
        showError(field: self.textField, errorText: errorText)
    }
    
    public func showError(field: UITextField!, errorText : String?) {
        
        self.errorText = errorText ?? ""
        self.errorField = field
        field.textColor = self.errorColor
        
        buildErrorLabel()
        if let errorLabel = errorLabel {
            if errorText != nil {
                errorLabel.text = self.errorText
                errorLabel.isHidden = false
                resizeError()
            }
        }
    }
    
    public func hideError(_ field: UITextField?) {
        
        if field == nil || errorField == field {
            if let errorLabel = errorLabel {
                errorLabel.isHidden = true
                errorField?.textColor = self.fieldTextColor
            }
        }
    }    
    
    // MARK: TextFieldDelegate functions

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    
    internal func buildElements() {
        
        // init stuff on the items that needs to run only once (as opposed to sizes that may change)
        self.addSubview(textField)
        
        textField.addTarget(self, action: #selector(BSInputLine.textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(BSInputLine.textFieldDidEndEditing(_:)), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(BSInputLine.textFieldEditingChanged(_:)), for: .editingChanged)
        textField.delegate = self
        
        self.imageButton = UIButton(type: UIButtonType.custom)
        self.addSubview(imageButton)
        imageButton.addTarget(self, action: #selector(BSBaseInputControl.imageTouchUpInside(_:)), for: .touchUpInside)
        imageButton.contentVerticalAlignment = .fill
        imageButton.contentHorizontalAlignment = .center
        //imageButton.backgroundColor = UIColor.yellow
        
        setElementAttributes()
    }
    
    internal func setElementAttributes() {
        
        // set stuff for shadow
        layer.shadowColor = shadowDarkColor.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = Float(shadowOpacity)
        super.backgroundColor = UIColor.clear
        
        textField.keyboardType = self.fieldKeyboardType
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
    
    internal func resizeElements() {
        
        // To make sure we fit in the givemn size, we set all widths and horizontal margins
        // according to this ratio.
        hRatio = self.frame.width / totalWidth
        vRatio = self.frame.height / totalHeight
        //NSLog("width=\(self.frame.width), hRatio=\(hRatio), height=\(self.frame.height), vRatio=\(vRatio)")
        
        if let fieldFont : UIFont = UIFont(name: self.fontName, size: fieldFontSize*vRatio) {
            textField.font = fieldFont
        }
        
        if image == nil {
            imageButton.isHidden = true
        } else {
            imageButton.isHidden = false
            imageButton.setImage(image, for: UIControlState.normal)
            imageButton.frame = getImageRect()
        }
        
        let actualFieldWidth : CGFloat = getFieldWidth()
        let fieldX = getFieldX()
        let fieldY = (totalHeight-fieldHeight)/2*vRatio
        let actualFieldHeight = self.fieldHeight * vRatio
        textField.frame = CGRect(x: fieldX, y: fieldY, width: actualFieldWidth, height: actualFieldHeight)
        
        buildFieldCoverButton()
        if let fieldCoverButton = fieldCoverButton {
            if shouldCoverTextField() == true {
                fieldCoverButton.frame = CGRect(x: fieldX, y: fieldY, width: actualFieldWidth, height: actualFieldHeight)
            }
        }
        
        resizeError()
    }
    
    internal func getImageRect() -> CGRect {
        return CGRect(x: (totalWidth-rightMargin-imageWidth)*hRatio, y: (totalHeight-imageHeight)/2*vRatio, width: imageWidth*hRatio, height: imageHeight*vRatio)
    }
    
    internal func getFieldWidth() -> CGFloat {
        
        let actualFieldWidth : CGFloat = (totalWidth - (image != nil ? imageWidth : 0) - leftMargin - rightMargin - middleMargin) * hRatio
        return actualFieldWidth
    }
    
    internal func getFieldX() -> CGFloat {
        
        let fieldX = leftMargin * hRatio
        return fieldX
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
                
                // remove later
                //fieldCoverButton.backgroundColor = UIColor.yellow
                //fieldCoverButton.alpha = 0.5
            }
        }
    }
    
    internal func buildErrorLabel() {
        
        if errorLabel == nil {
            errorLabel = UILabel()
            self.addSubview(errorLabel!)
        }
        if let errorLabel = errorLabel {
            errorLabel.backgroundColor = UIColor.clear
            errorLabel.textColor = self.errorColor
            errorLabel.isHidden = true
            errorLabel.textAlignment = .left
        }
    }
    
    internal func resizeError() {
        if let errorLabel = errorLabel {
            if !errorLabel.isHidden {
                if let labelFont : UIFont = UIFont(name: self.fontName, size: errorFontSize*vRatio) {
                    errorLabel.font = labelFont
                }
                errorLabel.frame = CGRect(x: textField.frame.minX, y: (self.totalHeight-self.errorHeight)*vRatio, width: textField.frame.width, height: errorHeight*vRatio)
            }
        }
    }
    
    override func updateConstraints() {
        
        //NSLog("updateConstraints, shouldSetupConstraints=\(shouldSetupConstraints)")
        if (shouldSetupConstraints) {
            // AutoLayout constraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    
    // MARK:- ---> Action methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        hideError(textField)
        sendActions(for: UIControlEvents.editingDidBegin)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        sendActions(for: UIControlEvents.editingDidEnd)
    }
    func textFieldEditingChanged(_ textField: UITextField) {
        
        sendActions(for: UIControlEvents.editingChanged)
    }
    
    func imageTouchUpInside(_ sender: Any) {
        
        sendActions(for: UIControlEvents.touchUpInside)
    }
    
    func fieldCoverButtonTouchUpInside(_ sender: Any) {
        
        sendActions(for: UIControlEvents.touchUpInside)
    }

    // MARK: Numeric Keyboard "done" button enhancement
    
    internal func createDoneButtonForKeyboard() -> UIToolbar {
        
        let viewForDoneButtonOnKeyboard = UIToolbar()
        viewForDoneButtonOnKeyboard.sizeToFit()
        let btnDoneOnKeyboard = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneBtnfromKeyboardClicked))
        viewForDoneButtonOnKeyboard.semanticContentAttribute = .forceRightToLeft
        viewForDoneButtonOnKeyboard.items = [btnDoneOnKeyboard]
        return viewForDoneButtonOnKeyboard
     }

    @IBAction func doneBtnfromKeyboardClicked (sender: Any) {
        //Hide Keyboard by endEditing
        self.endEditing(true)
    }
    
    internal func setNumericKeyboard() {
        
        let viewForDoneButtonOnKeyboard = createDoneButtonForKeyboard()
        self.textField.inputAccessoryView = viewForDoneButtonOnKeyboard
    }
    
    internal func removeNumericKeyboard() {
        
        self.textField.inputAccessoryView = nil
    }


}
