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

    
    /**
     Navigate to the country list, allow changing current selection.
     
     - parameters:
     - inNavigationController: your viewController's navigationController (to be able to navigate back)
     - animated: how to navigate to the new screen
     - selectedCountryCode: 3 characters of the curtrent language code (uppercase)
     - updateFunc: callback; will be called each time a new value is selected
     */
    open class func showCurrencyList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        countryManager : BSCountryManager,
        selectedCountryCode : String!,
        updateFunc: @escaping (String, String)->Void) {
        
        let storyboard = UIStoryboard(name: BSViewsManager.storyboardName, bundle: Bundle(identifier: BSViewsManager.bundleIdentifier))
        let countryScreen = storyboard.instantiateViewController(withIdentifier: BSViewsManager.countryScreenStoryboardId) as! BSCountryViewController

        countryScreen.selectedCountryCode = selectedCountryCode
        countryScreen.updateFunc = updateFunc
        countryScreen.countryManager = countryManager
        
        inNavigationController.pushViewController(countryScreen, animated: animated)
    }
}
