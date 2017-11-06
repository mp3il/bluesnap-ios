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
    static let storyboardName = "BlueSnap"
    static let currencyScreenStoryboardId = "BSCurrenciesStoryboardId"
    static let startScreenStoryboardId = "BSStartScreenStoryboardId"
    static let purchaseScreenStoryboardId = "BSPaymentScreenStoryboardId"
    static let existingCcScreenStoryboardId = "BSExistingCcScreenStoryboardId"
    static let countryScreenStoryboardId = "BSCountriesStoryboardId"
    static let stateScreenStoryboardId = "BSStatesStoryboardId"
    static let webScreenStoryboardId = "BSWebViewController"

    fileprivate static var startScreen: BSStartViewController!
    fileprivate static var purchaseScreen: BSPaymentViewController!//BSSummaryScreen!
    fileprivate static var currencyScreen: BSCurrenciesViewController!
    fileprivate static var bsBundle: Bundle = createBundle()

    /**
     Create the bundle containing BlueSnap assets
     */
    private static func createBundle() -> Bundle {

        let bundleforURL = Bundle(for: BSViewsManager.self)
        if let bundleurl = bundleforURL.url(forResource: "BluesnapUI", withExtension: "bundle") {
            return Bundle(url: bundleurl)!
        } else {
            return Bundle(identifier: BSViewsManager.bundleIdentifier)!;
        }
    }

    /**
     Get the bundle containing BlueSnap assets
     */
    open static func getBundle() -> Bundle {

        return bsBundle
    }

    /**
     Open the check-out start screen, where the shopper chooses CC/ApplePay.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - paymentRequest: object that holds the shopper and payment details; shopper name and shipping details may be pre-filled
     - withShipping: if true, the shopper will be asked to supply shipping details
     - fullBilling: if true, we collect full billing address; otherwise only name and optionally zip code
     */
    open static func showStartScreen(
        inNavigationController: UINavigationController!,
        animated: Bool) {
        
        if startScreen == nil {
            let bundle = BSViewsManager.getBundle()
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
            startScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.startScreenStoryboardId) as! BSStartViewController
        }

        startScreen.initScreen()

        inNavigationController.pushViewController(startScreen, animated: animated)
    }
    
    /**
     Open the check-out screen, where the shopper payment details are entered.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     */
    open class func showCCDetailsScreen(
        inNavigationController: UINavigationController!,
        animated: Bool) {
        
        if let initialData = BlueSnapSDK.initialData {
            if purchaseScreen == nil {
                let bundle = BSViewsManager.getBundle()
                let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle);
                purchaseScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.purchaseScreenStoryboardId) as! BSPaymentViewController
            }
            
            let paymentRequest = BSCcPaymentRequest(initialData: initialData)
            purchaseScreen.initScreen(paymentRequest: paymentRequest)
            
            inNavigationController.pushViewController(purchaseScreen, animated: animated)
        }
    }
    
    /**
     Open the check-out screen for an existing CC, For returning shopper.
     
     - parameters:
     - paymentRequest: returning shopper details in the payment request
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     */
    open class func showExistingCCDetailsScreen(
        paymentRequest: BSExistingCcPaymentRequest!,
        inNavigationController: UINavigationController!,
        animated: Bool) {
        
        let bundle = BSViewsManager.getBundle()
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle);
        let existingCcScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.existingCcScreenStoryboardId) as! BSExistingCCViewController
        
        existingCcScreen.initScreen(paymentRequest: paymentRequest)
        
        inNavigationController.pushViewController(existingCcScreen, animated: animated)
    }
    
    /**
     Navigate to the country list, allow changing current selection.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - selectedCountryCode: ISO country code
     - updateFunc: callback; will be called each time a new value is selected
     */
    open class func showCountryList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        selectedCountryCode : String!,
        updateFunc: @escaping (String, String)->Void) {

        let bundle = BSViewsManager.getBundle()
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
        let screen : BSCountryViewController! = storyboard.instantiateViewController(withIdentifier: BSViewsManager.countryScreenStoryboardId) as! BluesnapSDK.BSCountryViewController

        screen.initCountries(selectedCode: selectedCountryCode, updateFunc: updateFunc)
        
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
        
        BSApiManager.getCurrencyRates(completion: { currencies, errors in
            
            if errors != nil || currencies == nil {
                NSLog("Failed to fetch currency rates from BlueSnap server")
                errorFunc()
                return
            }
            if currencyScreen == nil {
                let bundle = BSViewsManager.getBundle()
                let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
                currencyScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.currencyScreenStoryboardId) as! BSCurrenciesViewController
            }
            currencyScreen.initCurrencies(
                currencyCode: selectedCurrencyCode,
                currencies: currencies!,
                updateFunc: updateFunc)
            DispatchQueue.main.async {
                inNavigationController.pushViewController(currencyScreen, animated: animated)
            }
        })
    }

    
    /**
     Navigate to the state list, allow changing current selection.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - selectedCountryCode: ISO country code
     - selectedStateCode: state code
     - updateFunc: callback; will be called each time a new value is selected
     */
    open class func showStateList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        addressDetails: BSBaseAddressDetails,
        updateFunc: @escaping (String, String)->Void) {
        
        let selectedCountryCode = addressDetails.country ?? ""
        let selectedStateCode = addressDetails.state ?? ""

        let countryManager = BSCountryManager.getInstance()
        if let states = countryManager.getCountryStates(countryCode: selectedCountryCode) {
            
            let bundle = BSViewsManager.getBundle()
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
            let screen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.stateScreenStoryboardId) as! BSStatesViewController
            
            screen.initStates(selectedCode: selectedStateCode, allStates: states, updateFunc: updateFunc)
            
            inNavigationController.pushViewController(screen, animated: animated)
        } else {
            NSLog("No state data available for \(selectedCountryCode)")
        }
    }
    
    open class func getImage(imageName: String!) -> UIImage? {
        
        var result : UIImage?
        let myBundle = BSViewsManager.getBundle()
        if let image = UIImage(named: imageName, in: myBundle, compatibleWith: nil) {
            result = image
        }
        return result
    }
    
    open class func createErrorAlert(title: BSLocalizedString, message: BSLocalizedString) -> UIAlertController {
        let messageText = BSLocalizedStrings.getString(message)
        return createErrorAlert(title: title, message: messageText)
    }

    open class func createErrorAlert(title: BSLocalizedString, message: String) -> UIAlertController {
        let titleText = BSLocalizedStrings.getString(title)
        let okButtonText = BSLocalizedStrings.getString(BSLocalizedString.Alert_OK_Button_Text)
        let alert = UIAlertController(title: titleText, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: okButtonText, style: .default, handler: { (action) -> Void in })
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
    open class func openPopupMenu(paymentRequest: BSBasePaymentRequest?,
            inNavigationController : UINavigationController,
            updateCurrencyFunc: @escaping (BSCurrency?, BSCurrency?)->Void,
            errorFunc: @escaping ()->Void) -> UIAlertController {
        
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // Add change currency menu item
        let currencyMenuTitle = BSLocalizedStrings.getString(BSLocalizedString.Menu_Item_Currency)
        let currencyMenuOption = UIAlertAction(title: currencyMenuTitle, style: UIAlertActionStyle.default) { _ in
            if let paymentRequest = paymentRequest {
                BSViewsManager.showCurrencyList(
                    inNavigationController: inNavigationController,
                    animated: true,
                    selectedCurrencyCode: paymentRequest.getCurrency(),
                    updateFunc: updateCurrencyFunc,
                    errorFunc: errorFunc)
            }
        }
        menu.addAction(currencyMenuOption)
        
        // Add Cancel menu item
        let cancelMenuTitle = BSLocalizedStrings.getString(BSLocalizedString.Menu_Item_Cancel)
        let cancelMenuOption = UIAlertAction(title: cancelMenuTitle, style: UIAlertActionStyle.cancel, handler: nil)
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
        url: String!, shouldGoToUrlFunc: ((_ url : String) -> Bool)?) {
        
        let bundle = BSViewsManager.getBundle()
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: bundle)
        let screen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.webScreenStoryboardId) as! BSWebViewController
        screen.initScreen(url: url, shouldGoToUrlFunc: shouldGoToUrlFunc)
        inNavigationController.pushViewController(screen, animated: true)
    }
}
