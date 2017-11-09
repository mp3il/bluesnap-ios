//
//  BSExistingCCViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 06/11/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSExistingCCViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var existingCcView: BSExistingCcUIView!
    @IBOutlet weak var billingLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var editBillingButton: UIButton!
    @IBOutlet weak var editShippingButton: UIButton!
    @IBOutlet weak var shippingBoxView: BSBaseBoxWithShadowView!
    @IBOutlet weak var billingNameLabel: UILabel!
    @IBOutlet weak var billingAddressTextView: UITextView!
    @IBOutlet weak var shippingNameLabel: UILabel!
    @IBOutlet weak var shippingAddressTextView: UITextView!
    @IBOutlet weak var payButton: UIButton!
    
    // MARK: private variables
    fileprivate var paymentRequest: BSExistingCcPaymentRequest!
    fileprivate var activityIndicator : UIActivityIndicatorView?
    
    // MARK: init
    
    public func initScreen(paymentRequest: BSExistingCcPaymentRequest!) {
        self.paymentRequest = paymentRequest
    }
    
    // MARK: - UIViewController's methods

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator = BSViewsManager.createActivityIndicator(view: self.view)
        self.title = BSLocalizedStrings.getString(BSLocalizedString.Title_Payment_Screen)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        existingCcView.setCc(ccType: paymentRequest.ccDetails.ccType ?? "", last4Digits: paymentRequest.ccDetails.last4Digits ?? "", expiration: paymentRequest.ccDetails.getExpiration())
        
        // update tax if needed
        if let shippingDetails = paymentRequest.getShippingDetails(), let updateTaxFunc = BlueSnapSDK.initialData?.updateTaxFunc {
            updateTaxFunc(shippingDetails.country!, shippingDetails.state, paymentRequest.priceDetails)
        }
        
        // load label translations
        billingLabel.text = BSLocalizedStrings.getString(BSLocalizedString.Label_Billing)
        shippingLabel.text = BSLocalizedStrings.getString(BSLocalizedString.Label_Shipping)
        let editButtonTitle = BSLocalizedStrings.getString(BSLocalizedString.Edit_Button_Title)
        editBillingButton.setTitle(editButtonTitle, for: UIControlState())
        editShippingButton.setTitle(editButtonTitle, for: UIControlState())
        let payButtonText = BSViewsManager.getPayButtonText(subtotalAmount: paymentRequest.getAmount() ?? 0.0, taxAmount: paymentRequest.getTaxAmount() ?? 0.0, toCurrency: paymentRequest.getCurrency() ?? "")
        payButton.setTitle(payButtonText, for: UIControlState())

        // for removing inner padding from text view
        let textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        
        let billingDetails = paymentRequest.billingDetails
        billingNameLabel.text = billingDetails?.name ?? ""
        billingAddressTextView.text = getDisplayAddress(addr: billingDetails)
        billingAddressTextView.isScrollEnabled = false
        billingAddressTextView.textContainerInset = textContainerInset
        
        shippingBoxView.isHidden = true
        shippingLabel.isHidden = true
        if let data = BlueSnapSDK.initialData {
            if data.withShipping {
                shippingBoxView.isHidden = false
                shippingLabel.isHidden = false
                shippingAddressTextView.isScrollEnabled = false
                shippingAddressTextView.textContainerInset = textContainerInset
                if let shippingDetails = paymentRequest.shippingDetails {
                    shippingNameLabel.text = shippingDetails.name
                    shippingAddressTextView.text = getDisplayAddress(addr: shippingDetails)
                } else {
                    shippingNameLabel.text = ""
                    shippingAddressTextView.text = ""
                }
            }
        }
    }

    // MARK: button actions

    @IBAction func clickPay(_ sender: Any) {
        
        if !validateBilling() {
            editBilling(sender)
        } else if !validateShipping() {
            editShipping(sender)
        } else {
            BSViewsManager.startActivityIndicator(activityIndicator: self.activityIndicator, blockEvents: true)
            submitPaymentFields()
        }
    }
    
    @IBAction func editBilling(_ sender: Any) {
        _ = BSViewsManager.showCCDetailsScreen(existingCcPaymentRequest: paymentRequest, inNavigationController: self.navigationController, animated: true)
    }
    
    @IBAction func editShipping(_ sender: Any) {
        BSViewsManager.showShippingScreen(
            paymentRequest: paymentRequest,
            submitPaymentFields: {_ in },
            validateOnEntry: false,
            inNavigationController: self.navigationController!,
            animated: true)
    }

    // MARK: private functions
    
    private func submitPaymentFields() {
        
        BSApiManager.submitPaymentRequest(paymentRequest: paymentRequest, completion: {
            ccDetails, error in
            
            if let error = error {
                if (error == .invalidCcNumber) {
                    self.showError(BSValidator.ccnInvalidMessage)
                } else if (error == .invalidExpDate) {
                    self.showError(BSValidator.expInvalidMessage)
                } else if (error == .invalidCvv) {
                    self.showError(BSValidator.cvvInvalidMessage)
                } else {
                    NSLog("Unexpected error submitting Payment Fields to BS; error: \(error)")
                    let message = BSLocalizedStrings.getString(BSLocalizedString.Error_General_CC_Submit_Error)
                    self.showError(message)
                }
            }
            DispatchQueue.main.async {
                // complete the purchase - go back to merchant screen and call the merchant purchaseFunc
                BSViewsManager.stopActivityIndicator(activityIndicator: self.activityIndicator)
                if error == nil {
                    if let navigationController = self.navigationController {
                        // return to merchant screen
                        let viewControllers = navigationController.viewControllers
                        let merchantControllerIndex = viewControllers.count - 3
                        _ = navigationController.popToViewController(viewControllers[merchantControllerIndex], animated: false)
                    }
                    // execute callback
                    BlueSnapSDK.initialData?.purchaseFunc(self.paymentRequest)
                }
            }
        })

    }
    
    private func getDisplayAddress(addr : BSBaseAddressDetails?) -> String {
        
        var result = ""
        if let addr = addr {
            if let address = addr.address {
                result = address + ", "
            }
            if let city = addr.city {
                result = result + city + " "
            }
            if let state = addr.state {
                result = result + state + " "
            }
            if let zip = addr.zip {
                result = result + zip + " "
            }
            if let country = addr.country {
                let countryName = BSCountryManager.getInstance().getCountryName(countryCode: country)
                result = result + (countryName ?? country)
            }
        }
        return result
    }
    
    private func showError(_ message: String) {
        // TODO
    }
    
    // MARK: Validation methods
    
    func validateBilling() -> Bool {
        
        var result = false
        if let data = BlueSnapSDK.initialData {
            
            // not validating CC, seeing as it is an existing one
            
            result = BSValidator.isValidName(paymentRequest.billingDetails.name)
            if data.withEmail {
                result = result && BSValidator.isValidEmail(paymentRequest.billingDetails.email ?? "")
            }
            result = result && BSValidator.isValidZip(countryCode: paymentRequest.billingDetails.country ?? "", zip: paymentRequest.billingDetails.zip ?? "")
            if data.fullBilling {
                let ok1 = BSValidator.isValidCity(paymentRequest.billingDetails.city ?? "")
                let ok2 = BSValidator.isValidStreet(paymentRequest.billingDetails.address ?? "")
                let ok3 = BSValidator.isValidCountry(countryCode: paymentRequest.billingDetails.country)
                let ok4 = BSValidator.isValidState(countryCode: paymentRequest.billingDetails.country ?? "", stateCode: paymentRequest.billingDetails.state)
                result = result && ok1 && ok2 && ok3 && ok4
            }
        }
        return result
    }

    func validateShipping() -> Bool {
        
        var result = true
        if let data = BlueSnapSDK.initialData {
            if data.withShipping {
                if let shippingDetails = paymentRequest.shippingDetails {
                    let ok1 = BSValidator.isValidName(shippingDetails.name)
                    let ok2 = BSValidator.isValidCity(shippingDetails.city ?? "")
                    let ok3 = BSValidator.isValidStreet(shippingDetails.address ?? "")
                    let ok4 = BSValidator.isValidCountry(countryCode: shippingDetails.country)
                    let ok5 = BSValidator.isValidState(countryCode: shippingDetails.country ?? "", stateCode: shippingDetails.state)
                    let ok6 = BSValidator.isValidZip(countryCode: shippingDetails.country ?? "", zip: shippingDetails.zip ?? "")
                    result =  ok1 && ok2 && ok3 && ok4 && ok5 && ok6
                }
            }
        }
        return result
    }
}
