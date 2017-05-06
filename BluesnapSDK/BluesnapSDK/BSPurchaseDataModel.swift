//
//  BSPurchaseDataModel.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 18/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

public class BSPaymentDetails : NSObject {
    
    // These 3 fields are input + output (they may change if shopper changes currency)
    var amount : Double! = 0.0
    var taxAmount : Double! = 0.0
    var currency : String! = "USD"
    
    // These fields hold the original amounts in USD, to keep precision in case of currency change
    internal var originalAmount : Double! = 0.0
    internal var originalTaxAmount : Double! = 0.0
    internal var originalRate : Double?
    
    // These fields are output, but may be supplied as input as well
    var name : String! = ""
    var shippingDetails : BSShippingDetails?

    // Output only - result of submitting the CC details to BlueSnap server
    var ccDetails : BSResultCcDetails?
    
    
    // MARK: Change currency methods
    
    /*
    Set amounts will reset the currency and amounts, including the original
    amounts.
    */
    public func setAmountsAndCurrency(amount: Double!, taxAmount: Double?, currency: String) {
        
        self.amount = amount
        self.originalAmount = amount
        self.taxAmount = taxAmount
        self.originalTaxAmount = taxAmount ?? 0.0
        self.currency = currency
        self.originalRate = nil
    }
    
    /*
    Change currencvy will also change the amounts according to the change rates
    */
    public func changeCurrency(oldCurrency: BSCurrency?, newCurrency : BSCurrency?) {
        
        if originalRate == nil {
            if let oldCurrency = oldCurrency {
                originalRate = oldCurrency.getRate() ?? 1.0
            } else {
                originalRate = 1.0
            }
        }
        if let newCurrency = newCurrency {
            self.currency = newCurrency.code
            let newRate = newCurrency.getRate() / originalRate!
            self.amount = originalAmount * newRate
            self.taxAmount = originalTaxAmount * newRate
        }
    }
    
    
    // MARK: getters and setters
    
    public func getAmount() -> Double! {
        return amount
    }
    
    public func getTaxAmount() -> Double! {
        return taxAmount
    }
    
    public func getCurrency() -> String! {
        return currency
    }
    
    public func getName() -> String! {
        return name
    }
    
    public func setName(name : String!) {
        self.name = name
    }
    
    public func getSplitName() -> (firstName: String, lastName: String)? {
        return name.splitName
    }

    
    public func getCcDetails() -> BSResultCcDetails? {
        return ccDetails
    }
    
    public func setCcDetails(ccDetails : BSResultCcDetails?) {
        self.ccDetails = ccDetails
    }
    
    public func getShippingDetails() -> BSShippingDetails? {
        return shippingDetails
    }
    
    public func setShippingDetails(shippingDetails : BSShippingDetails?) {
        self.shippingDetails = shippingDetails
    }
}

/**
    Shopper shipping details for purchase
 */
public class BSShippingDetails {
    
    var name : String = ""
    var email : String = ""
    var address : String = ""
    var city : String = ""
    var zip : String = ""
    var country : String = ""
    var state : String = ""
}

/**
 Output non-secured CC details for the purchase
*/
public class BSResultCcDetails {
    
    // these fields are output - result of submitting the CC details to BlueSnap server
    var ccType : String?
    var last4Digits : String?
    var ccIssuingCountry : String?
}

