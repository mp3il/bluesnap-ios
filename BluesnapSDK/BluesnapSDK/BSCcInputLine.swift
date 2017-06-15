//
//  BSCcInputLine.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 22/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

protocol BSCcInputLineDelegate : class {
    func startEditCreditCard()
    func endEditCreditCard()
    func willCheckCreditCard()
    func showAlert(_ message : String)
    func didCheckCreditCard(result: BSResultCcDetails?, error: BSCcDetailErrors?)
    func didSubmitCreditCard(result: BSResultCcDetails?, error: BSCcDetailErrors?)
}

@IBDesignable
class BSCcInputLine: BSBaseTextInput {

    // We use the BSBaseTextInput for the CCN field and image,
    // and add fields for EXP and CVV

    // MARK: Configurable properties
    
    @IBInspectable var showOpenInDesign: Bool = false {
        didSet {
            if designMode {
                ccnIsOpen = showOpenInDesign
            }
        }
    }
    @IBInspectable var ccnWidth: CGFloat = 220 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var last4Width: CGFloat = 70 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var expWidth: CGFloat = 70 {
        didSet {
            self.actualExpWidth = expWidth
        }
    }
    @IBInspectable var cvvWidth: CGFloat = 70 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var errorWidth: CGFloat = 150 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var nextBtnWidth: CGFloat = 22 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var nextBtnHeight: CGFloat = 22 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var nextBtnImage: UIImage?
    
    
    // MARK: public properties

    var delegate : BSCcInputLineDelegate?
    
    var cardType : String = "" {
        didSet {
            updateCcIcon(ccType: cardType)
        }
    }
    
    var ccnIsOpen : Bool = true {
        didSet {
            self.isEditable = ccnIsOpen ? nil : "NO"
            if ccnIsOpen {
                self.textField.text = ccn
            } else {
                //ccn = self.textField.text
                self.textField.text = ccn.last4
            }
        }
    }


    // MARK: private properties
    
    internal var expTextField : UITextField = UITextField()
    internal var cvvTextField : UITextField = UITextField()
    private var expErrorLabel : UILabel?
    private var cvvErrorLabel : UILabel?
    private var nextButton : UIButton = UIButton()

    private var ccn : String = ""
    private var lastValidateCcn : String = ""
    private var closing = false
    
    var actualCcnWidth: CGFloat = 220
    var actualLast4Width: CGFloat = 70
    var actualExpWidth: CGFloat = 70
    var actualCvvWidth: CGFloat = 70
    var actualErrorWidth: CGFloat = 150
    var actualNextBtnWidth: CGFloat = 22
    var actualNextBtnHeight: CGFloat = 22

    
    // MARK: Constants

    fileprivate let ccImages = [
        "amex": "amex",
        "cirrus": "cirrus",
        "diners": "dinersclub",
        "discover": "discover",
        "jcb": "jcb",
        "maestr_uk": "maestro",
        "mastercard": "mastercard",
        "china_union_pay": "unionpay",
        "visa": "visa"]

    // MARK: Public functions
    
    public func reset() {
        hideError(textField)
        hideError(expTextField)
        hideError(cvvTextField)
        textField.text = ""
        expTextField.text = ""
        cvvTextField.text = ""
        ccn = ""
        //ccnIsOpen = true
        openCcn()
    }

    public func closeOnLeave() {
        closing = true
    }
    
    public func getExpDateAsMMYYYY() -> String! {
        
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
        if self.ccnIsOpen {
            return self.textField.text
        } else {
            return ccn
        }
    }
    
    override func setValue(_ newValue: String!) {
        ccn = newValue
        if self.ccnIsOpen {
            self.textField.text = ccn
        }
    }
    
    public func getCvv() -> String! {
        return self.cvvTextField.text ?? ""
    }
    
    public func getCardType() -> String! {
        return cardType
    }
    
    public func validate() -> Bool {
        
        let result = validateCCN() && validateExp() && validateCvv()
        return result
    }
    
