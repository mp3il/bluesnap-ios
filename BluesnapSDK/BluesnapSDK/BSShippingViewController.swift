//
//  ShippingViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 03/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSShippingViewController: UIViewController {
    
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
    
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
