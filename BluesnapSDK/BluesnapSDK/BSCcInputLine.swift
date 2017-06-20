//
//  BSCcInputLine.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 22/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

/**
 This protocol should be implemented by the view which owns the BSCcInputLine control; Although the component's functionality is sort-of self-sufficient, we still have some calls to the parent
 */
protocol BSCcInputLineDelegate : class {
    /**
     startEditCreditCard is called when we switch to the "open" state of the component
    */
    func startEditCreditCard()
    /**
     startEditCreditCard is called when we switch to the "closed" state of the component
     */
    func endEditCreditCard()
    /**
     willCheckCreditCard is called just before calling the BlueSnap server to validate the CCN; since this is a longish action, you may want to show an activity indicator
     */
    func willCheckCreditCard()
    /**
     didCheckCreditCard is called just after getting the BlueSnap server result; this is where you hide the activity indicator
     */
    func didCheckCreditCard(result: BSResultCcDetails?, error: BSCcDetailErrors?)
    /**
     didSubmitCreditCard is called at the end of submitPaymentFields() to let the owner know of the submit result; either result or error parameters will be full, so check the error first.
     */
    func didSubmitCreditCard(result: BSResultCcDetails?, error: BSCcDetailErrors?)
    /**
     showAlert is called in case of unexpected errors from the BlueSnap server.
     */
    func showAlert(_ message : String)
}

/**
 BSCcInputLine is a Custom control for CC details input (Credit Card number, expiration date and CVV).
 It inherits configurable properties from BSBaseTextInput that let you adjust the look&feel and adds some.
 [We use BSBaseTextInput for the CCN field and image,and add fields for EXP and CVV.]

 The control has 2 states:
 * Open: when we edit the CC number, the field gets longer, EXP and CVV fields are hidden; a "next" button is shown if the field already has a value
 * Closed: after CCN is entered and validated, the field gets shorter and displays only the last 4 digits; EXP and CVV fields are shown and ediatble; "next" button is hidden.
*/
@IBDesignable
class BSCcInputLine: BSBaseTextInput {

    // MARK: Configurable properties
    
    /**
     showOpenInDesign (default = false) helps you to see the component on the storyboard in both states, open (when you edit the CCN field) or closed (CCn shows only last 4 digits and is not editable, you can edit EXP and CVV fields).
     */
    @IBInspectable var showOpenInDesign: Bool = false {
        didSet {
            if designMode {
                ccnIsOpen = showOpenInDesign
            }
        }
    }
    
    /**
     expPlaceholder (default = "MM/YY") determines the placeholder text for the EXP field
     */
    @IBInspectable var expPlaceholder: String = "MM/YY" {
        didSet {
            self.expTextField.placeholder = expPlaceholder
        }
    }
    /**
     cvcPlaceholder (default = "CVV") determines the placeholder text for the CVV field
     */
    @IBInspectable var cvcPlaceholder: String = "CVV" {
        didSet {
            self.cvvTextField.placeholder = cvcPlaceholder
        }
    }
    
    /**
     ccnWidth (default = 220) determines the CCN text field width in the "open" state (value will change at runtime according to the device)
     */
    @IBInspectable var ccnWidth: CGFloat = 220 {
        didSet {
            resizeElements()
        }
    }
    /**
     last4Width (default = 70) determines the CCN text field width in the "closed" state, when we show only last 4 digits of the CCN (value will change at runtime according to the device)
     */
    @IBInspectable var last4Width: CGFloat = 70 {
        didSet {
            resizeElements()
        }
    }
    /**
     expWidth (default = 70) determines the EXP field width (value will change at runtime according to the device)
     */
    @IBInspectable var expWidth: CGFloat = 70 {
        didSet {
            self.actualExpWidth = expWidth
        }
    }
    /**
     cvvWidth (default = 70) determines the CVV field width (value will change at runtime according to the device)
     */
    @IBInspectable var cvvWidth: CGFloat = 70 {
        didSet {
            resizeElements()
        }
    }
    /**
     errorWidth (default = 150) determines the error width (value will change at runtime according to the device)
     */
    @IBInspectable var errorWidth: CGFloat = 150 {
        didSet {
            resizeElements()
        }
    }
    /**
     nextBtnWidth (default = 20) determines the width of the next button, which shows in the open state when we already have a value in the CCN field (value will change at runtime according to the device)
     */
    @IBInspectable var nextBtnWidth: CGFloat = 22 {
        didSet {
            resizeElements()
        }
    }
    /**
     nextBtnHeight (default = 22) determines the height of the next button, which shows in the open state when we already have a value in the CCN field (value will change at runtime according to the device)
     */
    @IBInspectable var nextBtnHeight: CGFloat = 22 {
        didSet {
            resizeElements()
        }
    }
    /**
     nextBtnHeight (default = internal image, looks like >) determines the image for the next button, which shows in the open state when we already have a value in the CCN field (value will change at runtime according to the device)
     */
    @IBInspectable var nextBtnImage: UIImage?
    
    
    // MARK: public properties

    /**
     When using this control, you need to implement the BSCcInputLineDelegate protocol, and set the control's delegate to be that class
    */
    var delegate : BSCcInputLineDelegate?
    
    var cardType : String = "" {
        didSet {
            updateCcIcon(ccType: cardType)
        }
    }
    
