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

    internal var purchaseData : PurchaseData!
    internal var payText : String!
    
    // MARK: outlets
    
    @IBOutlet weak var nameUITextField: UITextField!
    @IBOutlet weak var emailUITextField: UITextField!
    @IBOutlet weak var addressUITextField: UITextField!
    @IBOutlet weak var cityUITextField: UITextField!
    @IBOutlet weak var zipUITextField: UITextField!
    @IBOutlet weak var countryUITextField: UITextField!
    @IBOutlet weak var stateUITextField: UITextField!
    
    @IBOutlet weak var stateUILabel: UILabel!
    
    
    @IBOutlet weak var nameErrorUILabel: UILabel!
    @IBOutlet weak var emailErrorUILabel: UILabel!
    @IBOutlet weak var addressErrorUILabel: UILabel!
    @IBOutlet weak var cityErrorUILabel: UILabel!
    @IBOutlet weak var zipErrorUILabel: UILabel!
    @IBOutlet weak var countryErrorUILabel: UILabel!
    @IBOutlet weak var stateErrorUILabel: UILabel!
    
    @IBOutlet weak var payUIButton: UIButton!
    
    // MARK: private properties
    var countryManager = BSCountryManager()
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            nameUITextField.text = shippingDetails.name
            emailUITextField.text = shippingDetails.email
            addressUITextField.text = shippingDetails.address
            cityUITextField.text = shippingDetails.city
            zipUITextField.text = shippingDetails.zip
            if (shippingDetails.country == "") {
                shippingDetails.country = Locale.current.regionCode ?? ""
            }
            countryUITextField.text = countryManager.getCountryName(countryCode: shippingDetails.country)
            updateState()
            payUIButton.setTitle(payText, for: UIControlState())
        }
    }
    
    
    @IBAction func CheckoutClick(_ sender: Any) {
        
        
        
    }
    
    
    // MARK: Validation methods
    
    func validateForm() -> Bool {
        
        let ok1 = validateName(ignoreIfEmpty: false)
        let ok2 = validateEmail(ignoreIfEmpty: false)
        let ok3 = validateAddress(ignoreIfEmpty: false)
        let ok4 = validateCity(ignoreIfEmpty: false)
        let ok5 = validateZip(ignoreIfEmpty: false)
        let ok6 = validateCountry(ignoreIfEmpty: false)
        let ok7 = validateState(ignoreIfEmpty: false)
        return ok1 && ok2 && ok3 && ok4 && ok5 && ok6 && ok7
    }
    
    func validateName(ignoreIfEmpty : Bool) -> Bool {
        
        let newValue = nameUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.name = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 4) {
            nameErrorUILabel.text = "Please fill Card holder name"
            nameErrorUILabel.isHidden = false
            result = false
        } else {
            nameErrorUILabel.isHidden = true
            result = true
        }
        return result
    }

    func validateEmail(ignoreIfEmpty : Bool) -> Bool {
        
        let newValue = emailUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.email = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (!newValue.isValidEmail) {
            emailErrorUILabel.text = "Please fill a valid email address"
            emailErrorUILabel.isHidden = false
            result = false
        } else {
            emailErrorUILabel.isHidden = true
            result = true
        }
        return result
    }
    
    func validateAddress(ignoreIfEmpty : Bool) -> Bool {
        
        let newValue = addressUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.address = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 3) {
            addressErrorUILabel.text = "Please fill a valid address"
            addressErrorUILabel.isHidden = false
            result = false
        } else {
            addressErrorUILabel.isHidden = true
            result = true
        }
        return result
    }
    
    func validateCity(ignoreIfEmpty : Bool) -> Bool {
        
        let newValue = cityUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.city = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 3) {
            cityErrorUILabel.text = "Please fill a valid city"
            cityErrorUILabel.isHidden = false
            result = false
        } else {
            cityErrorUILabel.isHidden = true
            result = true
        }
        return result
    }
    
    func validateZip(ignoreIfEmpty : Bool) -> Bool {
        
        let newValue = zipUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.zip = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 3) {
            zipErrorUILabel.text = "Please fill a valid zip code"
            zipErrorUILabel.isHidden = false
            result = false
        } else {
            zipErrorUILabel.isHidden = true
            result = true
        }
        return result
    }
    
    func validateCountry(ignoreIfEmpty : Bool) -> Bool {
        
        let newValue = self.purchaseData.getShippingDetails()?.country ?? ""
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 2) {
            countryErrorUILabel.text = "Please fill a valid country"
            countryErrorUILabel.isHidden = false
            result = false
        } else {
            countryErrorUILabel.isHidden = true
            result = true
        }
        return result
    }
    
    func validateState(ignoreIfEmpty : Bool) -> Bool {
        
        let newValue = stateUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.state = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 2) {
            stateErrorUILabel.text = "Please fill a valid state"
            stateErrorUILabel.isHidden = false
            result = false
        } else {
            stateErrorUILabel.isHidden = true
            result = true
        }
        return result
    }

    
    // MARK: real-time formatting and Validations on text fields
    
    @IBAction func nameEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneAlphaCharacters.cutToMaxLength(maxLength: 100)
        sender.text = input
    }
    
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneEmailCharacters.cutToMaxLength(maxLength: 1200)
        sender.text = input
    }
    
    @IBAction func addressEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.cutToMaxLength(maxLength: 100)
        sender.text = input
    }
    
    @IBAction func cityEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneAlphaCharacters.cutToMaxLength(maxLength: 50)
        sender.text = input
    }
    
    @IBAction func zipEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.cutToMaxLength(maxLength: 20)
        sender.text = input
    }
    
    @IBAction func countryEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneAlphaCharacters.cutToMaxLength(maxLength: 2)
        sender.text = input
    }
    
    @IBAction func stateEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneAlphaCharacters.cutToMaxLength(maxLength: 2)
        sender.text = input
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
        _ = validateZip(ignoreIfEmpty: true)
    }
    
    @IBAction func countryEditingDidEnd(_ sender: UITextField) {
        _ = validateCountry(ignoreIfEmpty: true)
        updateState()
    }
    
    @IBAction func stateEditingDidEnd(_ sender: UITextField) {
        _ = validateState(ignoreIfEmpty: true)
    }
    
    
    // enter country field - open the country screen
    @IBAction func countryTouchDown(_ sender: Any) {
        
        let selectedCountryCode = purchaseData.getShippingDetails()?.country ?? ""
        BSViewsManager.showCountryList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            selectedCountryCode: selectedCountryCode,
            updateFunc: updateWithNewCountry)
    }
    
    // enter state field - open the state screen
    @IBAction func statetouchDown(_ sender: Any) {
        let selectedCountryCode = purchaseData.getShippingDetails()?.country ?? ""
        let selectedStateCode = purchaseData.getShippingDetails()?.state ?? ""
        BSViewsManager.showStateList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            selectedCountryCode: selectedCountryCode,
            selectedStateCode: selectedStateCode,
            updateFunc: updateWithNewState)
    }
    

    // MARK: private functions
    
    private func updateWithNewCountry(countryCode : String, countryName : String) {
        
        if let shippingDetails = purchaseData.getShippingDetails() {
            shippingDetails.country = countryCode
        }
        self.countryUITextField.text = countryName
    }
    
    private func updateState() {
        let selectedCountryCode = purchaseData.getShippingDetails()?.country ?? ""
        let selectedStateCode = purchaseData.getShippingDetails()?.state ?? ""
        var hideState : Bool = true
        if let states = countryManager.countryStates(countryCode: selectedCountryCode){
            stateUITextField.text = states[selectedStateCode]
            hideState = false
        }
        stateUITextField.isHidden = hideState
        stateUILabel.isHidden = hideState
        stateErrorUILabel.isHidden = true
    }
    
    private func updateWithNewState(stateCode : String, stateName : String) {
        
        if let shippingDetails = purchaseData.getShippingDetails() {
            shippingDetails.state = stateCode
        }
        self.stateUITextField.text = stateName
    }

}
