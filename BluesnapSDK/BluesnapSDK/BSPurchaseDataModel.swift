//
//  BSPurchaseDataModel.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 18/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

public class BSPaymentDetails : NSObject {
    
    // These 4 fields are input + output (they may change if shopper changes currency)
    var amount : Double! = 0.0
    var taxAmount : Double! = 0.0
    var taxPercent : Double! = 0.0
    var currency : String! = "USD"
    
    // These fields are output, but may be supplied as input as well
    var name : String! = ""
    var shippingDetails : BSShippingDetails?

    // Output only - result of submitting the CC details to BlueSnap server
    var ccDetails : BSResultCcDetails?
    
    
    // MARK: Change currency method
    
    /*
    Change currencvy will also change the amounts according to the change rates
    */
    public func changeCurrency(oldCurrency: BSCurrency?, newCurrency : BSCurrency?) {
        
        if let newCurrency = newCurrency {
        
            currency = newCurrency.code
        
            // calculate conversion rate
        
            var oldRate : Double = 1.0
            if let oldCurrency = oldCurrency {
                // keep rate to convert amount and tax back to USD
                oldRate = oldCurrency.getRate()
            }
            let newRate = newCurrency.getRate() / oldRate
        
            // update amounts
            amount = amount * newRate
            taxAmount = taxAmount * newRate
        }
    }
    
    
    // MARK: getters and setters
    
    public func getAmount() -> Double! {
        return amount
    }
    
    public func setAmount(amount : Double!) {
        self.amount = amount
    }
    
    public func getTaxAmount() -> Double! {
        return taxAmount
    }
    
    public func setTaxAmount(taxAmount : Double!) {
        self.taxAmount = taxAmount
    }
    
    public func getTaxPercent() -> Double! {
        return taxPercent
    }
    
    public func setTaxPercent(taxPercent : Double!) {
        self.taxPercent = taxPercent
    }
    
    public func getCurrency() -> String! {
        return currency
    }
    
    public func setCurrency(currency : String!) {
        self.currency = currency
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

