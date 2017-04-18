//
//  BSPurchaseDataModel.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 18/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

public class PurchaseData : NSObject {
    
    var amount : Double = 0.0
    var taxAmount : Double = 0.0
    var currency : String = "USD"
    var name : String = ""
    var ccn : String = ""
    var exp : String = ""
    var cvv : String = ""
    var shippingDetails : BSShippingDetails?
    
    public func changeCurrency(oldCurrency: BSCurrency?, newCurrency : BSCurrency?, bsCurrencies: BSCurrencies?) {
        
        if (newCurrency == nil || bsCurrencies == nil) {
            return
        }
        
        currency = newCurrency!.code
        
        // calculate conversion rate
        
        var oldRate : Double = 1.0
        if (oldCurrency != nil) {
            // keep rate to convert amount and tax back to USD
            oldRate = oldCurrency!.getRate()
        }
        let newRate = newCurrency!.getRate() / oldRate
        
        // update amounts
        amount = amount * newRate
        taxAmount = taxAmount * newRate
    }
    
    public func getAmount() -> Double {
        return amount
    }
    
    public func setAmount(amount : Double) {
        self.amount = amount
    }
    
    public func getTaxAmount() -> Double {
        return taxAmount
    }
    
    public func setTaxAmount(taxAmount : Double) {
        self.taxAmount = taxAmount
    }
    
    public func getCurrency() -> String {
        return currency
    }
    
    public func setCurrency(currency : String) {
        self.currency = currency
    }
    
    public func getName() -> String {
        return name
    }
    
    public func setName(name : String) {
        self.name = name
    }
    
    public func getCCN() -> String {
        return ccn
    }
    
    public func setCCN(ccn : String) {
        self.ccn = ccn
    }
    
    public func getExp() -> String {
        return exp
    }
    
    public func setExp(exp : String) {
        self.exp = exp
    }
    
    public func getCVV() -> String {
        return cvv
    }
    
    public func setCVV(cvv : String) {
        self.cvv = cvv
    }
    
    public func getShippingDetails() -> BSShippingDetails? {
        return shippingDetails
    }
    
    public func setShippingDetails(shippingDetails : BSShippingDetails?) {
        self.shippingDetails = shippingDetails
    }
}

public class BSShippingDetails {
    
    var name : String = ""
    var email : String = ""
    var address : String = ""
    var city : String = ""
    var zip : String = ""
    var country : String = ""
    var state : String = ""
    
}
