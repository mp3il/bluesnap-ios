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
    
    
    func testFlowFullBillingNoShippingNoEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: false, withEmail: false, amount: 30, taxAmount: 0.5, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let _ = fillBillingDetails(app: app, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 30.50")
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingNoEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: true, withEmail: false, amount: 30, taxAmount: 0.5, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let paymentHelper = fillBillingDetails(app: app, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: true)
        let _ = checkPayButton(app: app, expectedPayText: "Pay $ 30.50")
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: false)
        let payButton = checkPayButton(app: app, expectedPayText: "Shipping >")
        
        payButton.tap()
        
        let _ = fillShippingDetails(app: app, initialData: initialData, shippingDetails: getDummyShippingDetails())
        let shippingPayButton = checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Pay $ 30.50")
        
        shippingPayButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingWithEmailNostate() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: true, withEmail: true, amount: 20, taxAmount: 1, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "IL"
        billingDetails.state = nil
        let paymentHelper = fillBillingDetails(app: app, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: billingDetails)
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: true)
        let _ = checkPayButton(app: app, expectedPayText: "Pay $ 21.00")
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: false)
        let payButton = checkPayButton(app: app, expectedPayText: "Shipping >")
        
        payButton.tap()
        
        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GB"
        shippingDetails.state = nil
        let _ = fillShippingDetails(app: app, initialData: initialData, shippingDetails: shippingDetails)
        let shippingPayButton = checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Pay $ 21.00")
        
        shippingPayButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingWithEmailNoZip() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: true, withEmail: true, amount: 20, taxAmount: 1, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "GH"
        billingDetails.state = nil
        let paymentHelper = fillBillingDetails(app: app, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: billingDetails)
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: true)
        let _ = checkPayButton(app: app, expectedPayText: "Pay $ 21.00")
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: false)
        let payButton = checkPayButton(app: app, expectedPayText: "Shipping >")
        
        payButton.tap()
        
        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GH"
        shippingDetails.state = nil
        let _ = fillShippingDetails(app: app, initialData: initialData, shippingDetails: shippingDetails)
        let shippingPayButton = checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Pay $ 21.00")
        
        shippingPayButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowFullBillingNoShippingWithEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: false, withEmail: true, amount: 30, taxAmount: 0.5, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let _ = fillBillingDetails(app: app, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 30.50")
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowNoFullBillingNoShippingWithEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: false, withShipping: false, withEmail: true, amount: 30, taxAmount: 0.5, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let _ = fillBillingDetails(app: app, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 30.50")
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowNoFullBillingNoShippingNoEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: false, withShipping: false, withEmail: false, amount: 30, taxAmount: 0.5, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let _ = fillBillingDetails(app: app, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 30.50")
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    
    //------------------------------------ Helper functions ----------------------------
    
     
    private func checkResult(app: XCUIApplication, expectedSuccessText: String) {
        
        let successLabel = app.staticTexts["SuccessLabel"]
        let labelText: String = successLabel.label
        assert(labelText == expectedSuccessText)
    }
    
    private func checkPayButton(app: XCUIApplication, expectedPayText: String) -> XCUIElement {
        
        return checkAPayButton(app: app, buttonId: "PayButton", expectedPayText: expectedPayText)
    }
    
    private func checkAPayButton(app: XCUIApplication, buttonId: String!, expectedPayText: String) -> XCUIElement {
        
        let payButton = app.buttons[buttonId]
        let payButtonText = payButton.label
        assert(expectedPayText == payButtonText)
        return payButton
    }
    
    private func getDummyBillingDetails() -> BSBillingAddressDetails {
        
        let billingDetails = BSBillingAddressDetails(email: "shevie@gmail.com", name: "Shevie Chen", address: "58 somestreet", city : "somecity", zip : "4282300", country : "CA", state : "ON")
        return billingDetails
    }
    
    private func getDummyShippingDetails() -> BSShippingAddressDetails {
        
        let shippingDetails = BSShippingAddressDetails(phone: "12345678", name: "Shevie Chen", address: "58 somestreet", city : "somecity", zip : "4282300", country : "CA", state : "ON")
        return shippingDetails
    }
    
    private func prepareInitialData(fullBilling: Bool, withShipping: Bool, withEmail: Bool, amount: Double!, taxAmount: Double, currency: String) -> BSInitialData {

        let initialData = BSInitialData()
        initialData.fullBilling = fullBilling
        initialData.withShipping = withShipping
        initialData.withEmail = withEmail
        initialData.priceDetails = BSPriceDetails(amount: amount, taxAmount: taxAmount, currency: currency)
        return initialData
    }
    
    private func fillBillingDetails(app: XCUIApplication, initialData: BSInitialData, ccn: String, exp: String, cvv: String, billingDetails: BSBillingAddressDetails) -> BSPaymentScreenUITestHelper {
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)
        
        // fill CC values
        paymentHelper.setCcDetails(isOpen: true, ccn: ccn, exp: exp, cvv: cvv)
        
        // make sure fields are shown according to configuration
        paymentHelper.checkInputs(initialData: initialData)
        
        // fill field values
        paymentHelper.setFieldValues(billingDetails: billingDetails, initialData: initialData)
        
        // check that the values are in correctly
        initialData.billingDetails = billingDetails
        paymentHelper.checkInputs(initialData: initialData)
        
        return paymentHelper
    }
    
    private func fillShippingDetails(app: XCUIApplication, initialData: BSInitialData, shippingDetails: BSShippingAddressDetails) -> BSShippingScreenUITestHelper {
        
        let paymentHelper = BSShippingScreenUITestHelper(app:app)
        
        // make sure fields are shown according to configuration
        initialData.shippingDetails = BSShippingAddressDetails()
        paymentHelper.checkInputs(initialData: initialData)
        
        // fill field values
        paymentHelper.setFieldValues(shippingDetails: shippingDetails, initialData: initialData)
        
        // check that the values are in correctly
        initialData.shippingDetails = shippingDetails
        paymentHelper.checkInputs(initialData: initialData)
        
        return paymentHelper
    }
    
    private func gotoPaymentScreen(app: XCUIApplication, initialData: BSInitialData) {
        
        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)
        
        // set switches and amounts in merchant checkout screen
        setMerchantCheckoutScreen(app: app, initialData: initialData)
        
        // click "Checkout" button
        app.buttons["CheckoutButton"].tap()
        
        // make sure payment type buttons are visible
        paymentTypeHelper.checkPaymentTypes(expectedApplePay: true, expectedPayPal: true, expectedCC: true)
        
        // click CC button
        app.buttons["CcButton"].tap()
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
