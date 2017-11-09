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
    public var expirationMonth: String?
    public var expirationYear: String?
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSCcDetails()
        copy.ccType = ccType
        copy.last4Digits = last4Digits
        copy.ccIssuingCountry = ccIssuingCountry
        copy.expirationMonth = expirationMonth
        copy.expirationYear = expirationYear
        return copy
    }
    
    public func getExpiration() -> String {
        return (expirationMonth ?? "") + " / " + (expirationYear ?? "")
    }
    
    func getExpirationForSubmit() -> String {
        return (expirationMonth ?? "") + "/" + (expirationYear ?? "")
    }
}

@objc public class BSExistingCcDetails: BSCcDetails {
    
    var billingDetails: BSBillingAddressDetails?
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSExistingCcDetails()
        copy.billingDetails = billingDetails?.copy(with: zone) as? BSBillingAddressDetails
        copy.last4Digits = last4Digits
        copy.ccType = ccType
        copy.expirationMonth = expirationMonth
        copy.expirationYear = expirationYear
        return copy
    }
}

/**
 New CC details for the purchase
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
 Existing CC details for the purchase
 */
@objc public class BSExistingCcPaymentRequest : BSCcPaymentRequest, NSCopying {
        
    // for copy
    override private init(initialData: BSInitialData) {
         super.init(initialData: initialData)
    }
    
    init(initialData: BSInitialData, shopper: BSReturningShopperData!, existingCcDetails: BSExistingCcDetails!) {
        
        super.init(initialData: initialData)
        
        self.ccDetails = existingCcDetails.copy() as! BSExistingCcDetails
        self.ccDetails.ccType = existingCcDetails.ccType
        self.ccDetails.last4Digits = existingCcDetails.last4Digits
        
        if let ccBillingDetails = existingCcDetails.billingDetails {
            self.billingDetails = ccBillingDetails.copy() as! BSBillingAddressDetails
            if !initialData.withEmail {
                self.billingDetails.email = nil
            }
            if !initialData.fullBilling {
                self.billingDetails.address = nil
                self.billingDetails.city = nil
                self.billingDetails.state = nil
            }
        } else {
            if let initialBillingDetails = initialData.billingDetails {
                self.billingDetails = initialBillingDetails.copy() as! BSBillingAddressDetails
            } else {
                self.billingDetails = BSBillingAddressDetails()
            }
            if let name = shopper.name {
                billingDetails.name = name
            }
            if initialData.withEmail {
                if let email = shopper.email {
                    billingDetails.email = email
                }
            }
            if let country = shopper.countryCode {
                billingDetails.country =  country
                if initialData.fullBilling {
                    if let state = shopper.stateCode {
                        billingDetails.state = state
                    }
                    if let address = shopper.address {
                        billingDetails.address = address
                    }
                    if let city = shopper.city {
                        billingDetails.city = city
                    }
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
    
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSExistingCcPaymentRequest(initialData: BlueSnapSDK.initialData!)
        copy.ccDetails = self.ccDetails.copy() as! BSExistingCcDetails
        copy.ccDetails = self.ccDetails.copy() as! BSCcDetails
        copy.billingDetails = self.billingDetails.copy() as! BSBillingAddressDetails
        if let shippingDetails = self.shippingDetails {
            copy.shippingDetails = shippingDetails.copy() as? BSShippingAddressDetails
        }
        return copy
    }

}

