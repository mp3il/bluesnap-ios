//
//  BSSdkConfiguration.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 13/11/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//
import Foundation

class BSSdkConfiguration: NSObject {
    
    var kountMID: Int?
    var currencies: BSCurrencies?
    var shopper: BSShopper?
    
    var supportedPaymentMethods: [String]?
    // TODO: use this top prevent paypal error
    var paypalCurrencies: [String]?
    // TODO: use these to filter out unsupported CC brands
    var creditCardTypes: [String]?
    var creditCardBrands: [String]?
    // TODO: use these to replace the static Regexes in the validator
    var creditCardRegex: [String : String]?
}

class BSShopper : NSObject {
    
    // todo: put contact address in baseAddressDetails?
    var name: String?
    var email: String?
    var countryCode: String?
    var stateCode: String?
    var address: String?
    var city: String?
    var zip: String?
    var phone: String?
    
    var shippingDetails : BSShippingAddressDetails?
    // todo: change to paymentSources of type paymentInfo
    var existingCreditCards: [BSCreditCardInfo] = []
    // todo: add last payment info? type paymentInfo, base for creditCardInfo
}
