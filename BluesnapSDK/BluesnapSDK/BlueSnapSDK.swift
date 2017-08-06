//
//  BlueSnap.swift
//  BlueSnap
//
//

import Foundation
import PassKit

@objc open class BlueSnapSDK: NSObject {
	
    // MARK: Supported networks for ApplePay
    
    static let applePaySupportedNetworks: [PKPaymentNetwork] = [
        .amex,
        .discover,
        .masterCard,
        .visa
    ]

    // MARK: SDK functions
    
    /**
     Set the token used for BS API
     This needs to be done before calling any of the methods below, and also if you catch notification 
     for token expired
     
     - parameters:
     - bsToken: BlueSnap token, should be fresh and valid
    */
    open class func setBsToken(bsToken : BSToken!) {
        
        BSApiManager.setBsToken(bsToken: bsToken)
    }

    /**
     Start the check-out flow, where the shopper payment details are entered.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - paymentRequest: object that holds the shopper and payment details; shopper name and shipping details may be pre-filled
     - withShipping: if true, the shopper will be asked to supply shipping details
     - fullBilling: if true, we collect full billing address; otherwise only name and optionally zip code
     - purchaseFunc: callback; will be called when the shopper hits "Pay" and all the data is prepared
     */
    open class func showCheckoutScreen(
        inNavigationController: UINavigationController!,
        animated: Bool,
        paymentRequest : BSPaymentRequest!,
        withShipping: Bool,
        fullBilling : Bool,
        purchaseFunc: @escaping (BSPaymentRequest!)->Void) {
        
        adjustPaymentRequest(paymentRequest: paymentRequest,
                             withShipping: withShipping)
        
        BSViewsManager.showStartScreen(inNavigationController: inNavigationController,
                                          animated: animated,
                                          paymentRequest: paymentRequest,
                                          withShipping: withShipping,
                                          fullBilling: fullBilling,
                                          purchaseFunc: purchaseFunc)
    }
    
    /**
     Submit Payment token fields
     If you do not want to use our check-out page, you can implement your own.
     You need to generate a token, and then call this function to submit the CC details to BlueSnap instead of returning them to your server (which is less secure) and then passing them to BlueSnap when you create the transaction.
     - parameters:
     - ccNumber: Credit card number
     - expDate: CC expiration date in format MM/YYYY
     - cvv: CC security code (CVV)
     - completion: callback with either result details if OK, or error details if not OK
     */
    open class func submitCcDetails(ccNumber: String, expDate: String, cvv: String, completion : @escaping (BSResultCcDetails?,BSErrors?)->Void) {
        
        BSApiManager.submitCcDetails(ccNumber: ccNumber, expDate: expDate, cvv: cvv, completion: completion)
    }
    
    /**
     Return a list of currencies and their rates from BlueSnap server
     - parameters:
     - throws BSErrors
     */
    open class func getCurrencyRates() -> BSCurrencies? {
        let result = BSApiManager.getCurrencyRates()
        return result
    }

    /**
     Navigate to the currency list, allow changing current selection.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - selectedCurrencyCode: 3 characters of the current language code (uppercase)
     - updateFunc: callback; will be called each time a new value is selected
     - errorFunc: callback; will be called if we fail to get the currencies
     */
    open class func showCurrencyList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        selectedCurrencyCode : String!,
        updateFunc: @escaping (BSCurrency?, BSCurrency?)->Void,
        errorFunc: @escaping()->Void) {
        
        BSViewsManager.showCurrencyList(inNavigationController: inNavigationController, animated: animated, selectedCurrencyCode: selectedCurrencyCode, updateFunc: updateFunc, errorFunc: errorFunc)
    }
    
    /**
     Call Kount SDK to initialize device data collection
     - parameters:
     - kountMid: if you have your own Kount MID, send it here; otherwise leave empty
     - fraudSessionID: this unique ID per shopper should be sent later to BlueSnap when creating the transaction
    */
    open class func KountInit(kountMid: Int?, fraudSessionID : String!) {
        //// Configure the Data Collector
        //
        //KDataCollector.shared().debug = true
        // TODO Set your Merchant ID
        //KDataCollector.shared().merchantID = kountMid ?? 700000
        // TODO Set the location collection configuration
        //KDataCollector.shared().locationCollectorConfig = KLocationCollectorConfig.requestPermission
        // For a released app, you'll want to set this to KEnvironment.Production
        //KDataCollector.shared().environment = KEnvironment.test
    }
    
    /**
    Check if ApplePay is available
    */
    open class func applePaySupported(supportedNetworks: [PKPaymentNetwork]) -> (canMakePayments: Bool, canSetupCards: Bool) {
        
        if BSApiManager.isSupportedPaymentMethod(BSPaymentType.ApplePay) {
            if #available(iOS 10, *) {
                return (PKPaymentAuthorizationController.canMakePayments(),
                        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks));
            }
        }
        return (canMakePayments: false, canSetupCards: false)
    }

    
    // MARK: Utility functions for quick testing
    
    /**
     Returns token for BlueSnap Sandbox environment; useful for tests.
     In your real app, the token should be generated on the server side and passed to the app, so that the app will not expose the username/password
    */
    open class func createSandboxTestToken() throws -> BSToken? {
        do {
            return try BSApiManager.createSandboxBSToken()
        } catch let error {
            throw error
        }
    }

    /**
    Objective C helper method for returning sandbox token
    */
    @objc open class func createSandboxTestTokenOrNil() -> BSToken? {
        do {
            return try BSApiManager.createSandboxBSToken()!
        } catch let error {
            NSLog("Error creating token")
            return nil
        }
    }


    open class func setApplePayMerchantIdentifier(merchantId: String!) -> String? {
        BSApplePayConfiguration.setIdentifier(merchantId: merchantId)
        return "OK"
    }
    
    // MARK: Private functions
    
    private class func adjustPaymentRequest(paymentRequest: BSPaymentRequest!,
                                            withShipping: Bool) {
        
        let defaultCountry = NSLocale.current.regionCode ?? "US"
        if (withShipping && paymentRequest.shippingDetails == nil) {
            paymentRequest.setShippingDetails(shippingDetails: BSShippingAddressDetails())
            paymentRequest.getShippingDetails()!.country = defaultCountry
        } else if (!withShipping && paymentRequest.shippingDetails != nil) {
            paymentRequest.setShippingDetails(shippingDetails: nil)
        }
        if paymentRequest.getBillingDetails().country ?? "" == "" {
            paymentRequest.getBillingDetails().country = defaultCountry
        }

    }
    
}

public class BSApplePayConfiguration {

    internal static var identifier: String? = nil

    public static func setIdentifier(merchantId: String!) {
        identifier = merchantId;
    }

    public static func getIdentifier() -> String! {
        return identifier
    }

}

let InternalQueue = OperationQueue();
