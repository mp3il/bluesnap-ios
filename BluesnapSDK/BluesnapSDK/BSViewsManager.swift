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
    static let purchaseScreenStoryboardId = "SummaryScreenStoryboardId"
    static let countryScreenStoryboardId = "BSCountriesStoryboardId"
    static let stateScreenStoryboardId = "BSStatesStoryboardId"

    
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
        
        if let states = countryManager.countryStates(countryCode: selectedCountryCode) {
            
            let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
            let screen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.stateScreenStoryboardId) as! BSStatesViewController
            
            screen.selectedCode = selectedStateCode
            screen.updateFunc = updateFunc
            screen.states = states
            
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


}
