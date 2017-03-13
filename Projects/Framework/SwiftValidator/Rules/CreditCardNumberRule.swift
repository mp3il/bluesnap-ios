//
//  PhoneValidation.swift
//
//  Created by Ori S
//

import Foundation

/**
 `CreditCardNumberRule` is a subclass of Rule that defines how a phone number is validated.
 */
open class CreditCardNumberRule: RegexRule {
//    let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
    
    static let regex = "^\\d{4}$"
    
       public convenience init(message : String = "Enter a valid credit card number") {
        self.init(regex: CreditCardNumberRule.regex, message : message)
    }
    
}
