//
//  CountryManager.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 23/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSCountryManager {
    
    fileprivate var countryCodes : [String] = []
    
    
    init() {
        countryCodes = NSLocale.isoCountryCodes
    }
    
    func getCountryCodes() -> [String] {
        return self.countryCodes
    }
    
    func getCountryName(countryCode: String) -> String? {
        let current = Locale(identifier: "en_US")
        return current.localizedString(forRegionCode: countryCode) ?? nil
    }

}
