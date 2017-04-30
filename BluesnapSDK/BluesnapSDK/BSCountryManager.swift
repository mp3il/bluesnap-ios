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
    fileprivate let COUNTRY_STATES : [String : [String : String]] = [
        "US": [
            "AK" : "Alaska",
            "AL" : "Alabama",
            "AR" : "Arkansas",
            "AS" : "American Samoa",
            "AZ" : "Arizona",
            "CA" : "California",
            "CO" : "Colorado",
            "CT" : "Connecticut",
            "DC" : "District of Columbia",
            "DE" : "Delaware",
            "FL" : "Florida",
            "GA" : "Georgia",
            "GU" : "Guam",
            "HI" : "Hawaii",
            "IA" : "Iowa",
            "ID" : "Idaho",
            "IL" : "Illinois",
            "IN" : "Indiana",
            "KS" : "Kansas",
            "KY" : "Kentucky",
            "LA" : "Louisiana",
            "MA" : "Massachusetts",
            "MD" : "Maryland",
            "ME" : "Maine",
            "MI" : "Michigan",
            "MN" : "Minnesota",
            "MO" : "Missouri",
            "MS" : "Mississippi",
            "MT" : "Montana",
            "NC" : "North Carolina",
            "ND" : " North Dakota",
            "NE" : "Nebraska",
            "NH" : "New Hampshire",
            "NJ" : "New Jersey",
            "NM" : "New Mexico",
            "NV" : "Nevada",
            "NY" : "New York",
            "OH" : "Ohio",
            "OK" : "Oklahoma",
            "OR" : "Oregon",
            "PA" : "Pennsylvania",
            "PR" : "Puerto Rico",
            "RI" : "Rhode Island",
            "SC" : "South Carolina",
            "SD" : "South Dakota",
            "TN" : "Tennessee",
            "TX" : "Texas",
            "UT" : "Utah",
            "VA" : "Virginia",
            "VI" : "Virgin Islands",
            "VT" : "Vermont",
            "WA" : "Washington",
            "WI" : "Wisconsin",
            "WV" : "West Virginia",
            "WY" : "Wyoming"
        ],
        "BR" : [
            "AC" : "Acre",
            "AM" : "Amazonas",
            "BA" : "Bahia",
            "CE" : "Ceará",
            "DF" : "Distrito Federal",
            "ES" : "Espírito Santo",
            "GO" : "Goiás",
            "MG" : "Minas Gerais",
            "PB" : "Paraíba",
            "PI" : "Piauí",
            "RJ" : "Rio de Janeiro",
            "RN" : "Rio Grande do Norte",
            "RO" : "Rondônia",
            "RR" : "Roraima",
            "RS" : "Rio Grande do Sull",
            "SE" : "Sergipe",
            "SP" : "São Paulo",
            "TO" : "Tocantins",
            "XA" : "Maranhão",
            "XB" : "Mato Grosso do Sul",
            "XC" : "Mato Grosso",
            "XD" : "Santa Catarina",
            "XE" : "Pará",
            "XF" : "Pernambuco",
            "XG" : "Paraná",
            "XH" : "Alagoas",
            "XI" : "Amapá"
        ],
        "CA" : [
            "AB" : "Alberta",
            "BC" : "British Columbia",
            "MB" : "Manitoba",
            "NB" : "New Brunswick",
            "NF" : "Newfoundland",
            "NL" : "Newfoundland and Labrador",
            "NS" : "Nova Scotia",
            "NT" : "Northwest Territories",
            "NU" : "Nunavut",
            "ON" : "Ontario",
            "PE" : "Prince Edward Island",
            "QC" : "Quebec",
            "SK" : "Saskatchewan",
            "YT" : "Yukon Territory"
        ]
    ]
    
    
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

    func countryStates(countryCode : String) -> [String : String]? {
        let result = COUNTRY_STATES[countryCode]
        return result //COUNTRY_STATES[countryCode]
    }
}
