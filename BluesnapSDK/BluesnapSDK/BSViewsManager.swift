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
    static let purchaseScreenStoryboardId = "BSPaymentScreenStoryboardId" //"BSPurchaseScreenStoryboardId"
    static let countryScreenStoryboardId = "BSCountriesStoryboardId"
    static let stateScreenStoryboardId = "BSStatesStoryboardId"
    static let webScreenStoryboardId = "BSWebViewController"

    fileprivate static var startScreen: BSStartViewController!
    fileprivate static var purchaseScreen: BSPaymentViewController!//BSSummaryScreen!
    fileprivate static var currencyScreen: BSCurrenciesViewController!

    /**
     Open the check-out start screen, where the shopper chooses CC/ApplePay.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - bsToken: BlueSnap token, should be fresh and valid
     - paymentDetails: object that holds the shopper and payment details; shopper name and shipping details may be pre-filled
     - withShipping: if true, the shopper will be asked to supply shipping details
     - fullBilling: if true, we collect full billing address; otherwise only name and optionally zip code
     - purchaseFunc: callback; will be called when the shopper hits "Pay" and all the data is prepared
     */
    open class func showStartScreen(
        inNavigationController: UINavigationController!,
        animated: Bool,
        bsToken : BSToken!,
        paymentDetails : BSPaymentDetails!,
        withShipping: Bool,
        fullBilling : Bool,
        purchaseFunc: @escaping (BSPaymentDetails!)->Void) {
        
        if startScreen == nil {
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
            startScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.startScreenStoryboardId) as! BSStartViewController
        }
        
        startScreen.paymentDetails = paymentDetails
        startScreen.bsToken = bsToken
        startScreen.purchaseFunc = purchaseFunc
        startScreen.fullBilling = fullBilling
        
        inNavigationController.pushViewController(startScreen, animated: animated)
    }
    
    /**
     Open the check-out screen, where the shopper payment details are entered.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - bsToken: BlueSnap token, should be fresh and valid
     - paymentDetails: object that holds the shopper and payment details; shopper name and shipping details may be pre-filled
     - fullBilling: if true, we collect full billing address; otherwise only name and optionally zip code
     - purchaseFunc: callback; will be called when the shopper hits "Pay" and all the data is prepared
     */
    open class func showCCDetailsScreen(
        inNavigationController: UINavigationController!,
        animated: Bool,
        bsToken : BSToken!,
        paymentDetails : BSPaymentDetails!,
        fullBilling : Bool,
        purchaseFunc: @escaping (BSPaymentDetails!)->Void) {
        
        if purchaseScreen == nil {
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
            purchaseScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.purchaseScreenStoryboardId) as! BSPaymentViewController //BSSummaryScreen
        }
        
        purchaseScreen.paymentDetails = paymentDetails
        purchaseScreen.bsToken = bsToken
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
        
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
        let screen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.countryScreenStoryboardId) as! BSCountryViewController

        screen.selectedCountryCode = selectedCountryCode
        screen.updateFunc = updateFunc
        screen.countryManager = countryManager
        
        inNavigationController.pushViewController(screen, animated: animated)
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
        addressDetails: BSAddressDetails,
        updateFunc: @escaping (String, String)->Void) {
        
        let selectedCountryCode = addressDetails.country ?? ""
        let selectedStateCode = addressDetails.state ?? ""
        
        if let states = countryManager.getCountryStates(countryCode: selectedCountryCode) {
            
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
            let screen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.stateScreenStoryboardId) as! BSStatesViewController
            
            screen.selectedCode = selectedStateCode
            screen.updateFunc = updateFunc
            screen.allStates = states
            
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
        return indicator
    }
    
    open class func startActivityIndicator(activityIndicator: UIActivityIndicatorView!) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = .gray
                activityIndicator.startAnimating()
            }
        }
    }

    open class func stopActivityIndicator(activityIndicator: UIActivityIndicatorView!) {
        
        UIApplication.shared.endIgnoringInteractionEvents()
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
            }
        }
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
    
    /*
     Create the popup menu for payment screen
    */
    static internal let privacyPolicyURL = "http://home.bluesnap.com/ecommerce/legal/privacy-policy/"
    static internal let refundPolicyURL = "http://home.bluesnap.com/ecommerce/legal/refund-policy/"
    static internal let termsURL = "http://home.bluesnap.com/ecommerce/legal/terms-and-conditions/"
    open class func openPopupMenu(paymentDetails: BSPaymentDetails?, bsToken: BSToken?,
            inNavigationController : UINavigationController,
            updateCurrencyFunc: @escaping (BSCurrency?, BSCurrency?)->Void) -> UIAlertController {
        
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let currencyMenuOption = UIAlertAction(title: "Currency", style: UIAlertActionStyle.default) { _ in
            if let paymentDetails = paymentDetails, let bsToken = bsToken {
                BlueSnapSDK.showCurrencyList(
                    inNavigationController: inNavigationController,
                    animated: true,
                    bsToken: bsToken,
                    selectedCurrencyCode: paymentDetails.getCurrency(),
                    updateFunc: updateCurrencyFunc)
            }
        }
        
        let refundPolicyMenuOption = UIAlertAction(title: "Refund Policy", style: .default) { _ in
            showBrowserScreen(inNavigationController: inNavigationController, url: refundPolicyURL)
        }
        
        let privacyPolicyMenuOption = UIAlertAction(title: "Privacy Policy", style: .default) { _ in
            showBrowserScreen(inNavigationController: inNavigationController, url: privacyPolicyURL)
        }
        
        let termsMenuOption = UIAlertAction(title: "Terms & Conditions", style: .default) { _ in
            showBrowserScreen(inNavigationController: inNavigationController, url: termsURL)
        }
        
        let cancelMenuOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        // relate actions to controllers
        menu.addAction(currencyMenuOption)
        menu.addAction(refundPolicyMenuOption)
        menu.addAction(privacyPolicyMenuOption)
        menu.addAction(termsMenuOption)
        menu.addAction(cancelMenuOption)
        
        //presentViewController(otherAlert, animated: true, completion: nil)
        return menu
    }
}
