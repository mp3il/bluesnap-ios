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

/**
 CC details for the purchase
 */
@objc public class BSExistingCcPaymentRequest : BSCcPaymentRequest {
    
    public var existingCcDetails: BSExistingCcDetails = BSExistingCcDetails()
    
    init(initialData: BSInitialData, shopper: BSReturningShopperData!, existingCcDetails: BSExistingCcDetails!) {
        
        super.init(initialData: initialData)
        
        self.existingCcDetails = existingCcDetails.copy() as! BSExistingCcDetails
        self.ccDetails.ccType = existingCcDetails.cardType
        self.ccDetails.last4Digits = existingCcDetails.last4Digits
        
        if let ccBillingDetails = existingCcDetails.billingDetails {
            self.billingDetails = ccBillingDetails.copy() as! BSBillingAddressDetails
        } else {
            if let initialBillingDetails = initialData.billingDetails {
                self.billingDetails = initialBillingDetails.copy() as! BSBillingAddressDetails
            } else {
                self.billingDetails = BSBillingAddressDetails()
            }
            if let name = shopper.name {
                billingDetails.name = name
            }
            if let email = shopper.email {
                billingDetails.email = email
            }
            if let country = shopper.countryCode {
                billingDetails.country =  country
                if let state = shopper.stateCode {
                    billingDetails.state = state
                }
                if let address = shopper.address {
                    billingDetails.address = address
                }
                if let city = shopper.city {
                    billingDetails.city = city
                }
                if let zip = shopper.zip {
                    billingDetails.zip = zip
                }
            }
        }
        
        if initialData.withShipping {
            if let shopperShippingDetails = shopper.shippingDetails {
                self.shippingDetails = shopperShippingDetails.copy() as? BSShippingAddressDetails
            } else if let initialShippingDetails = initialData.shippingDetails {
                self.shippingDetails = initialShippingDetails.copy() as? BSShippingAddressDetails
            }
            if self.shippingDetails?.name == nil || self.shippingDetails?.name == "" {
                // copy from billing
                self.shippingDetails!.name = billingDetails.name
                self.shippingDetails!.country = billingDetails.country
                self.shippingDetails!.state = billingDetails.state
                self.shippingDetails!.zip = billingDetails.zip
                self.shippingDetails!.city = billingDetails.city
                self.shippingDetails!.address = billingDetails.address
                self.shippingDetails!.name = billingDetails.name
            }
            if let phone = shopper.phone {
                self.shippingDetails?.phone = phone
            }
        }
    }
}

