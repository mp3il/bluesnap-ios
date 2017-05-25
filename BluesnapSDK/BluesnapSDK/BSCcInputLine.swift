//
//  BSCcInputLine.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 22/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSCcInputLine: BSBaseInputControl, UITextFieldDelegate {

    // We use the BSBaseInputControl for the CCN field and image,
    // and add fields for EXP and CVV

    // MARK: public properties

    internal var submitCcFunc: (String!)->Bool! = {
        ccn in
        print("submitCcFunc should be overridden")
        return true
    }
    internal var startEditCcFunc: () -> Void = {
        print("startEditCcFunc should be overridden")
    }
    internal var endEditCcFunc: () -> Void = {
        print("endEditCcFunc should be overridden")
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
    
    private let ccnWidth : CGFloat = 180
    private let last4Width : CGFloat = 46
    private let expLeftMargin : CGFloat = 120
    private let expWidth : CGFloat = 70
    private let cvvLeftMargin : CGFloat = 250
    private let cvvWidth : CGFloat = 50
    private let errorWidth : CGFloat = 150
    
    internal var ccn : String! = ""
    internal var ccnIsOpen : Bool = true {
        didSet {
            self.fieldIsEditable = ccnIsOpen ? nil : "NO"
            if ccnIsOpen {
                self.textField.text = ccn
            } else {
                //ccn = self.textField.text
                self.textField.text = ccn.last4
            }
        }
    }
    
    // MARK: Constants

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
    
    func getExpDateAsMMYYYY() -> String! {
        
        let newValue = self.expTextField.text ?? ""
        if let p = newValue.characters.index(of: "/") {
            let mm = newValue.substring(with: newValue.startIndex..<p)
            let yy = newValue.substring(with: p ..< newValue.endIndex).removeNoneDigits
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
        
        let result = validateCCN() && validateExp() && validateCvv()
        return result
    }
    
    
    // MARK: BSBaseInputControl Override functions

    override func buildElements() {
        
        //self.fieldIsEditable = ccnIsOpen ? nil : "NO"

        super.buildElements()
        
        self.textField.delegate = self
        self.addSubview(expTextField)
        self.expTextField.delegate = self
        self.addSubview(cvvTextField)
        self.cvvTextField.delegate = self
        
        fieldKeyboardType = .numberPad
        
        expTextField.addTarget(self, action: #selector(BSCcInputLine.expFieldDidBeginEditing(_:)), for: .editingDidBegin)
        expTextField.addTarget(self, action: #selector(BSCcInputLine.expFieldEditingChanged(_:)), for: .editingChanged)

        cvvTextField.addTarget(self, action: #selector(BSCcInputLine.cvvFieldDidBeginEditing(_:)), for: .editingDidBegin)
        cvvTextField.addTarget(self, action: #selector(BSCcInputLine.cvvFieldEditingChanged(_:)), for: .editingChanged)
        
        expTextField.textAlignment = .center
        cvvTextField.textAlignment = .center
        
        errorLabel = UILabel()
        self.addSubview(errorLabel!)
        showError(nil)
        errorLabel?.isHidden = true
    }

    override func setElementAttributes() {
        
        super.setElementAttributes()
        
        expTextField.keyboardType = .numberPad
        expTextField.backgroundColor = self.fieldBkdColor
        expTextField.textColor = self.fieldTextColor
        expTextField.returnKeyType = UIReturnKeyType.done
        expTextField.borderStyle = .none
        expTextField.placeholder = "MM/YY"

        cvvTextField.keyboardType = .numberPad
        cvvTextField.backgroundColor = self.fieldBkdColor
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
            // position the label according the chosen field
            
            var x: CGFloat = leftMargin
            errorLabel.textAlignment = .left
            if let errorField = self.errorField {
                x = errorField.frame.minX
                errorLabel.textAlignment = .left
                if errorField == self.expTextField || errorField == self.cvvTextField {
                    // center error around the field
                    let fieldCenter : CGFloat! = errorField.frame.minX + errorField.frame.width/2.0
                    x = fieldCenter - errorWidth*hRatio/2.0
                    errorLabel.textAlignment = .center
                }/* else if errorField == self.cvvTextField {
                    // right - justify
                    x = (totalWidth - rightMargin - errorWidth)*hRatio
                    errorLabel.textAlignment = .right
                }*/
            }
            errorLabel.frame = CGRect(x: x, y: (totalHeight-errorHeight)*vRatio, width: self.errorWidth, height: errorHeight*vRatio)
        }
    }
    
    func resizeError(field: UITextField) {
        if let errorLabel = errorLabel {
            if let labelFont : UIFont = UIFont(name: self.fontName, size: errorFontSize*vRatio) {
                errorLabel.font = labelFont
            }
            errorLabel.frame = CGRect(x: field.frame.minX, y: (totalHeight-errorHeight)*vRatio, width: errorWidth*hRatio, height: errorHeight*vRatio)
        }
    }
    
    // MARK: TextFieldDelegate functions
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.textField {
            print("ccn should return")
        } else if textField == self.expTextField {
            print("exp should return")
        } else if textField == self.cvvTextField {
            print("cvv should return")
        } else {
            print("UNKNOWN should return")
        }
        return  true
    }
    func textFieldShouldEndEditing(_ sender: UITextField) -> Bool {
        
        var ok : Bool = false
        if sender == self.textField {
            ok = tryCloseCcn()
        } else if sender == self.expTextField {
            ok = validateExp()
            if ok == true {
                focusOnCvvField()
            }
        } else {
            ok = validateCvv()
            if ok == true {
                focusOnNextField()
            }
        }
        return ok
    }
    
    // MARK: focus on fields
    
    func focusOnCcnField() {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.textField.becomeFirstResponder()
            }
        }
    }
    
    func focusOnExpField() {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.expTextField.becomeFirstResponder()
            }
        }
    }
    
    func focusOnCvvField() {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.cvvTextField.becomeFirstResponder()
            }
        }
    }
    
    func focusOnNextField() {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                let nextTage = self.cvvTextField.tag+1;
                let nextResponder = self.superview?.viewWithTag(nextTage) as UIResponder!
                if nextResponder != nil {
                    nextResponder?.becomeFirstResponder()
                }
            }
        }
    }
    

    // MARK: event handlers
    
    override func fieldCoverButtonTouchUpInside(_ sender: Any) {
        
        if errorLabel?.isHidden == true {
            openCcn()
        }
    }
    
    override func textFieldDidBeginEditing(_ sender: UITextField) {
        hideError()
    }
    
    override func textFieldDidEndEditing(_ sender: UITextField) {
        //print("textFieldDidEndEditing")
        endEditCcFunc()
    }
    
    override func textFieldEditingChanged(_ sender: UITextField) {
        
        self.ccn = self.textField.text
        BSValidator.ccnEditingChanged(textField)
        
        let ccn = textField.text?.removeNoneDigits ?? ""
        let ccnLength = ccn.characters.count
        //print("textFieldEditingChanged; ccnLength=\(ccnLength)")
        
        if ccnLength >= 6 {
            cardType = textField.text?.getCCTypeByRegex()?.lowercased() ?? ""
        }
        var maxLength : Int = 16
        if cardType == "amex" {
            maxLength = 15
        } else if cardType == "dinersclub" {
            maxLength = 14
        }
        if checkMaxLength(textField: sender, maxLength: maxLength) == true {
            if ccnLength == maxLength {
                // try to resign first responder
                //print("textFieldEditingChanged; resigning")
                self.textField.resignFirstResponder()
            }
        }
    }

    
    private func tryCloseCcn() -> Bool {
        //print("************* close CCN")
        if self.ccnIsOpen {
            ccn = self.textField.text
        }
        // do not leave field until is valid
        var ok = false
        if validateCCN() {
            if submitCcFunc(textField.text!) == true {
                ok = true
            }
        }
        if ok == true {
            ccnIsOpen = false
            hideError()
            resizeElements()
            focusOnExpField()
        } else {
            focusOnCcnField()
            //self.textField.becomeFirstResponder()
        }
        return ok
    }
    
    private func openCcn() {
        //print("************* open CCN")
        ccnIsOpen = true
        resizeElements()
        focusOnCcnField()
        startEditCcFunc()
    }

    func expFieldDidBeginEditing(_ sender: UITextField) {
        
        hideError()
    }
    
    func expFieldEditingChanged(_ sender: UITextField) {
        
        BSValidator.expEditingChanged(sender)
        if checkMaxLength(textField: sender, maxLength: 5) == true {
            if sender.text?.characters.count == 5 {
                expTextField.resignFirstResponder()
            }
        }
    }

    func cvvFieldDidBeginEditing(_ sender: UITextField) {
        
        hideError()
    }
    
    func cvvFieldEditingChanged(_ sender: UITextField) {
        
        BSValidator.cvvEditingChanged(sender)
        var cvvMaxLength = 3
        if cardType == "amex" {
            cvvMaxLength = 4
        }
        if checkMaxLength(textField: sender, maxLength: cvvMaxLength) == true {
            if sender.text?.characters.count == cvvMaxLength {
                cvvTextField.resignFirstResponder()
            }
        }
    }
    
    // MARK: Validation methods
    
    func validateCCN() -> Bool {
        
        let result = BSValidator.validateCCN(input: self)
        return result
    }
    
    func validateExp() -> Bool {
        
        let result = BSValidator.validateExp(input: self)
        return result
    }
    
    func validateCvv() -> Bool {
        
        let result = BSValidator.validateCvv(input: self)
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
    
    func checkMaxLength(textField: UITextField!, maxLength: Int) -> Bool {
        if (textField.text!.removeNoneDigits.characters.count > maxLength) {
            textField.deleteBackward()
            return false
        } else {
            return true
        }
    }

}
