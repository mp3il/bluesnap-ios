//
//  BluesnapSDKExampleUITests.swift
//  BluesnapSDKExampleUITests
//
//  Created by Oz on 26/03/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
import Foundation
import PassKit
import BluesnapSDK

class BluesnapSDKExampleUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()

        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)

        // prepare initial data for the test
        let initialData = BSInitialData()
        initialData.fullBilling = true
        initialData.withShipping = true
        initialData.withEmail = false
        initialData.priceDetails = BSPriceDetails(amount: 30, taxAmount: 0.5, currency: "USD")
        
        // set switches and amounts in merchant checkout screen
        setMerchantCheckoutScreen(app: app, initialData: initialData)
        
        // click "Checkout" button
        app.buttons["CheckoutButton"].tap()
        
        // make sure payment type buttons are visible
        paymentTypeHelper.checkPaymentTypes(expectedApplePay: true, expectedPayPal: true, expectedCC: true)
        
        // click CC button
        app.buttons["CcButton"].tap()
        
        // check CCN component state
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)
        paymentHelper.checkCcnComponentState(shouldBeOpen: true)
        
        let ccnTextField = paymentHelper.getCcInputFieldElement()
        ccnTextField.typeText("4111 1111 1111 1111")

        paymentHelper.checkCcnComponentState(shouldBeOpen: false)

        let expTextField = paymentHelper.getExpInputFieldElement()
        expTextField.typeText("1126")
        
        let cvvTextField = paymentHelper.getCvvInputFieldElement()
        cvvTextField.typeText("333")
        
        // make sure fields are shown according to configuration
        paymentHelper.checkInputs(initialData: initialData)
        
        // fill field values
        let billingDetails = BSBillingAddressDetails(email: "shevie@gmail.com", name: "Shevie Chen", address: "58 somestreet", city : "somecity", zip : "4282300", country : "CA", state : "ON")
        paymentHelper.setFieldValues(billingDetails: billingDetails)

        // check that the values are in correctly
        initialData.billingDetails = billingDetails
        paymentHelper.checkInputs(initialData: initialData)
        
        //let elementsQuery = app.scrollViews.otherElements
        /*
        let paybuttonButton = app.buttons["PayButton"]
        paybuttonButton.tap()
        */
        
        print("done")
    }
    
    
    
    private func setMerchantCheckoutScreen(app: XCUIApplication, initialData: BSInitialData) {
        
        // set with Shipping switch = on
        let withShippingSwitch = app.switches["WithShippingSwitch"]
        let withShippingSwitchValue = (withShippingSwitch.value as? String) ?? "0"
        if (withShippingSwitchValue == "0" && initialData.withShipping) || (withShippingSwitchValue == "1" && !initialData.withShipping) {
            withShippingSwitch.tap()
        }
        
        // set full billing switch = on
        let fullBillingSwitch = app.switches["FullBillingSwitch"]
        let fullBillingSwitchValue = (fullBillingSwitch.value as? String) ?? "0"
        if (fullBillingSwitchValue == "0" && initialData.fullBilling) || (fullBillingSwitchValue == "1" && !initialData.fullBilling) {
            fullBillingSwitch.tap()
        }
        
        // set with Email switch = on
        let withEmailSwitch = app.switches["WithEmailSwitch"]
        let withEmailSwitchValue = (withEmailSwitch.value as? String) ?? "0"
        if (withEmailSwitchValue == "0" && initialData.withEmail) || (withEmailSwitchValue == "1" && !initialData.withEmail) {
            withEmailSwitch.tap()
        }
        
        if let priceDetails = initialData.priceDetails {
            
            // set amount text field value
            let amount = "\(priceDetails.amount ?? 0)"
            let amountField : XCUIElement = app.textFields["AmountField"]
            amountField.tap()
            amountField.doubleTap()
            amountField.typeText(amount)
            
            // set tax text field value
            let taxAmount = "\(priceDetails.taxAmount ?? 0)"
            let taxField : XCUIElement = app.textFields["TaxField"]
            taxField.tap()
            taxField.doubleTap()
            taxField.typeText(taxAmount)
        }
        
    }
}
