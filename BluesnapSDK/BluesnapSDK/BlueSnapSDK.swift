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
    
    static var purchaseData : PurchaseData?

	// MARK: - Show currencies' selection screen
	
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
	
	// MARK: - Show purchase screen
	
    /**
     Open the check-out screen, where the shopper payment details are entered.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - bsToken: BlueSnap token, should be fresh and valid
     - purchaseData: object that will hold the shopper and payment details; shopper name and shipping details may be pre-filled
     - withShipping: if true, the shopper will be asked to supply shipping details
     - purchaseFunc: callback; will be called when the shopper hits "Pay" and all the data isd prepared
     
    */
    open class func showPurchaseScreen(
        inNavigationController: UINavigationController!,
        animated: Bool,
        bsToken : BSToken!,
        purchaseData : PurchaseData!,
        withShipping: Bool,
        purchaseFunc: (PurchaseData!)->Void) {
		
		if purchaseScreen == nil {
			let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
			purchaseScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.purchaseScreenStoryboardId) as! BSSummaryScreen
        }
		
        if (withShipping && purchaseData.shippingDetails == nil) {
            purchaseData.setShippingDetails(shippingDetails: BSShippingDetails())
        } else if (!withShipping && purchaseData.shippingDetails != nil) {
            purchaseData.setShippingDetails(shippingDetails: nil)
        }
        purchaseScreen.purchaseData = purchaseData
        purchaseScreen.bsToken = bsToken
		
		inNavigationController.pushViewController(purchaseScreen, animated: animated)
	}
    
    /**
    Submit Payment token fields
    */
    
    
    
    
    // MARK: Utility functions
    
    /**
    Returns token for BlueSnap Sandbox environment; useful for tests.
    */
    open class func getSandboxTestToken() -> BSToken? {
        return BSApiManager.getSandboxBSToken()
    }
    
    /**
     Returns Currency Rates data.
     */
    open class func getCurrencyRates(bsToken : BSToken) -> BSCurrencies? {
        return BSApiManager.getCurrencyRates(bsToken: bsToken)
    }
}
