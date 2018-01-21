//
//  PaymentTypeScreenUITestHelper.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 07/09/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import XCTest

class BSPaymentTypeScreenUITestHelper {
    
    var keyboardIsHidden = true

    var app: XCUIApplication!
    
    init(app: XCUIApplication!, keyboardIsHidden : Bool) {
        self.app = app
        self.keyboardIsHidden = keyboardIsHidden
    }
    
    func getApplePayButtonElement() -> XCUIElement{
        return app.buttons["ApplePayButton"]
    }
    
    func getPayPalButtonElement() -> XCUIElement{
        return app.buttons["PayPalButton"]
    }
    
    func getCcButtonElement() -> XCUIElement{
        return app.buttons["CcButton"]
    }
    
    func checkPaymentTypes(expectedApplePay: Bool, expectedPayPal: Bool, expectedCC: Bool) {
        
        // check visibility of CC button
        let ccButton = getCcButtonElement()
        let ccButtonIsVisible = ccButton.exists
        assert(ccButtonIsVisible == expectedCC)

        // check visibility of ApplePay button
        let applePayButton = getApplePayButtonElement()
        let applePayButtonIsVisible = applePayButton.exists //&& applePayButton.isEnabled && applePayButton.isHittable
        assert(applePayButtonIsVisible == expectedApplePay)
        
        // check visibility of PayPal button
        let payPalButton = getPayPalButtonElement()
        let payPalButtonIsVisible = payPalButton.exists
        assert(payPalButtonIsVisible == expectedPayPal)
    }

}