    /**
    ccnIsOpen indicated the state of the control (open or closed)
    */
    var ccnIsOpen : Bool = true {
        didSet {
            self.isEditable = ccnIsOpen ? true : false
            if ccnIsOpen {
                self.textField.text = ccn
            } else {
                self.textField.text = BSStringUtils.last4(ccn)
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
    
    /**
     reset sets the component to its initial state, where the fields are emnpty and we are in the "open" state
    */
    public func reset() {
        hideError(textField)
        hideError(expTextField)
        hideError(cvvTextField)
        textField.text = ""
        expTextField.text = ""
        cvvTextField.text = ""
        ccn = ""
        openCcn()
    }

    /**
     This should be called when you try to navigate away from the current view; it bypasses validations so that the fields will resign first responder
    */
    public func closeOnLeave() {
        closing = true
    }
    
    /**
     The EXP field contains the expiration date in format MM/YY. This function returns the expiration date in format MMYYYY
    */
    public func getExpDateAsMMYYYY() -> String! {
        
        let newValue = self.expTextField.text ?? ""
        if let p = newValue.characters.index(of: "/") {
            let mm = newValue.substring(with: newValue.startIndex..<p)
            let yy = BSStringUtils.removeNoneDigits(newValue.substring(with: p ..< newValue.endIndex))
            let currentYearStr = String(BSValidator.getCurrentYear())
            let p1 = currentYearStr.index(currentYearStr.startIndex, offsetBy: 2)
            let first2Digits = currentYearStr.substring(with: currentYearStr.startIndex..<p1)
            return "\(mm)/\(first2Digits)\(yy)"
        }
        return ""
    }
    
    /**
     Returns the CCN value
    */
    override func getValue() -> String! {
        if self.ccnIsOpen {
            return self.textField.text
        } else {
            return ccn
        }
    }
    
    /**
     Sets the CCN value
     */
    override func setValue(_ newValue: String!) {
        ccn = newValue
        if self.ccnIsOpen {
            self.textField.text = ccn
        }
    }
    
    /**
     Returns the CVV value
     */
    public func getCvv() -> String! {
        return self.cvvTextField.text ?? ""
    }
    
    /**
     Returns the CC Type
     */
    public func getCardType() -> String! {
        return cardType
    }
    
    /**
     Validated the 3 fields; returns true if all are OK; displays errors under the fields if not.
     */
    public func validate() -> Bool {
        
        let result = validateCCN() && validateExp() && validateCvv()
        return result
    }
    
    /**
     Submits the CCN to BlueSnap server; This lets us get the CC issuing country and card type from server, while validating the CCN
     */
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

    /**
     This should be called by the "Pay" button - it submits all the CC details to BlueSnap server, so that later purchase requests to BlueSnap will not need gto contain these values (they will be automatically identified by the token).
     In case of errors from the server (there may be validations we did not catch before), we show the errors under the matching fields.
     After getting the result, we call the delegate's didSubmitCreditCard function.
    */
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

    override func dismissKeyboard() {
        
        if self.textField.isFirstResponder {
            self.textField.resignFirstResponder()
        } else if self.expTextField.isFirstResponder {
            self.expTextField.resignFirstResponder()
        } else if self.cvvTextField.isFirstResponder {
            self.cvvTextField.resignFirstResponder()
        }
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
        
        expTextField.keyboardType = .numberPad
        expTextField.backgroundColor = self.fieldBkdColor
        expTextField.textColor = self.textColor
        expTextField.returnKeyType = UIReturnKeyType.done
        expTextField.borderStyle = .none
        expTextField.placeholder = expPlaceholder

        cvvTextField.keyboardType = .numberPad
        cvvTextField.backgroundColor = self.fieldBkdColor
        cvvTextField.textColor = self.textColor
        cvvTextField.returnKeyType = UIReturnKeyType.done
        cvvTextField.borderStyle = .none
        cvvTextField.placeholder = cvcPlaceholder
        
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
        
        let ccn = BSStringUtils.removeNoneDigits(textField.text ?? "")
        let ccnLength = ccn.characters.count
        
        if ccnLength >= 6 {
            cardType = BSValidator.getCCTypeByRegex(textField.text ?? "")?.lowercased() ?? ""
        }
        let maxLength : Int = BSValidator.getCcLengthByCardType(cardType)
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

    // private/internal functions
    
    func updateCcIcon(ccType : String?) {
        
        // change the image in ccIconImage
        if let image = getCcIconByCardType(ccType: ccType) {
            self.image = image
        }
    }
    
    /**
     This function updates the image that holds the card-type icon according to the chosen card type.
     Override this if necessary.
     */
    func getCcIconByCardType(ccType : String?) -> UIImage? {
        
        var imageName : String?
        if let ccType = ccType?.lowercased() {
            imageName = ccImages[ccType]
        }
        if imageName == nil {
            imageName = "default"
            NSLog("ccTypew \(ccType) does not have an icon")
        }
        return BSViewsManager.getImage(imageName: "cc_\(imageName!)")
    }
    
    private func checkMaxLength(textField: UITextField!, maxLength: Int) -> Bool {
        if (BSStringUtils.removeNoneDigits(textField.text!).characters.count > maxLength) {
            textField.deleteBackward()
            return false
        } else {
            return true
        }
    }

}
