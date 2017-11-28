//
//  BSCcPayment.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 07/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

/**
 (PCI-compliant) Credit Card details: result of submitting the CC details to BlueSnap server
 */
@objc public class BSCreditCard : NSObject, NSCopying {
    
    public var ccType : String?
    public var last4Digits : String?
    public var ccIssuingCountry : String?
    public var expirationMonth: String?
    public var expirationYear: String?
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSCreditCard()
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

/**
 (PCI-compliant) Existing credit card info as we get it from BlueSnap API when getting the shopper information
 */
class BSCreditCardInfo: BSPaymentInfo, NSCopying {
    
    public var creditCard: BSCreditCard!
    public var billingDetails: BSBillingAddressDetails?
    
    private init() {
        super.init(paymentType: BSPaymentType.CreditCard)
    }
    
    public init(creditCard: BSCreditCard!, billingDetails: BSBillingAddressDetails?) {
        super.init(paymentType: BSPaymentType.CreditCard)
        self.creditCard = creditCard
        self.billingDetails = billingDetails
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSCreditCardInfo()
        copy.billingDetails = billingDetails?.copy(with: zone) as? BSBillingAddressDetails
        copy.creditCard = creditCard.copy(with: zone) as? BSCreditCard
        return copy
    }
}

/**
 New CC details for the purchase
 */
@objc public class BSCcSdkResult : BSBaseSdkResult {
    
    public var creditCard: BSCreditCard = BSCreditCard()
    public var billingDetails : BSBillingAddressDetails! = BSBillingAddressDetails()
    public var shippingDetails : BSShippingAddressDetails?

    public override init(sdkRequest: BSSdkRequest) {
        super.init(sdkRequest: sdkRequest)
        
        if let shopper = BSApiManager.shopper {
            self.billingDetails = BSBillingAddressDetails(email: shopper.email, name: shopper.name, address: shopper.address, city: shopper.city, zip: shopper.zip, country: shopper.countryCode, state: shopper.stateCode)
        } else if let billingDetails = sdkRequest.billingDetails {
            self.billingDetails = billingDetails.copy() as! BSBillingAddressDetails
        }
        if let shippingDetails = BSApiManager.shopper?.shippingDetails {
            self.shippingDetails = shippingDetails.copy() as? BSShippingAddressDetails
            self.shippingDetails?.phone = BSApiManager.shopper?.phone
        } else if let shippingDetails = sdkRequest.shippingDetails {
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
@objc public class BSExistingCcSdkResult : BSCcSdkResult, NSCopying {
        
    // for copy
    override private init(sdkRequest: BSSdkRequest) {
         super.init(sdkRequest: sdkRequest)
    }
    
    init(sdkRequest: BSSdkRequest, shopper: BSShopper!, existingCcDetails: BSCreditCardInfo!) {
        
        super.init(sdkRequest: sdkRequest)
        
        self.creditCard = existingCcDetails.creditCard.copy() as! BSCreditCard
        
        if let ccBillingDetails = existingCcDetails.billingDetails {
            self.billingDetails = ccBillingDetails.copy() as! BSBillingAddressDetails
            if !sdkRequest.withEmail {
                self.billingDetails.email = nil
            } else if self.billingDetails.email == nil {
                self.billingDetails.email = shopper.email
            }
            if !sdkRequest.fullBilling {
                self.billingDetails.address = nil
                self.billingDetails.city = nil
                self.billingDetails.state = nil
            }
        } else {
            if let initialBillingDetails = sdkRequest.billingDetails {
                self.billingDetails = initialBillingDetails.copy() as! BSBillingAddressDetails
            } else {
                self.billingDetails = BSBillingAddressDetails()
            }
            if let name = shopper.name {
                billingDetails.name = name
            }
            if sdkRequest.withEmail {
                if let email = shopper.email {
                    billingDetails.email = email
                }
            }
            if let country = shopper.countryCode {
                billingDetails.country =  country
                if sdkRequest.fullBilling {
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
        
        if sdkRequest.withShipping {
            if let shopperShippingDetails = shopper.shippingDetails {
                self.shippingDetails = shopperShippingDetails.copy() as? BSShippingAddressDetails
            } else if let initialShippingDetails = sdkRequest.shippingDetails {
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
        let copy = BSExistingCcSdkResult(sdkRequest: BlueSnapSDK.sdkRequest!)
        copy.creditCard = self.creditCard.copy() as! BSCreditCard
        copy.billingDetails = self.billingDetails.copy() as! BSBillingAddressDetails
        if let shippingDetails = self.shippingDetails {
            copy.shippingDetails = shippingDetails.copy() as? BSShippingAddressDetails
        }
        return copy
    }

}

