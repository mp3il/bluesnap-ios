//
//  BSPaymentViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 21/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSPaymentViewController: UIViewController, UITextFieldDelegate, BSCcInputLineDelegate {

    
    // MARK: private properties
    
    fileprivate var newCardMode = true
    fileprivate var withShipping = false
    fileprivate var fullBilling = false
    fileprivate var withEmail = true
    fileprivate var cardType : String?
    fileprivate var activityIndicator : UIActivityIndicatorView?
    fileprivate var firstTime : Bool = true
    fileprivate var firstTimeShipping : Bool = true
    fileprivate var payButtonText : String?
    fileprivate var zipTopConstraintOriginalConstant : CGFloat?
    fileprivate var paymentRequest : BSCcPaymentRequest!
    fileprivate var existingPaymentRequest : BSCcPaymentRequest?
    fileprivate var updateTaxFunc: ((_ shippingCountry: String, _ shippingState: String?, _ priceDetails: BSPriceDetails) -> Void)?
    fileprivate var countryManager = BSCountryManager.getInstance()
    
    // MARK: - Outlets
    
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var subtotalAndTaxDetailsView: BSSubtotalUIView!
    
    @IBOutlet weak var ccInputLine: BSCcInputLine!
    @IBOutlet weak var existingCcView: BSExistingCcUIView!
    
    @IBOutlet weak var nameInputLine: BSInputLine!
    @IBOutlet weak var emailInputLine: BSInputLine!
    @IBOutlet weak var streetInputLine: BSInputLine!
    @IBOutlet weak var zipInputLine: BSInputLine!
    @IBOutlet weak var cityInputLine: BSInputLine!
    @IBOutlet weak var stateInputLine: BSInputLine!
    
    @IBOutlet weak var shippingSameAsBillingView: UIView!
    @IBOutlet weak var shippingSameAsBillingSwitch: UISwitch!
    @IBOutlet weak var shippingSameAsBillingLabel: UILabel!
    
    @IBOutlet weak var zipTopConstraint: NSLayoutConstraint!
    
    // MARK: init

    public func initScreen(paymentRequest: BSCcPaymentRequest!) {
        
        self.firstTime = true
        self.firstTimeShipping = true
        if let data = BlueSnapSDK.initialData {
            self.fullBilling = data.fullBilling
            self.withEmail = data.withEmail
            self.withShipping = data.withShipping
            self.updateTaxFunc = data.updateTaxFunc
        }
        if let _ = paymentRequest as? BSExistingCcPaymentRequest {
            newCardMode = false
            self.existingPaymentRequest = paymentRequest
            self.paymentRequest = paymentRequest.copy() as! BSCcPaymentRequest as? BSExistingCcPaymentRequest                
        } else {
            self.paymentRequest = paymentRequest
        }
    }
    
    // MARK: Keyboard functions
    
    let scrollOffset : Int = -64 // this is the Y of scrollView
    var movedUp = false
    var fieldBottom : Int?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fieldsView: UIView!
    
    override func viewDidLayoutSubviews()
    {
        let scrollViewBounds = scrollView.bounds
        //let containerViewBounds = fieldsView.bounds
        
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = scrollViewBounds.size.height/2.0;
        scrollViewInsets.top -= fieldsView.bounds.size.height/2.0;
        
        scrollViewInsets.bottom = scrollViewBounds.size.height/2.0
        scrollViewInsets.bottom -= fieldsView.bounds.size.height/2.0;
        scrollViewInsets.bottom += 1
        
        scrollView.contentInset = scrollViewInsets
    }
    
    @IBAction func editingDidBegin(_ sender: BSBaseTextInput) {
        
        fieldBottom = Int(sender.frame.origin.y + sender.frame.height)
    }
    
    private func scrollForKeyboard(direction: Int) {
        
        self.movedUp = (direction > 0)
        let y = 200*direction
        let point : CGPoint = CGPoint(x: 0, y: y)
        self.scrollView.setContentOffset(point, animated: false)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        var moveUp = false
        if let fieldBottom = fieldBottom {
            let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
            let keyboardFrame = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! CGRect
            let keyboardHeight = Int(keyboardFrame.height)
            let viewHeight : Int = Int(self.view.frame.height)
            let offset = fieldBottom + keyboardHeight - scrollOffset
            if (offset > viewHeight) {
                moveUp = true
            }
        }
        
        if !self.movedUp && moveUp {
            scrollForKeyboard(direction: 1)
        } else if self.movedUp && !moveUp {
            scrollForKeyboard(direction: 0)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if self.movedUp {
            scrollForKeyboard(direction: 0)
        }
    }
    
    func registerTapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        
        self.ccInputLine.dismissKeyboard()
        self.nameInputLine.dismissKeyboard()
        self.emailInputLine.dismissKeyboard()
        self.zipInputLine.dismissKeyboard()
        self.streetInputLine.dismissKeyboard()
        self.cityInputLine.dismissKeyboard()
    }

    // MARK: BSCcInputLineDelegate methods
    
    
    func startEditCreditCard() {
        hideShowFields()
    }
    
    func endEditCreditCard() {
        hideShowFields()
    }

    func willCheckCreditCard() {
    }
    
    func didCheckCreditCard(ccDetails: BSCcDetails, error: BSErrors?) {
        if error == nil {
            paymentRequest.ccDetails = ccDetails
            if let issuingCountry = ccDetails.ccIssuingCountry {
                self.updateWithNewCountry(countryCode: issuingCountry, countryName: "")
            }
        }
    }
    
    func didSubmitCreditCard(ccDetails: BSCcDetails, error: BSErrors?) {

        if let navigationController = self.navigationController {
            
            let viewControllers = navigationController.viewControllers
            let topController = viewControllers[viewControllers.count-1]
            let inShippingScreen = topController != self            
            self.stopActivityIndicator()
            
            if error == nil {
                paymentRequest.ccDetails = ccDetails
                // return to merchant screen
                let merchantControllerIndex = viewControllers.count - (inShippingScreen ? 4 : 3)
                _ = navigationController.popToViewController(viewControllers[merchantControllerIndex], animated: false)
                // execute callback
                BlueSnapSDK.initialData?.purchaseFunc(self.paymentRequest)
            } else {
                // error
                if inShippingScreen {
                    _ = navigationController.popViewController(animated: false)
                }
            }
        }
    }
    
    
    func showAlert(_ message : String) {
        let alert = BSViewsManager.createErrorAlert(title: BSLocalizedString.Error_Title_Payment, message: message)
        present(alert, animated: true, completion: nil)
    }

    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ccInputLine.delegate = self
        
        emailInputLine.fieldKeyboardType = .emailAddress
        activityIndicator = BSViewsManager.createActivityIndicator(view: self.view)
        if let zipTopConstraint = self.zipTopConstraint {
            zipTopConstraintOriginalConstant = zipTopConstraint.constant
        }
        
        /*NotificationCenter.default.addObserver(
            self,
            selector:  #selector(deviceDidRotate),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )*/
        registerTapToHideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.navigationController!.isNavigationBarHidden = false
        
        shippingSameAsBillingView.isHidden = !self.withShipping || !self.fullBilling
        
        // set the 'shipping same as billing' to be true if no shipping name is supplied
        if self.firstTime == true {
            
            shippingSameAsBillingSwitch.isOn = self.paymentRequest.getShippingDetails()?.name ?? "" == ""

            // in case of empty shipping country - fill with default and call updateTaxFunc
            if withShipping && paymentRequest.shippingDetails!.country ?? "" == "" {
                let defaultCountry = NSLocale.current.regionCode ?? BSCountryManager.US_COUNTRY_CODE
                paymentRequest.shippingDetails!.country = defaultCountry
                callUpdateTax(ifSameAsBilling: false, ifNotSameAsBilling: true)
            }
        }
        
        updateTexts()
        updateAmounts()

        if self.firstTime == true {
            self.firstTime = false
            if let billingDetails = self.paymentRequest.getBillingDetails() {
                self.nameInputLine.setValue(billingDetails.name)
                self.emailInputLine.setValue(billingDetails.email)
                self.zipInputLine.setValue(billingDetails.zip)
                if fullBilling {
                    self.streetInputLine.setValue(billingDetails.address)
                    self.cityInputLine.setValue(billingDetails.city)
                }
            }
            nameInputLine.hideError()
            emailInputLine.hideError()
            streetInputLine.hideError()
            zipInputLine.hideError()
            cityInputLine.hideError()
            stateInputLine.hideError()
            if (!newCardMode) {
                ccInputLine.closeOnLeave()
            } else {
                ccInputLine.reset()
            }
        }
        hideShowFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        if newCardMode && ccInputLine.ccnIsOpen == true {
            self.ccInputLine.focusOnCcnField()
        } else {
            self.nameInputLine.becomeFirstResponder()
        }
        //adjustToPageRotate()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        if newCardMode {
            ccInputLine.closeOnLeave()
        }
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }


    /*private func adjustToPageRotate() {
        
        DispatchQueue.main.async{
            
            self.ccInputLine.deviceDidRotate()
            self.nameInputLine.deviceDidRotate()
            self.emailInputLine.deviceDidRotate()
            self.streetInputLine.deviceDidRotate()
            self.zipInputLine.deviceDidRotate()
            self.cityInputLine.deviceDidRotate()
            self.stateInputLine.deviceDidRotate()
            
            self.deviceDidRotate()
            
            self.viewDidLayoutSubviews()
        }
    }*/
    
    private func isShippingSameAsBilling() -> Bool {
        return self.withShipping && self.fullBilling && self.shippingSameAsBillingSwitch.isOn
    }
    
    private func hideShowFields() {
        
        if let paymentRequest = paymentRequest as? BSExistingCcPaymentRequest {
            ccInputLine.isHidden = true
            existingCcView.isHidden = false
            let ccDetails = paymentRequest.existingCcDetails
            existingCcView.setCc(ccType: ccDetails.ccType ?? "", last4Digits: ccDetails.last4Digits ?? "", expiration: ccDetails.getExpiration())
        } else {
            ccInputLine.isHidden = false
            existingCcView.isHidden = true
        }
        
        if newCardMode && self.ccInputLine.ccnIsOpen {
            // hide everything
            nameInputLine.isHidden = true
            emailInputLine.isHidden = true
            streetInputLine.isHidden = true
            cityInputLine.isHidden = true
            zipInputLine.isHidden = true
            stateInputLine.isHidden = true
            shippingSameAsBillingView.isHidden = true
            subtotalAndTaxDetailsView.isHidden = true
        } else {
            nameInputLine.isHidden = false
            emailInputLine.isHidden = !self.withEmail
            let hideFields = !self.fullBilling
            streetInputLine.isHidden = hideFields
            let countryCode = self.paymentRequest.getBillingDetails().country ?? ""
            updateZipByCountry(countryCode: countryCode)
            updateFlagImage(countryCode: countryCode)
            cityInputLine.isHidden = hideFields
            updateState()
            shippingSameAsBillingView.isHidden = !self.withShipping || !self.fullBilling
            subtotalAndTaxDetailsView.isHidden = !newCardMode && self.paymentRequest.getTaxAmount() == 0
            updateZipFieldLocation()
        }
    }
    
    /*func deviceDidRotate() {
    }*/

    private func updateState() {
        
        if (fullBilling) {
            BSValidator.updateState(addressDetails: paymentRequest.getBillingDetails(), stateInputLine: stateInputLine)
        } else {
            stateInputLine.isHidden = true
        }
    }
    
    private func updateTexts() {
        
        self.title = BSLocalizedStrings.getString(BSLocalizedString.Title_Payment_Screen)
        updateAmounts()
        
        self.nameInputLine.labelText = BSLocalizedStrings.getString(BSLocalizedString.Label_Name)
        self.emailInputLine.labelText = BSLocalizedStrings.getString(BSLocalizedString.Label_Email)
        self.streetInputLine.labelText = BSLocalizedStrings.getString(BSLocalizedString.Label_Street)
        self.cityInputLine.labelText = BSLocalizedStrings.getString(BSLocalizedString.Label_City)
        self.stateInputLine.labelText = BSLocalizedStrings.getString(BSLocalizedString.Label_State)
        
        self.nameInputLine.placeHolder = BSLocalizedStrings.getString(BSLocalizedString.Placeholder_Name)
        
        self.shippingSameAsBillingLabel.text = BSLocalizedStrings.getString(BSLocalizedString.Label_Shipping_Same_As_Billing)
    }
    
    private func updateAmounts() {

        if self.ccInputLine.ccnIsOpen {
            subtotalAndTaxDetailsView.isHidden = true
        } else {
            subtotalAndTaxDetailsView.isHidden = !newCardMode && self.paymentRequest.getTaxAmount() == 0
        }

        let toCurrency = paymentRequest.getCurrency() ?? ""
        let subtotalAmount = paymentRequest.getAmount() ?? 0.0
        let taxAmount = paymentRequest.getTaxAmount() ?? 0.0
        subtotalAndTaxDetailsView.setAmounts(subtotalAmount: subtotalAmount, taxAmount: taxAmount, currency: toCurrency)
        
        if newCardMode {
            payButtonText = BSViewsManager.getPayButtonText(subtotalAmount: subtotalAmount, taxAmount: taxAmount, toCurrency: toCurrency)
        } else {
            payButtonText = BSLocalizedStrings.getString(BSLocalizedString.Keyboard_Done_Button_Text)
        }
        updatePayButtonText()
    }

    private func updatePayButtonText() {
        
        if (newCardMode && self.withShipping && !isShippingSameAsBilling()) {
            let shippingButtonText = BSLocalizedStrings.getString(BSLocalizedString.Payment_Shipping_Button)
            payButton.setTitle(shippingButtonText, for: UIControlState())
        } else {
            payButton.setTitle(payButtonText, for: UIControlState())
        }
    }
    
    func submitPaymentFields() {
        
        self.ccInputLine.submitPaymentFields()
    }
    
    private func gotoShippingScreen() {
        
        BSViewsManager.showShippingScreen(
            paymentRequest: paymentRequest,
            submitPaymentFields: submitPaymentFields,
            validateOnEntry: !firstTimeShipping,
            inNavigationController: self.navigationController!,
            animated: true)
    }
    
    
    private func updateWithNewCountry(countryCode : String, countryName : String) {
        
        paymentRequest.getBillingDetails().country = countryCode
        updateZipByCountry(countryCode: countryCode)
        updateState()
        
        // load the flag image
        updateFlagImage(countryCode: countryCode.uppercased())

        callUpdateTax(ifSameAsBilling: true, ifNotSameAsBilling: false)
    }

    private func updateZipByCountry(countryCode : String) {

        let hideZip = BSCountryManager.getInstance().countryHasNoZip(countryCode: countryCode)
        self.zipInputLine.labelText = BSValidator.getZipLabelText(countryCode: countryCode, forBilling: true)
        self.zipInputLine.fieldKeyboardType = BSValidator.getZipKeyboardType(countryCode: countryCode)
        self.zipInputLine.isHidden = hideZip
        self.zipInputLine.hideError()
        //self.streetInputLine.fieldKeyboardType = .numbersAndPunctuation
    }
    
    private func updateWithNewState(stateCode : String, stateName : String) {
        
        paymentRequest.getBillingDetails().state = stateCode
        self.stateInputLine.setValue(stateName)
        callUpdateTax(ifSameAsBilling: true, ifNotSameAsBilling: false)
    }
    
    private func updateFlagImage(countryCode : String) {
        
        // load the flag image
        if let image = BSViewsManager.getImage(imageName: countryCode.uppercased()) {
            nameInputLine.image = image
        }
    }

    private func updateZipFieldLocation() {
        
        if !zipInputLine.isHidden {
            if withEmail {
                zipTopConstraint.constant = zipTopConstraintOriginalConstant ?? 1
            } else {
                zipTopConstraint.constant = -1 * emailInputLine.frame.height
            }
        } else {
            if withEmail {
                zipTopConstraint.constant = -1 * emailInputLine.frame.height
            } else {
                zipTopConstraint.constant = -2 * emailInputLine.frame.height
            }
        }
    }
    
    // MARK: menu actions
    
    private func updateCurrencyFunc(oldCurrency : BSCurrency?, newCurrency : BSCurrency?) {
        
        paymentRequest.changeCurrency(oldCurrency: oldCurrency, newCurrency: newCurrency)
        updateAmounts()
    }
    
    @IBAction func MenuClick(_ sender: UIBarButtonItem) {
        
        let menu : UIAlertController = BSViewsManager.openPopupMenu(paymentRequest: paymentRequest, inNavigationController: self.navigationController!, updateCurrencyFunc: updateCurrencyFunc, errorFunc: {
                let errorMessage = BSLocalizedStrings.getString(BSLocalizedString.Error_General_Payment_error)
                self.showAlert(errorMessage)
            })
        present(menu, animated: true, completion: nil)
    }
    
    // MARK: button actions
    
    @IBAction func shippingSameAsBillingValueChanged(_ sender: Any) {

        callUpdateTax(ifSameAsBilling: true, ifNotSameAsBilling: true)
        updateAmounts()
    }

    private func callUpdateTax(ifSameAsBilling: Bool, ifNotSameAsBilling: Bool) {

        if updateTaxFunc != nil && self.withShipping {
            var country: String = ""
            var state: String?
            var callFunc: Bool = false
            if ifSameAsBilling && isShippingSameAsBilling() {
                country = paymentRequest.billingDetails.country!
                state = paymentRequest.billingDetails.state
                callFunc = true
            } else if ifNotSameAsBilling && !isShippingSameAsBilling() {
                let defaultCountry = NSLocale.current.regionCode ?? BSCountryManager.US_COUNTRY_CODE
                country = paymentRequest.shippingDetails?.country ?? defaultCountry
                state = paymentRequest.shippingDetails?.state
                callFunc = true
            }
            if callFunc {
                updateTaxFunc!(country, state, paymentRequest.priceDetails)
            }
        }
    }

    @IBAction func clickPay(_ sender: UIButton) {
        
        if (validateForm()) {
            
            if !newCardMode {
                updateExistingPaymentRequestAndGoBack()
            } else if (withShipping && !isShippingSameAsBilling()) {
                updateAmounts()
                gotoShippingScreen()
            } else {
                startActivityIndicator()
                submitPaymentFields()
            }
        } else {
            //return false
        }
    }

    private func updateExistingPaymentRequestAndGoBack() {
        
        // copy billing values from payment request to existingPaymentRequest
        existingPaymentRequest?.billingDetails = paymentRequest.billingDetails
        
        if isShippingSameAsBilling() {
            // copy shipping values from payment request to existingPaymentRequest
            existingPaymentRequest?.shippingDetails = paymentRequest.shippingDetails
        }
        
        // go back to existing page
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Validation methods
    
    func validateForm() -> Bool {
        
        let ok1 = validateName(ignoreIfEmpty: false)
        let ok2 = newCardMode ? ccInputLine.validate() : true
        var result = ok1 && ok2
        
        if fullBilling {
            let ok1 = validateEmail(ignoreIfEmpty: false)
            let ok2 = validateCity(ignoreIfEmpty: false)
            let ok3 = validateStreet(ignoreIfEmpty: false)
            let ok4 = validateCity(ignoreIfEmpty: false)
            let ok5 = validateZip(ignoreIfEmpty: false)
            let ok6 = validateState(ignoreIfEmpty: false)
            result = result && ok1 && ok2 && ok3 && ok4 && ok5 && ok6
        } else {
            let ok1 = validateEmail(ignoreIfEmpty: true)
            let ok2 = zipInputLine.isHidden ? true : validateZip(ignoreIfEmpty: false)
            result = result && ok1 && ok2
        }
        
        if result && isShippingSameAsBilling() {
            // copy billing details to shipping
            if let shippingDetails = self.paymentRequest.getShippingDetails(), let billingDetails = self.paymentRequest.getBillingDetails() {
                shippingDetails.address = billingDetails.address
                shippingDetails.city = billingDetails.city
                shippingDetails.country = billingDetails.country
                shippingDetails.name = billingDetails.name
                shippingDetails.state = billingDetails.state
                shippingDetails.zip = billingDetails.zip
            }
        }
        
        return result
    }
    
    func validateName(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateName(ignoreIfEmpty: ignoreIfEmpty, input: nameInputLine, addressDetails: paymentRequest.getBillingDetails())
        return result
    }
    
    func validateEmail(ignoreIfEmpty : Bool) -> Bool {
        
        if emailInputLine.isHidden {
            return true
        }
        let result : Bool = BSValidator.validateEmail(ignoreIfEmpty: ignoreIfEmpty, input: emailInputLine, addressDetails: paymentRequest.getBillingDetails())
        return result
    }
    
    func validateStreet(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateStreet(ignoreIfEmpty: ignoreIfEmpty, input: streetInputLine, addressDetails: paymentRequest.getBillingDetails())
        return result
    }
    
    func validateCity(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateCity(ignoreIfEmpty: ignoreIfEmpty, input: cityInputLine, addressDetails: paymentRequest.getBillingDetails())
        return result
    }

    func validateZip(ignoreIfEmpty : Bool) -> Bool {
        
        if (zipInputLine.isHidden) {
            paymentRequest.getBillingDetails().zip = ""
            zipInputLine.setValue("")
            return true
        }
        
        // make zip optional for cards other than visa/discover
        var ignoreEmptyZip = ignoreIfEmpty
        let ccType = self.ccInputLine.getCardType().lowercased()
        if !ignoreIfEmpty && !fullBilling && ccType != "visa" && ccType != "discover" {
            ignoreEmptyZip = true
        }
        
        let result = BSValidator.validateZip(ignoreIfEmpty: ignoreEmptyZip, input: zipInputLine, addressDetails: paymentRequest.getBillingDetails())
        return result
    }
    
    func validateState(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateState(ignoreIfEmpty: ignoreIfEmpty, input: stateInputLine, addressDetails: paymentRequest.getBillingDetails())
        return result
    }

    
    // MARK: activity indicator methods
    
    func startActivityIndicator() {
        BSViewsManager.startActivityIndicator(activityIndicator: self.activityIndicator, blockEvents: true)
    }
    func stopActivityIndicator() {
        BSViewsManager.stopActivityIndicator(activityIndicator: self.activityIndicator)
    }

    
    // MARK: real-time formatting and Validations on text fields
    
    @IBAction func nameEditingChanged(_ sender: BSInputLine) {
        
        BSValidator.nameEditingChanged(sender)
    }
    
    @IBAction func nameEditingDidEnd(_ sender: BSInputLine) {
        _ = validateName(ignoreIfEmpty: true)
    }

    @IBAction func countryFlagClick(_ sender: BSInputLine) {
        
        // open the country screen
        let selectedCountryCode = paymentRequest.getBillingDetails().country ?? ""
        BSViewsManager.showCountryList(
            inNavigationController: self.navigationController,
            animated: true,
            selectedCountryCode: selectedCountryCode,
            updateFunc: updateWithNewCountry)
    }

    @IBAction func emailEditingChanged(_ sender: BSInputLine) {
        BSValidator.emailEditingChanged(sender)
    }
    
    @IBAction func emailEditingDidEnd(_ sender: BSInputLine) {
        _ = validateEmail(ignoreIfEmpty: true)
    }
    
    @IBAction func streetEditingChanged(_ sender: BSInputLine) {
        BSValidator.addressEditingChanged(sender)
    }
    
    @IBAction func streetEditingDidEnd(_ sender: BSInputLine) {
        _ = validateStreet(ignoreIfEmpty: true)
    }
    
    @IBAction func streetEditingDidBegin(_ sender: BSInputLine) {
        
        editingDidBegin(sender)
        if streetInputLine.getValue() == "" {
            streetInputLine.fieldKeyboardType = .numbersAndPunctuation
        } else {
            streetInputLine.fieldKeyboardType = .default
        }
    }
    
    @IBAction func cityEditingChanged(_ sender: BSInputLine) {
        BSValidator.cityEditingChanged(sender)
    }
    
    @IBAction func cityEditingDidEnd(_ sender: BSInputLine) {
        _ = validateCity(ignoreIfEmpty: true)
    }
    
    @IBAction func zipEditingChanged(_ sender: BSInputLine) {
        BSValidator.zipEditingChanged(sender)
    }
    
    @IBAction func zipEditingDidEnd(_ sender: BSInputLine) {
        _ = validateZip(ignoreIfEmpty: true)
    }
    
    @IBAction func stateClick(_ sender: BSInputLine) {
        
        // open the state screen
        BSViewsManager.showStateList(
            inNavigationController: self.navigationController,
            animated: true,
            addressDetails: paymentRequest.getBillingDetails(),
            updateFunc: updateWithNewState)
    }

    // MARK: Prevent rotation, support only Portrait mode
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

}
