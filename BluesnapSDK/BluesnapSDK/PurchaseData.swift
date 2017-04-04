//
//  PurchaseData.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 04/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class PurchaseData : NSObject {
    
    var amount : Double = 0.0
    var taxAmount : Double = 0.0
    var currency : String = "USD"
    var name : String = ""
    var ccn : String = ""
    var exp : String = ""
    var cvv : String = ""
    var shippingDetails : BSShippingDetails?
    
    func getAmount() -> Double {
        return amount
    }
    
    func setAmount(amount : Double) {
        self.amount = amount
    }
    
    func getTaxAmount() -> Double {
        return taxAmount
    }
    
    func setTaxAmount(taxAmount : Double) {
        self.taxAmount = taxAmount
    }
    
    func getCurrency() -> String {
        return currency
    }
    
    func setCurrency(currency : String) {
        self.currency = currency
    }

    func getName() -> String {
        return name
    }

    func setName(name : String) {
        self.name = name
    }
    
    func getCCN() -> String {
        return ccn
    }
    
    func setCCN(ccn : String) {
        self.ccn = ccn
    }
    
    func getExp() -> String {
        return exp
    }
    
    func setExp(exp : String) {
        self.exp = exp
    }
    
    func getCVV() -> String {
        return cvv
    }
    
    func setCVV(cvv : String) {
        self.cvv = cvv
    }
    
    func getShippingDetails() -> BSShippingDetails? {
        return shippingDetails
    }
    
    func setShippingDetails(shippingDetails : BSShippingDetails?) {
        self.shippingDetails = shippingDetails
    }
    
}
