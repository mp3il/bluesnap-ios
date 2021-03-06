//
//  BSPurchaseDataModel.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 18/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

/**
 Available payment types
 */
public enum BSPaymentType : String {
    case CreditCard = "CC"
    case ApplePay = "APPLE_PAY"
    case PayPal = "PAYPAL"
}

/**
 Base class for the different payments; for now only BSCreditCardInfo inherits from this.
 */
  public class BSPaymentInfo: NSObject {
    let paymentType : BSPaymentType!
    public init(paymentType: BSPaymentType!) {
        self.paymentType = paymentType
    }
}

/**
 Base class for payment request; this will be the result of the payment flow (one of the inherited classes: BSCcSdkResult/BSApplePaySdkResult/BSPayPalSdkResult)
 */
  public class BSBaseSdkResult : NSObject {
    
    var fraudSessionId: String?
    var priceDetails: BSPriceDetails!
    
    internal init(sdkRequest: BSSdkRequest) {
        super.init()
        self.priceDetails = sdkRequest.priceDetails.copy() as? BSPriceDetails
        self.fraudSessionId = BlueSnapSDK.fraudSessionId
    }
    
    public func getFraudSessionId() -> String? {
        return fraudSessionId;
    }
        
    // MARK: getters and setters
    
    public func getAmount() -> Double! {
        return priceDetails.amount.doubleValue
    }
    
    public func getTaxAmount() -> Double! {
        return priceDetails.taxAmount.doubleValue
    }
    
    public func getCurrency() -> String! {
        return priceDetails.currency
    }
}


/**
 price details: amount, tax and currency
 */
  public class BSPriceDetails : NSObject, NSCopying {

    public var amount: NSNumber! = 0.0
    public var taxAmount: NSNumber! = 0.0
    public var currency : String! = "USD"

      public func setDetailsWithAmount(amount: NSNumber!, taxAmount: NSNumber!, currency: NSString?/*, baseCurrency: NSString?*/) {
        self.amount = amount
        self.taxAmount = taxAmount
        self.currency = currency! as String
    }

    public init(amount: Double!, taxAmount: Double!, currency: String?) {
        super.init()
        self.amount = NSNumber.init(value: amount)
        self.taxAmount = NSNumber.init(value: taxAmount)
        self.currency = currency ?? "USD"
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSPriceDetails(amount: amount.doubleValue, taxAmount: taxAmount.doubleValue, currency: currency)
        return copy
    }
    
    public func changeCurrencyAndConvertAmounts(newCurrency: BSCurrency!) {
        
        if let currencies = BSApiManager.bsCurrencies {
            let originalRate = currencies.getCurrencyByCode(code: self.currency)?.getRate() ?? 1.0
            self.currency = newCurrency.code
            let newRate = newCurrency.getRate() / originalRate
            self.amount = NSNumber.init(value: self.amount.doubleValue * newRate)
            self.taxAmount = NSNumber.init(value: self.taxAmount.doubleValue * newRate)
        } else {
            fatalError("Unable to access currency rates")
        }
    }
}


/**
  Class holds initial or setup data for the flow:
    - Flow flavors (withShipping, withBilling, withEmail)
    - Price details
    - (optional) Shopper details
    - (optional) function for updating tax amount based on shipping country/state. Only called when 'withShipping
 */
  public class BSSdkRequest : NSObject {

    public var withEmail: Bool = true
    public var withShipping: Bool = false
    public var fullBilling: Bool = false
    public var priceDetails: BSPriceDetails! = BSPriceDetails(amount: 0, taxAmount: 0, currency: nil)
    
    public var billingDetails: BSBillingAddressDetails?
    public var shippingDetails: BSShippingAddressDetails?

    public var purchaseFunc: (BSBaseSdkResult?) -> Void
    public var updateTaxFunc: ((_ shippingCountry: String, _ shippingState: String?, _ priceDetails: BSPriceDetails) -> Void)?
    
    public init(
        withEmail: Bool,
        withShipping: Bool,
        fullBilling: Bool,
        priceDetails: BSPriceDetails!,
        billingDetails: BSBillingAddressDetails?,
        shippingDetails: BSShippingAddressDetails?,
        purchaseFunc: @escaping (BSBaseSdkResult?) -> Void,
        updateTaxFunc: ((_ shippingCountry: String, _ shippingState: String?, _ priceDetails: BSPriceDetails) -> Void)?) {
        
        self.withEmail = withEmail
        self.withShipping = withShipping
        self.fullBilling = fullBilling
        self.priceDetails = priceDetails
        self.billingDetails = billingDetails
        self.shippingDetails = shippingDetails
        self.purchaseFunc = purchaseFunc
        self.updateTaxFunc = updateTaxFunc
    }
}
