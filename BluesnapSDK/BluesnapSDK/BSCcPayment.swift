//
//  BSCcPayment.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 07/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

/**
 (PCI-compliant) CC details: result of submitting the CC details to BlueSnap server
 */
@objc public class BSCcDetails : NSObject, NSCopying {
    
    // these fields are output - result of submitting the CC details to BlueSnap server
    public var ccType : String?
    public var last4Digits : String?
    public var ccIssuingCountry : String?
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSCcDetails()
        copy.ccType = ccType
        copy.last4Digits = last4Digits
        copy.ccIssuingCountry = ccIssuingCountry
        return copy
    }
}

/**
 CC details for the purchase
 */
@objc public class BSCcPaymentRequest : BSBasePaymentRequest/*, NSCopying*/ {
    
    public var ccDetails: BSCcDetails = BSCcDetails()
    public var billingDetails : BSBillingAddressDetails! = BSBillingAddressDetails()
    public var shippingDetails : BSShippingAddressDetails?
    
    public override init(initialData: BSInitialData) {
        super.init(initialData: initialData)
        self.paymentType = .ApplePay
        if let billingDetails = initialData.billingDetails {
            self.billingDetails = billingDetails.copy() as! BSBillingAddressDetails
        }
        if let shippingDetails = initialData.shippingDetails {
            self.shippingDetails = shippingDetails.copy() as? BSShippingAddressDetails
        }
    }
    
    public func getBillingDetails() -> BSBillingAddressDetails! {
        return billingDetails
    }
    
    public func getShippingDetails() -> BSShippingAddressDetails? {
        return shippingDetails
    }
    
    public func setShippingDetails(shippingDetails : BSShippingAddressDetails?) {
        self.shippingDetails = shippingDetails
    }
}