    // get issuing country and card type from server, while vsalidating the CCN
    public func checkCreditCard(ccn: String) {
        
        if validateCCN() {
            self.delegate?.willCheckCreditCard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                BSApiManager.submitCcn(ccNumber: ccn, completion: { (result, error) in
                    
                    //Check for error
                    if let error = error{
                        if (error == BSCcDetailErrors.invalidCcNumber) {
                            self.showError(BSValidator.ccnInvalidMessage)
                        } else {
                            self.delegate?.showAlert("An error occurred")
                        }
                    }
                    
                    // Check for result
                    if let result = result {
                        if let cardType = result.ccType {
                            self.cardType = cardType
                        }
                        self.closeCcn()
                    }
                    
                    self.delegate?.didCheckCreditCard(result: result, error: error)
                })
            })
        }
    }

    public func submitPaymentFields() {
        
        let ccn = self.getValue() ?? ""
        let cvv = self.getCvv() ?? ""
        let exp = self.getExpDateAsMMYYYY() ?? ""
        
        BSApiManager.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, completion: { (result, error) in
            
            
            //Check for error
            if let error = error{
                if (error == BSCcDetailErrors.invalidCcNumber) {
                    self.showError(field: self.textField, errorText: BSValidator.ccnInvalidMessage)
                } else if (error == BSCcDetailErrors.invalidExpDate) {
                    self.showError(field: self.expTextField, errorText: BSValidator.expInvalidMessage)
                } else if (error == BSCcDetailErrors.invalidCvv) {
                    self.showError(field: self.cvvTextField, errorText: BSValidator.cvvInvalidMessage)
                } else if (error == BSCcDetailErrors.expiredToken) {
                    self.delegate?.showAlert("Your session has expired, please go back and try again")
                } else {
                    NSLog("Unexpected error submitting Payment Fields to BS")
                    self.delegate?.showAlert("An error occurred, please try again")
                }
            }
            
            self.delegate?.didSubmitCreditCard(result: result, error: error)
        })
    }

    
    // MARK: BSBaseTextInput Override functions

    override func initRatios() -> (hRatio: CGFloat, vRatio: CGFloat) {
        let ratios = super.initRatios()
        
        actualNextBtnWidth = (nextBtnWidth * ratios.hRatio).rounded()
        actualNextBtnHeight = (nextBtnHeight * ratios.vRatio).rounded()
        
        actualCcnWidth = (ccnWidth * ratios.hRatio).rounded()
        actualLast4Width = (last4Width * ratios.hRatio).rounded()
        actualExpWidth = (expWidth * ratios.hRatio).rounded()
        actualCvvWidth = (cvvWidth * ratios.hRatio).rounded()
        actualErrorWidth = (errorWidth * ratios.hRatio).rounded()
        
        return ratios
    }
    
    override func buildElements() {
        
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
        
        setNumericKeyboard()
        
        buildErrorLabel()
        errorLabel?.isHidden = true
        
        setButtonImage()
    }
    
    private func setButtonImage() {
        
        var btnImage : UIImage?
        if let img = self.nextBtnImage {
            btnImage = img
        } else {
            btnImage = BSViewsManager.getImage(imageName: "forward_arrow")
        }
        if let img = btnImage {
            nextButton.setImage(img, for: .normal)
            nextButton.contentVerticalAlignment = .fill
            nextButton.contentHorizontalAlignment = .center
            nextButton.addTarget(self, action: #selector(self.doneBtnfromKeyboardClicked), for: .touchUpInside)
            self.addSubview(nextButton)
        }
    }

    override func setElementAttributes() {
        
        super.setElementAttributes()
        
        NSLog("********** In ccn setElement attributes ********")
        
        expTextField.keyboardType = .numberPad
        expTextField.backgroundColor = self.fieldBkdColor
        expTextField.textColor = self.textColor
        expTextField.returnKeyType = UIReturnKeyType.done
        expTextField.borderStyle = .none
        expTextField.placeholder = "MM/YY"

        cvvTextField.keyboardType = .numberPad
        cvvTextField.backgroundColor = self.fieldBkdColor
        cvvTextField.textColor = self.textColor
        cvvTextField.returnKeyType = UIReturnKeyType.done
        cvvTextField.borderStyle = .none
        cvvTextField.placeholder = "CVV"
        
        cvvTextField.borderStyle = textField.borderStyle
        expTextField.borderStyle = textField.borderStyle
        cvvTextField.layer.borderWidth = fieldBorderWidth
        expTextField.layer.borderWidth = fieldBorderWidth
        
        if let fieldBorderColor = self.fieldBorderColor {
            cvvTextField.layer.borderColor = fieldBorderColor.cgColor
            expTextField.layer.borderColor = fieldBorderColor.cgColor
        }
    }


    override func resizeElements() {
        
        super.resizeElements()
        
        expTextField.font = textField.font
        cvvTextField.font = textField.font
        
        if ccnIsOpen == true {
            expTextField.isHidden = true
            cvvTextField.isHidden = true
        } else {
            expTextField.isHidden = false
            cvvTextField.isHidden = false
            let fieldEndX = getFieldX() + textField.frame.width
            let cvvFieldX = self.frame.width - actualCvvWidth - self.actualRightMargin
            let expFieldX = (fieldEndX + cvvFieldX - actualExpWidth) / 2.0
            let fieldY = (self.frame.height-actualFieldHeight)/2
            expTextField.frame = CGRect(x: expFieldX, y: fieldY, width: actualExpWidth, height: actualFieldHeight)
            cvvTextField.frame = CGRect(x: cvvFieldX, y: fieldY, width: actualCvvWidth, height: actualFieldHeight)
        }

        if self.ccnIsOpen && (textField.text != "" || designMode) {
            let x : CGFloat = self.frame.width - actualRightMargin - actualNextBtnWidth
            let y : CGFloat = (self.frame.height-actualNextBtnHeight) / 2.0
            nextButton.frame = CGRect(x: x, y: y, width: actualNextBtnWidth, height: actualNextBtnHeight)
            nextButton.isHidden = false
        } else {
            nextButton.isHidden = true
        }

        if fieldCornerRadius != 0 {
            cvvTextField.layer.cornerRadius = fieldCornerRadius
            expTextField.layer.cornerRadius = fieldCornerRadius
        }
    }
    
    override func getImageRect() -> CGRect {
        return CGRect(x: actualRightMargin, y: (self.frame.height-actualImageHeight)/2, width: actualImageWidth, height: actualImageHeight)
    }

    override func getFieldWidth() -> CGFloat {
        if ccnIsOpen == true {
            return actualCcnWidth
        } else {
            return actualLast4Width
        }
    }
    
    override func getFieldX() -> CGFloat {
        let fieldX = actualLeftMargin + actualImageWidth + actualMiddleMargin
        return fieldX
    }

    override func resizeError() {
        
        if let errorLabel = errorLabel {
            if let labelFont : UIFont = UIFont(name: self.fontName, size: actualErrorFontSize) {
                errorLabel.font = labelFont
            }
            // position the label according the chosen field
            
            var x: CGFloat = actualLeftMargin
            errorLabel.textAlignment = .left
            if let errorField = self.errorField {
                x = errorField.frame.minX
                errorLabel.textAlignment = .left
                if errorField == self.expTextField || errorField == self.cvvTextField {
                    // center error around the field
                    let fieldCenter : CGFloat! = errorField.frame.minX + errorField.frame.width/2.0
                    x = fieldCenter - actualErrorWidth/2.0
                    errorLabel.textAlignment = .center
                }
            }
            errorLabel.frame = CGRect(x: x, y: self.frame.height-actualErrorHeight, width: actualErrorWidth, height: actualErrorHeight)
        }
    }
    
    func resizeError(field: UITextField) {
        if let errorLabel = errorLabel {
            if let labelFont : UIFont = UIFont(name: self.fontName, size: actualErrorFontSize) {
                errorLabel.font = labelFont
            }
            errorLabel.frame = CGRect(x: field.frame.minX, y: self.frame.height-actualErrorHeight, width: actualErrorWidth, height: actualErrorHeight)
        }
    }
    
    // MARK: TextFieldDelegate functions
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldEndEditing(_ sender: UITextField) -> Bool {
        
        if closing {
            closing = false
            return true
        }
        var ok : Bool = false
        if sender == self.textField {
            if ccnIsOpen {
                ccn = self.textField.text!
                if lastValidateCcn == self.textField.text {
                    self.closeCcn()
                } else {
                    self.lastValidateCcn = self.ccn
                    self.checkCreditCard(ccn: ccn)
                }
            } else {
                ok = true
            }
        } else if sender == self.expTextField {
            ok = validateExp()
        } else if sender == self.cvvTextField {
            ok = validateCvv()
        }
        return ok
    }
    
    // MARK: Numeric Keyboard "done" button enhancement
    
    override internal func setNumericKeyboard() {
        
        let viewForDoneButtonOnKeyboard = createDoneButtonForKeyboard()
        self.textField.inputAccessoryView = viewForDoneButtonOnKeyboard
        self.expTextField.inputAccessoryView = viewForDoneButtonOnKeyboard
        self.cvvTextField.inputAccessoryView = viewForDoneButtonOnKeyboard
    }
    

    // MARK: focus on fields
    
    func focusOnCcnField() {
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                if self.ccnIsOpen == true {
                    self.textField.becomeFirstResponder()
                }
            }
        }
    }
    
    func focusOnExpField() {
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                if self.ccnIsOpen == false {
                    self.expTextField.becomeFirstResponder()
                }
            }
        }
    }
    
    func focusOnCvvField() {
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                if self.ccnIsOpen == false {
                    self.cvvTextField.becomeFirstResponder()
                }
            }
        }
    }
    
    func focusOnNextField() {
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                let nextTage = self.tag+1;
                let nextResponder = self.superview?.viewWithTag(nextTage) as? BSInputLine
                if nextResponder != nil {
                    nextResponder?.textField.becomeFirstResponder()
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
        //hideError(textField)
    }
    
    override func textFieldDidEndEditing(_ sender: UITextField) {
        delegate?.endEditCreditCard()
    }
    
    override func textFieldEditingChanged(_ sender: UITextField) {
        
        self.ccn = self.textField.text!
        BSValidator.ccnEditingChanged(textField)
        
        let ccn = textField.text?.removeNoneDigits ?? ""
        let ccnLength = ccn.characters.count
        
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
                if self.textField.canResignFirstResponder {
                    focusOnExpField()
                }
            }
        }
    }

    private func closeCcn() {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.ccnIsOpen = false
            self.resizeElements()
            self.layoutIfNeeded()
        }, completion: { animate in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.focusOnExpField()
            }
        })
    }

    private func openCcn() {
        var canOpen = true
        if cvvTextField.isFirstResponder {
            if !cvvTextField.canResignFirstResponder {
                canOpen = false
            }
        } else if expTextField.isFirstResponder {
            if !expTextField.canResignFirstResponder {
                canOpen = false
            }
        }
        if canOpen {
            UIView.animate(withDuration: 0.4, animations: {
                self.ccnIsOpen = true
                self.resizeElements()
                self.layoutIfNeeded()
            }, completion: { animate in
                self.delegate?.startEditCreditCard()
                self.focusOnCcnField()
           })
         }
    }

    func expFieldDidBeginEditing(_ sender: UITextField) {
        
        //hideError(expTextField)
    }
    
    func expFieldEditingChanged(_ sender: UITextField) {
        
        BSValidator.expEditingChanged(sender)
        if checkMaxLength(textField: sender, maxLength: 5) == true {
            if sender.text?.characters.count == 5 {
                if expTextField.canResignFirstResponder {
                    focusOnCvvField()
                }
            }
        }
    }

    func cvvFieldDidBeginEditing(_ sender: UITextField) {
        
        //hideError(cvvTextField)
    }
    
    func cvvFieldEditingChanged(_ sender: UITextField) {
        
        BSValidator.cvvEditingChanged(sender)
        var cvvMaxLength = 3
        if cardType == "amex" {
            cvvMaxLength = 4
        }
        if checkMaxLength(textField: sender, maxLength: cvvMaxLength) == true {
            if sender.text?.characters.count == cvvMaxLength {
                if cvvTextField.canResignFirstResponder == true {
                    focusOnNextField()
                }
            }
        }
    }
    
    func nextArrowTouchUpInside(_ sender: Any) {
        
        if textField.canResignFirstResponder {
            focusOnExpField()
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
    
    private func checkMaxLength(textField: UITextField!, maxLength: Int) -> Bool {
        if (textField.text!.removeNoneDigits.characters.count > maxLength) {
            textField.deleteBackward()
            return false
        } else {
            return true
        }
    }

}
