//
//  BSExistingCcScreenUITestHelper.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 09/11/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK

class BSExistingCcScreenUITestHelper {
    
    var app: XCUIApplication!
    var billingNameLabel : XCUIElement!
    var shippingNameLabel : XCUIElement!
    var billingAddressLabel : XCUIElement!
    var shippingAddressLabel : XCUIElement!
    var editBillingButton : XCUIElement!
    var editShippingButton : XCUIElement!
    var keyboardIsHidden : Bool  = true

    init(app: XCUIApplication!, keyboardIsHidden : Bool) {
        self.app = app
//        let elementsQuery = app.scrollViews.otherElements
        billingNameLabel = app.staticTexts["BillingName"] //elementsQuery.element(matching: .any, identifier: "BillingName")
        shippingNameLabel = app.staticTexts["ShippingName"] //elementsQuery.element(matching: .any, identifier: "ShippingName")
        billingAddressLabel = app.staticTexts["BillingAddress"] //elementsQuery.element(matching: .any, identifier: "BillingAddress")
        shippingAddressLabel = app.staticTexts["ShippingAddress"] //elementsQuery.element(matching: .any, identifier: "ShippingAddress")
        editBillingButton = app.buttons["EditBillingButton"] //elementsQuery.element(matching: .any, identifier: "EditBillingButton")
        editShippingButton = app.buttons["EditShippingButton"] //elementsQuery.element(matching: .any, identifier: "EditShippingButton")
        self.keyboardIsHidden = keyboardIsHidden
    }
    
    
    // check visibility of inputs - make sure fields are shown according to configuration
    func checkScreenItems(sdkRequest: BSSdkRequest) {
        
        assert(billingNameLabel.exists)
        assert(billingAddressLabel.exists)
        assert(editBillingButton.exists)
        if sdkRequest.withShipping {
            assert(shippingNameLabel.exists)
            assert(shippingAddressLabel.exists)
            assert(editShippingButton.exists)
        } else {
            assert(!shippingNameLabel.exists)
            assert(!shippingAddressLabel.exists)
            assert(!editShippingButton.exists)
        }
    }
}
