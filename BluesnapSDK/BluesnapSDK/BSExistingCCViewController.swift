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
    
    // MARK: private variables
    fileprivate var paymentRequest: BSExistingCcPaymentRequest!
    
    // MARK: init
    
    public func initScreen(paymentRequest: BSExistingCcPaymentRequest!) {
        self.paymentRequest = paymentRequest
    }
    
    // MARK: - UIViewController's methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        existingCcView.setCc(ccType: paymentRequest.existingCcDetails.cardType ?? "", last4Digits: paymentRequest.existingCcDetails.last4Digits ?? "", expiration: paymentRequest.existingCcDetails.getExpiration())
        
        // TODO: load label translations
        // billingLabel.text =
        // shippingLabel.text =
        // editBillingButton.setTitle("", for: UIControlState())
        // editShippingButton("", for: UIControlState())
        
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
    }
    @IBAction func editBilling(_ sender: Any) {
    }
    @IBAction func editShipping(_ sender: Any) {
    }

    // MARK: provate functions
    
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

}
