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
    
    @IBOutlet weak var nameUITextField: UITextField!
    @IBOutlet weak var emailUITextField: UITextField!
    @IBOutlet weak var addressUITextField: UITextField!
    @IBOutlet weak var cityUITextField: UITextField!
    @IBOutlet weak var zipUITextField: UITextField!
    @IBOutlet weak var stateUITextField: UITextField!
    @IBOutlet weak var stateUILabel: UILabel!
    @IBOutlet weak var countryFlagButton: UIButton!
    
    
    @IBOutlet weak var nameErrorUILabel: UILabel!
    @IBOutlet weak var emailErrorUILabel: UILabel!
    @IBOutlet weak var addressErrorUILabel: UILabel!
    @IBOutlet weak var cityErrorUILabel: UILabel!
    @IBOutlet weak var zipErrorUILabel: UILabel!
    @IBOutlet weak var stateErrorUILabel: UILabel!
    
    @IBOutlet weak var payUIButton: UIButton!
    
    // MARK: for scrolling to prevent keyboard hiding

    let scrollOffset : Int = -64 // ask Michal why this is???
    var movedUp = false
    var fieldBottom : Int?
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        let y = scrollOffset + 100*direction
        let point : CGPoint = CGPoint(x: 0, y: y)
        self.scrollView.setContentOffset(point, animated: true)
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
        scrollForKeyboard(direction: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        if let shippingDetails = self.paymentDetails.getShippingDetails() {
            nameUITextField.text = shippingDetails.name
            emailUITextField.text = shippingDetails.email
            addressUITextField.text = shippingDetails.address
            cityUITextField.text = shippingDetails.city
            zipUITextField.text = shippingDetails.zip
            if (shippingDetails.country == "") {
                shippingDetails.country = Locale.current.regionCode ?? ""
            }
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
            
            _ = navigationController?.popViewController(animated: true)
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
        
        let result : Bool = BSValidator.validateName(ignoreIfEmpty: ignoreIfEmpty, textField: nameUITextField, errorLabel: nameErrorUILabel, errorMessage: "Please fill Card holder name", addressDetails: paymentDetails.getShippingDetails())
        return result
    }

    func validateEmail(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateEmail(ignoreIfEmpty: ignoreIfEmpty, textField: emailUITextField, errorLabel: emailErrorUILabel, addressDetails: paymentDetails.getShippingDetails())
        return result
    }
    
    func validateAddress(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateAddress(ignoreIfEmpty: ignoreIfEmpty, textField: addressUITextField, errorLabel: addressErrorUILabel, addressDetails: paymentDetails.getShippingDetails())
        return result
    }
    
    func validateCity(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateCity(ignoreIfEmpty: ignoreIfEmpty, textField: cityUITextField, errorLabel: cityErrorUILabel, addressDetails: paymentDetails.getShippingDetails())
        return result
    }
    
    func validateCountryAndZip(ignoreIfEmpty : Bool) -> Bool {
        
        var result : Bool = BSValidator.validateCountry(ignoreIfEmpty: ignoreIfEmpty, errorLabel: zipErrorUILabel, addressDetails: paymentDetails.getShippingDetails())
        
        if result == true {
            result = BSValidator.validateZip(ignoreIfEmpty: ignoreIfEmpty, textField: zipUITextField, errorLabel: zipErrorUILabel, addressDetails: paymentDetails.getShippingDetails())
        }
        return result
    }
    
    func validateState(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateState(ignoreIfEmpty: ignoreIfEmpty, textField: stateUITextField, errorLabel: stateErrorUILabel, addressDetails: paymentDetails.getShippingDetails())
        return result
    }

    
    // MARK: real-time formatting and Validations on text fields
    
    @IBAction func nameEditingChanged(_ sender: UITextField) {
        BSValidator.nameEditingChanged(sender)
    }
    
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        BSValidator.emailEditingChanged(sender)
    }
    
    @IBAction func addressEditingChanged(_ sender: UITextField) {
        BSValidator.addressEditingChanged(sender)
    }
    
    @IBAction func cityEditingChanged(_ sender: UITextField) {
        BSValidator.cityEditingChanged(sender)
    }
    
    @IBAction func zipEditingChanged(_ sender: UITextField) {
        BSValidator.zipEditingChanged(sender)
    }
    
    @IBAction func stateEditingChanged(_ sender: UITextField) {
        sender.text = "" // prevent typing - open pop-up insdtead
        self.statetouchDown(sender)
    }
    
    @IBAction func nameEditingDidEnd(_ sender: UITextField) {
        _ = validateName(ignoreIfEmpty: true)
    }
    
    @IBAction func emailEditingDidEnd(_ sender: UITextField) {
        _ = validateEmail(ignoreIfEmpty: true)
    }
    
    @IBAction func addressEditingDidEnd(_ sender: UITextField) {
        _ = validateAddress(ignoreIfEmpty: true)
    }
    
    @IBAction func cityEditingDidEnd(_ sender: UITextField) {
        _ = validateCity(ignoreIfEmpty: true)
    }
    
    @IBAction func zipEditingDidEnd(_ sender: UITextField) {
        _ = validateCountryAndZip(ignoreIfEmpty: true)
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
    
    // enter state field - open the state screen
    @IBAction func statetouchDown(_ sender: Any) {
        
        self.stateUITextField.resignFirstResponder()

        BSViewsManager.showStateList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            addressDetails: paymentDetails.getShippingDetails()!,
            updateFunc: updateWithNewState)
    }
    

    // MARK: private functions
    
    private func updateWithNewCountry(countryCode : String, countryName : String) {
        
        if let shippingDetails = paymentDetails.getShippingDetails() {
            shippingDetails.country = countryCode
        }
        // load the flag image
        if let image = BSViewsManager.getImage(imageName: countryCode.uppercased()) {
            self.countryFlagButton.imageView?.image = image
        }
    }
    
    private func updateState() {
        
        BSValidator.updateState(addressDetails: paymentDetails.getShippingDetails()!, countryManager: countryManager, stateUILabel: stateUILabel, stateUITextField: stateUITextField, stateErrorUILabel: stateErrorUILabel)
    }
    
    private func updateWithNewState(stateCode : String, stateName : String) {
        
        if let shippingDetails = paymentDetails.getShippingDetails() {
            shippingDetails.state = stateCode
        }
        self.stateUITextField.text = stateName
    }

}
