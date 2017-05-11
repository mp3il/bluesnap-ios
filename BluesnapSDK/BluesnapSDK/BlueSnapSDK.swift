//
//  BlueSnap.swift
//  BlueSnap
//
//

import Foundation

@objc open class BlueSnapSDK: NSObject {
	
	
	// MARK: - UI Controllers
	
	fileprivate static var currencyScreen: BSCurrenciesViewController!
	fileprivate static var purchaseScreen: BSSummaryScreen!
    
    // MARK: data
    
    static var paymentDetails : BSPaymentDetails?

    // MARK: - Show checkout screen
    
    /**
     Open the check-out screen, where the shopper payment details are entered.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - bsToken: BlueSnap token, should be fresh and valid
     - paymentDetails: object that holds the shopper and payment details; shopper name and shipping details may be pre-filled
     - withShipping: if true, the shopper will be asked to supply shipping details
     - fullBilling: if true, we collect full billing address; otherwise only name and optionally zip code
     - purchaseFunc: callback; will be called when the shopper hits "Pay" and all the data is prepared
     */
    open class func showCheckoutScreen(
        inNavigationController: UINavigationController!,
        animated: Bool,
        bsToken : BSToken!,
        paymentDetails : BSPaymentDetails!,
        withShipping: Bool,
        fullBilling : Bool,
        purchaseFunc: @escaping (BSPaymentDetails!)->Void) {
        
        if purchaseScreen == nil {
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
            purchaseScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.purchaseScreenStoryboardId) as! BSSummaryScreen
        }
        
        let defaultCountry = NSLocale.current.regionCode ?? "US"
        if (withShipping && paymentDetails.shippingDetails == nil) {
            paymentDetails.setShippingDetails(shippingDetails: BSAddressDetails())
            paymentDetails.getShippingDetails()!.country = defaultCountry
        } else if (!withShipping && paymentDetails.shippingDetails != nil) {
            paymentDetails.setShippingDetails(shippingDetails: nil)
        }
        if (fullBilling == true) && (paymentDetails.getBillingDetails().country ?? "" == "") {
            paymentDetails.getBillingDetails().country = defaultCountry
        }
        purchaseScreen.paymentDetails = paymentDetails
        purchaseScreen.bsToken = bsToken
        purchaseScreen.purchaseFunc = purchaseFunc
        purchaseScreen.fullBilling = fullBilling
        
        inNavigationController.pushViewController(purchaseScreen, animated: animated)
    }
    
    // MARK: - Submit Payment token fields

    /**
     Submit Payment token fields
     If you do not wanrt to use our check-out page, you can implement your own.
     You need to generate a token, and then call this function to submit the CC details to BlueSnap instead of returning them to your server (which is less secure) and then passing them to BlueSnap when you create the transaction.
     */
    static func submitCcDetails(bsToken : BSToken!, ccNumber: String, expDate: String, cvv: String) throws -> BSResultCcDetails? {
        
        do {
            let result = try BSApiManager.submitCcDetails(bsToken: bsToken, ccNumber: ccNumber, expDate: expDate, cvv: cvv)
            return result
        } catch let error {
            throw error
        }
    }

    
    // MARK: - Currency functions
    
    /**
     Returns Currency Rates data.
     */
    open class func getCurrencyRates(bsToken : BSToken) -> BSCurrencies? {
        return BSApiManager.getCurrencyRates(bsToken: bsToken)
    }

    /**
     Navigate to the currency list, allow changing current selection.
     
     - parameters:
        - inNavigationController: your viewController's navigationController (to be able to navigate back)
        - animated: how to navigate to the new screen
        - bsToken: BlueSnap token, should be fresh and valid
        - selectedCurrencyCode: 3 characters of the curtrent language code (uppercase)
        - updateFunc: callback; will be called each time a new value is selected
     */
    open class func showCurrencyList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        bsToken: BSToken!,
        selectedCurrencyCode : String!,
        updateFunc: @escaping (BSCurrency?, BSCurrency?)->Void) {

		if currencyScreen == nil {
			let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
			currencyScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.currencyScreenStoryboardId) as! BSCurrenciesViewController
		}
		
        currencyScreen.bsToken = bsToken
        currencyScreen.selectedCurrencyCode = selectedCurrencyCode
        currencyScreen.updateFunc = updateFunc

        inNavigationController.pushViewController(currencyScreen, animated: animated)
	}
	
    // MARK: init Kount for device data collection
    
    /**
     Call Kount SDK to initialize devicde data collection
     - parameters:
     - kountMid: if you have your own Kount MID, send it here; otherwise leave empty
     - fraudSessionID: this unique ID per shopper should be sent later to BlueSnap when creating the transaction
    */
    open class func KountInit(kountMid: Int?, fraudSessionID : String!) {
        //// Configure the Data Collector
        //
        KDataCollector.shared().debug = true
        // TODO Set your Merchant ID
        KDataCollector.shared().merchantID = kountMid ?? 700000
        // TODO Set the location collection configuration
        KDataCollector.shared().locationCollectorConfig = KLocationCollectorConfig.requestPermission
        // For a released app, you'll want to set this to KEnvironment.Production
        KDataCollector.shared().environment = KEnvironment.test
    }
    
    
    // MARK: Utility functions for quick testing
    
    /**
     Returns token for BlueSnap Sandbox environment; useful for tests.
     In your real app, the token should be generated on the server side and passed to the app, so that the app will not expose the username/password
    */
    open class func getSandboxTestToken() -> BSToken? {
        return BSApiManager.getSandboxBSToken()
    }
    
}
