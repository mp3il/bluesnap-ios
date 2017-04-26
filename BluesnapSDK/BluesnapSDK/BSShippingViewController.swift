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
            countryUITextField.text = countryManager.getCountryName(countryCode: shippingDetails.country)
            stateUITextField.text = shippingDetails.state
            payUIButton.setTitle(payText, for: UIControlState())
        }
    }
    
    // MARK: Validation methods
    
    func validateForm() -> Bool {
        
        let ok1 = validateName()
        let ok2 = validateEmail()
        let ok3 = validateAddress()
        let ok4 = validateCity()
        let ok5 = validateZip()
        let ok6 = validateCountry()
        let ok7 = validateState()
        return ok1 && ok2 && ok3 && ok4 && ok5 && ok6 && ok7
    }
    
    func validateName() -> Bool {
        
        let newValue = nameUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.name = newValue
        }
        if (newValue.characters.count < 4) {
                nameErrorUILabel.text = "Please fill Card holder name"
                nameErrorUILabel.isHidden = false
                return false
        } else {
            nameErrorUILabel.isHidden = true
            return true
        }
    }

    func validateEmail() -> Bool {
        
        let newValue = emailUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.email = newValue
        }
        if (!newValue.isValidEmail) {
            emailErrorUILabel.text = "Please fill a valid email address"
            emailErrorUILabel.isHidden = false
            return false
        } else {
            emailErrorUILabel.isHidden = true
            return true
        }
    }
    
    func validateAddress() -> Bool {
        
        let newValue = addressUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.address = newValue
        }
        if (newValue.characters.count < 3) {
            addressErrorUILabel.text = "Please fill a valid address"
            addressErrorUILabel.isHidden = false
            return false
        } else {
            addressErrorUILabel.isHidden = true
            return true
        }
    }
    
    func validateCity() -> Bool {
        
        let newValue = cityUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.city = newValue
        }
        if (newValue.characters.count < 3) {
            cityErrorUILabel.text = "Please fill a valid city"
            cityErrorUILabel.isHidden = false
            return false
        } else {
            cityErrorUILabel.isHidden = true
            return true
        }
    }
    
    func validateZip() -> Bool {
        
        let newValue = zipUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.zip = newValue
        }
        if (newValue.characters.count < 3) {
            zipErrorUILabel.text = "Please fill a valid zip code"
            zipErrorUILabel.isHidden = false
            return false
        } else {
            zipErrorUILabel.isHidden = true
            return true
        }
    }
    
    func validateCountry() -> Bool {
        
        let newValue = self.purchaseData.getShippingDetails()?.country ?? ""
        if (newValue.characters.count < 2) {
            countryErrorUILabel.text = "Please fill a valid country"
            countryErrorUILabel.isHidden = false
            return false
        } else {
            countryErrorUILabel.isHidden = true
            return true
        }
    }
    
    func validateState() -> Bool {
        
        let newValue = stateUITextField.text ?? ""
        if let shippingDetails = self.purchaseData.getShippingDetails() {
            shippingDetails.state = newValue
        }
        if (newValue.characters.count < 2) {
            stateErrorUILabel.text = "Please fill a valid state"
            stateErrorUILabel.isHidden = false
            return false
        } else {
            stateErrorUILabel.isHidden = true
            return true
        }
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
        _ = validateName()
    }
    
    @IBAction func emailEditingDidEnd(_ sender: UITextField) {
        _ = validateEmail()
    }
    
    @IBAction func addressEditingDidEnd(_ sender: UITextField) {
        _ = validateAddress()
    }
    
    @IBAction func cityEditingDidEnd(_ sender: UITextField) {
        _ = validateCity()
    }
    
    
    @IBAction func zipEditingDidEnd(_ sender: UITextField) {
        _ = validateZip()
    }
    
    
    @IBAction func countryEditingDidEnd(_ sender: UITextField) {
        _ = validateCountry()
    }
    
    
    @IBAction func stateEditingDidEnd(_ sender: UITextField) {
        _ = validateState()
    }
    
    // enter country field - open the country screen
    @IBAction func countryTouchDown(_ sender: Any) {
        
        let selectedCountryCode = purchaseData.getShippingDetails()?.country ?? ""
        BSViewsManager.showCurrencyList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            selectedCountryCode: selectedCountryCode,
            updateFunc: updateViewWithNewCountry)
    }

    // MARK: private functions
    
    private func updateViewWithNewCountry(countryCode : String, countryName : String) {
        
        if let shippingDetails = purchaseData.getShippingDetails() {
            shippingDetails.country = countryCode
        }
        self.countryUITextField.text = countryName
    }
}
