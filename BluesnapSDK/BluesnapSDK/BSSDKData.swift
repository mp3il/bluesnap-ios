//
//  BSSDKData.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 19/10/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSSdkData: NSObject {
    
    var kountMID: Int?
    var currencyRates: BSCurrencies?
    var returningShopper: BSReturningShopperData?
    var supportedPaymentMethods: [String]?
    // TODO: use this top prevent paypal error
    var paypalCurrencies: [String]?
    // TODO: use these to filter out unsupported CC brands
    var creditCardTypes: [String]?
    var creditCardBrands: [String]?
    // TODO: use these to replace the static Regexes in the validator
    var creditCardRegex: [String : String]?
}

@objc public class BSExistingCcDetails: NSObject, NSCopying {
    
    var billingDetails: BSBillingAddressDetails?
    var last4Digits: String?
    var cardType: String?
    var expirationMonth: String?
    var expirationYear: String?
    
    func getExpiration() -> String {
        return (expirationMonth ?? "") + " / " + (expirationYear ?? "")
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSExistingCcDetails()
        copy.billingDetails = billingDetails?.copy(with: zone) as? BSBillingAddressDetails
        copy.last4Digits = last4Digits
        copy.cardType = cardType
        copy.expirationMonth = expirationMonth
        copy.expirationYear = expirationYear
        return copy
    }
}

class BSReturningShopperData: NSObject {
    
    var name: String?
    var email: String?
    var countryCode: String?
    var stateCode: String?
    var address: String?
    var city: String?
    var zip: String?
    var phone: String?
    
    var shippingDetails : BSShippingAddressDetails?
    var existingCreditCards: [BSExistingCcDetails] = []
}
