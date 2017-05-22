//
//  BSCcInputLine.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 22/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSCcInputLine: BSBaseInputControl {

    // We use the BSBaseInputControl for the CCN field and image,
    // and add fields for EXP and CVV

    // MARK: public properties

    internal var submitCcFunc: (String!)->Bool! = {
        ccn in
        print("submitCcFunc should be overridden")
        return true
    }
    internal var cardType : String! = "" {
        didSet {
            updateCcIcon(ccType: cardType)
        }
    }


    // MARK: Additional UI elements
    
    internal var expTextField : UITextField! = UITextField()
    internal var expErrorLabel : UILabel?
    internal var cvvTextField : UITextField! = UITextField()
    internal var cvvErrorLabel : UILabel?

    // MARK: private properties
    
    private let ccnWidth : CGFloat = 155
    private let last4Width : CGFloat = 46
    private let expLeftMargin : CGFloat = 150
    private let expWidth : CGFloat = 80
    private let cvvLeftMargin : CGFloat = 284
    private let cvvWidth : CGFloat = 62
    
    private var ccn : String! = ""
    internal var ccnIsOpen : Bool = true {
        didSet {
            self.fieldIsEditable = ccnIsOpen ? nil : "NO"
            if ccnIsOpen {
                self.textField.text = ccn
            } else {
                ccn = self.textField.text
                self.textField.text = ccn.last4
            }
        }
    }
    
    // MARK: Constants

    fileprivate let ccnInvalidMessage = "Please fill a valid Credit Card number"
    fileprivate let cvvInvalidMessage = "Please fill a valid CVV number"
    fileprivate let expInvalidMessage = "Please fill a valid exiration date"
    fileprivate let ccImages = [
        "amex": "amex",
        //"cartebleue": "visa",
        "cirrus": "cirrus",
        "diners": "dinersclub",
        "discover": "discover",
        "jcb": "jcb",
        "maestr_uk": "maestro",
        "mastercard": "mastercard",
        "china_union_pay": "unionpay",
        "visa": "visa"]

    // MARK: Public functions
    
    //func getExp() -> String! {
    //    return self.expTextField.text ?? ""
    //}
    
    func getExpDateAsMMYYYY() -> String! {
        
        let newValue = self.expTextField.text ?? ""
        if let p = newValue.characters.index(of: "/") {
            let mm = newValue.substring(with: newValue.startIndex..<p)
            let yy = newValue.substring(with: p ..< newValue.endIndex)
            let currentYearStr = String(BSValidator.getCurrentYear())
            let p1 = currentYearStr.index(currentYearStr.startIndex, offsetBy: 2)
            let first2Digits = currentYearStr.substring(with: currentYearStr.startIndex..<p1)
            return "\(mm)/\(first2Digits)\(yy)"
        }
        return ""
    }
    
    override func getValue() -> String! {
        return ccn
    }
    
    override func setValue(_ newValue: String!) {
        ccn = newValue
        if self.ccnIsOpen {
            self.textField.text = ccn
        }
    }
    
    func getCvv() -> String! {
        return self.cvvTextField.text ?? ""
    }
    
    func getCardType() -> String! {
        return cardType
    }
    
    func validate() -> Bool {
        
        let ok1 = validateCCN()
        let ok2 = validateExp()
        let ok3 = validateCvv()
        let result = ok1 && ok2 && ok3
        return result
    }
    
    // MARK: BSBaseInputControl Override functions

    override func buildElements() {
        
        //self.fieldIsEditable = ccnIsOpen ? nil : "NO"

        super.buildElements()
        self.addSubview(expTextField)
        self.addSubview(cvvTextField)
        
        fieldKeyboardType = .numberPad
        
        expTextField.addTarget(self, action: #selector(BSCcInputLine.expFieldDidBeginEditing(_:)), for: .editingDidBegin)
        expTextField.addTarget(self, action: #selector(BSCcInputLine.expFieldDidEndEditing(_:)), for: .editingDidEnd)
        expTextField.addTarget(self, action: #selector(BSCcInputLine.expFieldEditingChanged(_:)), for: .editingChanged)

        cvvTextField.addTarget(self, action: #selector(BSCcInputLine.cvvFieldDidBeginEditing(_:)), for: .editingDidBegin)
        cvvTextField.addTarget(self, action: #selector(BSCcInputLine.cvvFieldDidEndEditing(_:)), for: .editingDidEnd)
        cvvTextField.addTarget(self, action: #selector(BSCcInputLine.cvvFieldEditingChanged(_:)), for: .editingChanged)
        
        errorLabel = UILabel()
        self.addSubview(errorLabel!)
        errorLabel?.isHidden = true
    }

    override func setElementAttributes() {
        
        super.setElementAttributes()
        
        expTextField.keyboardType = .numberPad
        expTextField.backgroundColor = UIColor.yellow // self.fieldBkdColor
        expTextField.textColor = self.fieldTextColor
        expTextField.returnKeyType = UIReturnKeyType.done
        expTextField.borderStyle = .none
        expTextField.placeholder = "MM/YY"

        cvvTextField.keyboardType = .numberPad
        cvvTextField.backgroundColor = UIColor.green //self.fieldBkdColor
        cvvTextField.textColor = self.fieldTextColor
        cvvTextField.returnKeyType = UIReturnKeyType.done
        cvvTextField.borderStyle = .none
        cvvTextField.placeholder = "CVV"
    }

    override func resizeElements() {
        
        super.resizeElements()
        
        expTextField.font = textField.font
        cvvTextField.font = cvvTextField.font
        
        if ccnIsOpen == true {
            expTextField.isHidden = true
            cvvTextField.isHidden = true
        } else {
            expTextField.isHidden = false
            cvvTextField.isHidden = false
            let actualExpFieldWidth : CGFloat = expWidth*hRatio
            let actualCvvFieldWidth : CGFloat = cvvWidth*hRatio
            let expFieldX = expLeftMargin*hRatio
            let cvvFieldX = cvvLeftMargin*hRatio
            let fieldY = (totalHeight-fieldHeight)/2*vRatio
            let actualFieldHeight = textField.bounds.height
            expTextField.frame = CGRect(x: expFieldX, y: fieldY, width: actualExpFieldWidth, height: actualFieldHeight)
            cvvTextField.frame = CGRect(x: cvvFieldX, y: fieldY, width: actualCvvFieldWidth, height: actualFieldHeight)
        }

    }
    
    override func getImageRect() -> CGRect {
        return CGRect(x: rightMargin*hRatio, y: (totalHeight-imageHeight)/2*vRatio, width: imageWidth*hRatio, height: imageHeight*vRatio)
    }

    override func getFieldWidth() -> CGFloat {
        if ccnIsOpen == true {
            return ccnWidth
        } else {
            return last4Width
        }
    }
    
    override func getFieldX() -> CGFloat {
        let fieldX = (leftMargin + imageWidth + middleMargin) * hRatio
        return fieldX
    }

    override func resizeError() {
        if let errorLabel = errorLabel {
             if let labelFont : UIFont = UIFont(name: self.fontName, size: errorFontSize*vRatio) {
                errorLabel.font = labelFont
            }
            errorLabel.frame = CGRect(x: leftMargin, y: textField.frame.minY, width: totalWidth*hRatio - rightMargin, height: errorHeight*vRatio)
            errorLabel.backgroundColor = UIColor.brown
        }
    }

    // MARK: event handlers
    
    override func fieldCoverButtonTouchUpInside(_ sender: Any) {
        
        ccnIsOpen = true
        //self.fieldIsEditable = nil
        resizeElements()
    }
    
    override func textFieldDidBeginEditing(_ sender: UITextField) {
        hideError()
    }
    
    override func textFieldDidEndEditing(_ sender: UITextField) {
        
        // do not leave field until is valid
        if validateCCN() {
            if submitCcFunc(textField.text!) == true {
                ccnIsOpen = false
                //self.fieldIsEditable = nil
                hideError()
                resizeElements()
            }
        }
    }
    
    override func textFieldEditingChanged(_ sender: UITextField) {
        
        BSValidator.ccnEditingChanged(textField)
    }

    func expFieldDidBeginEditing(_ sender: UITextField) {
        
        hideError()
    }
    
    func expFieldEditingChanged(_ sender: UITextField) {
        
        BSValidator.expEditingChanged(sender)
    }

    func expFieldDidEndEditing(_ sender: UITextField) {
        
        let _ = validateExp()
    }

    func cvvFieldDidBeginEditing(_ sender: UITextField) {
        
        hideError()
    }
    
    func cvvFieldEditingChanged(_ sender: UITextField) {
        
        BSValidator.cvvEditingChanged(sender)
    }
    
    func cvvFieldDidEndEditing(_ sender: UITextField) {
        
        let _ = validateCvv()
    }

    // MARK: Validation methods
    
    func validateCCN() -> Bool {
        
        let result = BSValidator.validateCCN(ignoreIfEmpty: false, textField: textField, errorLabel: errorLabel!, errorMessage: ccnInvalidMessage)
        return result
    }
    
    func validateExp() -> Bool {
        
        let result = BSValidator.validateExp(textField: expTextField, errorLabel: errorLabel!)
        return result
    }
    
    func validateCvv() -> Bool {
        
        let result = BSValidator.validateCvv(ignoreIfEmpty: false, textField: cvvTextField, errorLabel: errorLabel!)
        return result
    }

    // private functions
    
    private func updateCcIcon(ccType : String?) {
        
        // change the image in ccIconImage
        var imageName : String?
        if let ccType = ccType?.lowercased() {
            imageName = ccImages[ccType]
        }
        if imageName == nil {
            imageName = "default"
            NSLog("ccTypew \(ccType) does not have an icon")
        }
        if let image = BSViewsManager.getImage(imageName: "cc_\(imageName!)") {
            self.image = image
        }
    }
    

}
