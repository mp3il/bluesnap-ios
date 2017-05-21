//
//  ShippingViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 03/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSShippingViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: shipping data as input and output
    //internal var storyboard : UIStoryboard?
    
    internal var paymentDetails : BSPaymentDetails!
    internal var payText : String!
    internal var submitPaymentFields : () -> BSResultCcDetails? = { return nil }
    internal var countryManager : BSCountryManager!
    
    // MARK: outlets
        
    @IBOutlet weak var payUIButton: UIButton!
    @IBOutlet weak var nameInputLine: BSInputLine!
    @IBOutlet weak var emailInputLine: BSInputLine!
    @IBOutlet weak var streetInputLine: BSInputLine!
    @IBOutlet weak var zipInputLine: BSInputLine!
    @IBOutlet weak var cityInputLine: BSInputLine!
    @IBOutlet weak var stateInputLine: BSInputLine!
    
    
    
    // MARK: for scrolling to prevent keyboard hiding
    
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        fieldBottom = Int(textField.frame.origin.y + textField.frame.height)
    }
    
    // Do we need this?
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
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
    
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if let shippingDetails = self.paymentDetails.getShippingDetails() {
            nameInputLine.setValue(shippingDetails.name)
            emailInputLine.setValue(shippingDetails.email)
            streetInputLine.setValue(shippingDetails.address)
            cityInputLine.setValue(shippingDetails.city)
            zipInputLine.setValue(shippingDetails.zip)
            if (shippingDetails.country == "") {
                shippingDetails.country = Locale.current.regionCode ?? ""
            }
            updateZipByCountry(countryCode: paymentDetails.getShippingDetails()?.country ?? "")
            updateState()
            payUIButton.setTitle(payText, for: UIControlState())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    @IBAction func SubmitClick(_ sender: Any) {
        
        if (validateForm()) {
            
            _ = navigationController?.popViewController(animated: false)
            _ = submitPaymentFields()
            
        } else {
            //return false
        }
    }
    
    
    // MARK: Validation methods
    
    func validateForm() -> Bool {
        
        let ok1 = validateName(ignoreIfEmpty: false)
        let ok2 = validateEmail(ignoreIfEmpty: false)
        let ok3 = validateAddress(ignoreIfEmpty: false)
        let ok4 = validateCity(ignoreIfEmpty: false)
        let ok5 = validateCountryAndZip(ignoreIfEmpty: false)
        let ok6 = validateState(ignoreIfEmpty: false)
        return ok1 && ok2 && ok3 && ok4 && ok5 && ok6
    }
    
    func validateName(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateName(ignoreIfEmpty: ignoreIfEmpty, input: nameInputLine, errorMessage: "Please fill Card holder name", addressDetails: paymentDetails.getShippingDetails())
        return result
    }

    
    
    func validateEmail(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateEmail(ignoreIfEmpty: ignoreIfEmpty, input: emailInputLine, addressDetails: paymentDetails.getShippingDetails())
        return result
    }
    
    func validateAddress(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateAddress(ignoreIfEmpty: ignoreIfEmpty, input: streetInputLine, addressDetails: paymentDetails.getShippingDetails())
        return result
    }
    
    func validateCity(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateCity(ignoreIfEmpty: ignoreIfEmpty, input: cityInputLine, addressDetails: paymentDetails.getShippingDetails())
        return result
    }
    
    func validateCountryAndZip(ignoreIfEmpty : Bool) -> Bool {
        
        if (zipInputLine.isHidden) {
            if let shippingDetails = paymentDetails.getShippingDetails() {
                shippingDetails.zip = ""
            }
            zipInputLine.setValue("")
            return true
        }
        
        var result : Bool = BSValidator.validateCountry(ignoreIfEmpty: ignoreIfEmpty, input: nameInputLine, addressDetails: paymentDetails.getShippingDetails())
        
        if result == true {
            result = BSValidator.validateZip(ignoreIfEmpty: ignoreIfEmpty, input: zipInputLine, addressDetails: paymentDetails.getShippingDetails())
        }
        return result
    }
    
    func validateState(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateState(ignoreIfEmpty: ignoreIfEmpty, input: stateInputLine, addressDetails: paymentDetails.getShippingDetails())
        return result
    }
    
    
    // MARK: real-time formatting and Validations on text fields
    
    @IBAction func nameEditingChanged(_ sender: BSInputLine) {
        BSValidator.nameEditingChanged(sender)
    }
    
    @IBAction func nameEditingDidEnd(_ sender: BSInputLine) {
        _ = validateName(ignoreIfEmpty: true)
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
        _ = validateAddress(ignoreIfEmpty: true)
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
        _ = validateCountryAndZip(ignoreIfEmpty: true)
    }
    
    // enter state field - open the state screen
    @IBAction func stateEditingDidBegin(_ sender: BSInputLine) {
        // prevent typing
        sender.closeKeyboard()
        sender.resignFirstResponder()
        
        BSViewsManager.showStateList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            addressDetails: paymentDetails.getShippingDetails()!,
            updateFunc: updateWithNewState)
    }

    
    // open the country screen
    @IBAction func changeCountry(_ sender: Any) {
        
        let selectedCountryCode = paymentDetails.getShippingDetails()?.country ?? ""
        BSViewsManager.showCountryList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            selectedCountryCode: selectedCountryCode,
            updateFunc: updateWithNewCountry)
    }
    
    
    
    // MARK: private functions
    
    private func updateWithNewCountry(countryCode : String, countryName : String) {
        
        if let shippingDetails = paymentDetails.getShippingDetails() {
            shippingDetails.country = countryCode
            updateZipByCountry(countryCode: countryCode)
        }
        // load the flag image
        if let image = BSViewsManager.getImage(imageName: countryCode.uppercased()) {
            nameInputLine.image = image
        }
    }
    
    private func updateZipByCountry(countryCode: String) {
        
        let hideZip = self.countryManager.countryHasNoZip(countryCode: countryCode)
        if countryCode.lowercased() == "us" {
            zipInputLine.labelText = "Shipping Zip"
            zipInputLine.textField.keyboardType = .numberPad
        } else {
            zipInputLine.labelText = "Postal Code"
            zipInputLine.textField.keyboardType = .numbersAndPunctuation
        }
        zipInputLine.isHidden = hideZip
        zipInputLine.hideError()
    }
    
    private func updateState() {
        
        BSValidator.updateState(addressDetails: paymentDetails.getShippingDetails()!, countryManager: countryManager, stateInputLine: stateInputLine)
    }
    
    private func updateWithNewState(stateCode : String, stateName : String) {
        
        if let shippingDetails = paymentDetails.getShippingDetails() {
            shippingDetails.state = stateCode
        }
        self.stateInputLine.setValue(stateName)
    }
    
}
