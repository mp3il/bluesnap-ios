//
//  BSViewsManager.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 23/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSViewsManager {
    
    // MARK: - Constants
    
    static let bundleIdentifier = "com.bluesnap.BluesnapSDK"
    static var bundle: Bundle!
    static let storyboardName = "BlueSnap"
    static let currencyScreenStoryboardId = "BSCurrenciesStoryboardId"
    static let startScreenStoryboardId = "BSStartScreenStoryboardId"
    static let purchaseScreenStoryboardId = "BSPaymentScreenStoryboardId" //"BSPurchaseScreenStoryboardId"
    static let countryScreenStoryboardId = "BSCountriesStoryboardId"
    static let stateScreenStoryboardId = "BSStatesStoryboardId"
    static let webScreenStoryboardId = "BSWebViewController"

    fileprivate static var startScreen: BSStartViewController!
    fileprivate static var purchaseScreen: BSPaymentViewController!//BSSummaryScreen!
    fileprivate static var currencyScreen: BSCurrenciesViewController!
    
    //static let transitionManager = BSTransitionManager()

    /**
     Open the check-out start screen, where the shopper chooses CC/ApplePay.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - paymentRequest: object that holds the shopper and payment details; shopper name and shipping details may be pre-filled
     - withShipping: if true, the shopper will be asked to supply shipping details
     - fullBilling: if true, we collect full billing address; otherwise only name and optionally zip code
     - purchaseFunc: callback; will be called when the shopper hits "Pay" and all the data is prepared
     */
    open static func showStartScreen(
        inNavigationController: UINavigationController!,
        animated: Bool,
        paymentRequest : BSPaymentRequest!,
        withShipping: Bool,
        fullBilling : Bool,
        purchaseFunc: @escaping (BSPaymentRequest!)->Void) {
        
        if startScreen == nil {
            let bundleforURL = Bundle(for: BSViewsManager.self)
            if let bundleurl = bundleforURL.url(forResource: "BluesnapUI", withExtension: "bundle") {
                bundle = Bundle(url: bundleurl)
                let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
                startScreen = (storyboard.instantiateViewController(withIdentifier: "BSNavToStart") as! UINavigationController).topViewController as! BSStartViewController;
            } else {
                bundle = Bundle(identifier: BSViewsManager.bundleIdentifier)!;
                let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
                startScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.startScreenStoryboardId) as! BSStartViewController
            }
        }
        
        startScreen.paymentRequest = paymentRequest
        startScreen.purchaseFunc = purchaseFunc
        startScreen.fullBilling = fullBilling
        startScreen.withShipping = withShipping
        
        if purchaseScreen != nil {
            purchaseScreen.resetCC()
        }
        
        //startScreen.transitioningDelegate = BSViewsManager.transitionManager

        inNavigationController.pushViewController(startScreen, animated: animated)
    }
    
    /**
     Open the check-out screen, where the shopper payment details are entered.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - paymentRequest: object that holds the shopper and payment details; shopper name and shipping details may be pre-filled
     - fullBilling: if true, we collect full billing address; otherwise only name and optionally zip code
     - purchaseFunc: callback; will be called when the shopper hits "Pay" and all the data is prepared
     */
    open class func showCCDetailsScreen(
        inNavigationController: UINavigationController!,
        animated: Bool,
        paymentRequest : BSPaymentRequest!,
        fullBilling : Bool,
        purchaseFunc: @escaping (BSPaymentRequest!)->Void) {
        
        if purchaseScreen == nil {
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: BSViewsManager.bundle);
            purchaseScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.purchaseScreenStoryboardId) as! BSPaymentViewController //BSSummaryScreen
        }
        
        purchaseScreen.paymentRequest = paymentRequest
        purchaseScreen.purchaseFunc = purchaseFunc
        purchaseScreen.fullBilling = fullBilling
       
        inNavigationController.pushViewController(purchaseScreen, animated: animated)
    }
    
    /**
     Navigate to the country list, allow changing current selection.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - countryManager: instance of BSCountryManager
     - selectedCountryCode: ISO country code
     - updateFunc: callback; will be called each time a new value is selected
     */
    open class func showCountryList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        countryManager : BSCountryManager,
        selectedCountryCode : String!,
        updateFunc: @escaping (String, String)->Void) {

        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle);
        let screen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.countryScreenStoryboardId) as! BSCountryViewController

        screen.initCountries(selectedCode: selectedCountryCode, countryManager: countryManager, updateFunc: updateFunc)
        
        inNavigationController.pushViewController(screen, animated: animated)
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
        errorFunc: @escaping ()->Void) {
        
        if currencyScreen == nil {
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
            currencyScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.currencyScreenStoryboardId) as! BSCurrenciesViewController
        }
        
        if currencyScreen.initCurrencies(currencyCode: selectedCurrencyCode, updateFunc: updateFunc) {
            inNavigationController.pushViewController(currencyScreen, animated: animated)
        } else {
            errorFunc()
        }
    }

    
    /**
     Navigate to the state list, allow changing current selection.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - countryManager: instance of BSCountryManager
     - selectedCountryCode: ISO country code
     - selectedStateCode: state code
     - updateFunc: callback; will be called each time a new value is selected
     */
    open class func showStateList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        countryManager : BSCountryManager,
        addressDetails: BSBaseAddressDetails,
        updateFunc: @escaping (String, String)->Void) {
        
        let selectedCountryCode = addressDetails.country ?? ""
        let selectedStateCode = addressDetails.state ?? ""
        
        if let states = countryManager.getCountryStates(countryCode: selectedCountryCode) {
            
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
            let screen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.stateScreenStoryboardId) as! BSStatesViewController
            
            screen.initStates(selectedCode: selectedStateCode, allStates: states, updateFunc: updateFunc)
            
            inNavigationController.pushViewController(screen, animated: animated)
        } else {
            NSLog("No state data available for \(selectedCountryCode)")
        }
    }
    
    open class func getImage(imageName: String!) -> UIImage? {
        
        var result : UIImage?
        if let myBundle = Bundle(identifier: bundleIdentifier) {
            if let image = UIImage(named: imageName, in: myBundle, compatibleWith: nil) {
                result = image
            }
        }
        return result
    }
    
    open class func createErrorAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(cancel)
        return alert
        //After you create alert, you show it like this: present(alert, animated: true, completion: nil)
    }
    
    open class func createActivityIndicator(view: UIView!) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        view.addSubview(indicator)
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .gray
        return indicator
    }
    
    open class func startActivityIndicator(activityIndicator: UIActivityIndicatorView!, blockEvents: Bool) {
        
        if blockEvents {
           UIApplication.shared.beginIgnoringInteractionEvents() 
        }
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                activityIndicator.startAnimating()
            }
        }
    }

    open class func stopActivityIndicator(activityIndicator: UIActivityIndicatorView!) {
        
        UIApplication.shared.endIgnoringInteractionEvents()
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
            }
        }
    }
        
    /*
     Create the popup menu for payment screen
    */
    open class func openPopupMenu(paymentRequest: BSPaymentRequest?,
            inNavigationController : UINavigationController,
            updateCurrencyFunc: @escaping (BSCurrency?, BSCurrency?)->Void,
            errorFunc: @escaping ()->Void) -> UIAlertController {
        
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let currencyMenuOption = UIAlertAction(title: "Currency", style: UIAlertActionStyle.default) { _ in
            if let paymentRequest = paymentRequest {
                BSViewsManager.showCurrencyList(
                    inNavigationController: inNavigationController,
                    animated: true,
                    selectedCurrencyCode: paymentRequest.getCurrency(),
                    updateFunc: updateCurrencyFunc,
                    errorFunc: errorFunc)
            }
        }
        
        let cancelMenuOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        // relate actions to controllers
        menu.addAction(currencyMenuOption)
        menu.addAction(cancelMenuOption)
        
        //presentViewController(otherAlert, animated: true, completion: nil)
        return menu
    }
    
    /**
     Navigate to the web browser screen, showing the given URL.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - url : URL for the browser
     */
    open class func showBrowserScreen(
        inNavigationController: UINavigationController!,
        url: String!) {
        
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
        let screen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.webScreenStoryboardId) as! BSWebViewController
        
        screen.url = url
        inNavigationController.pushViewController(screen, animated: true)
    }
}
