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
    
    /* -------------------------------- Returning shopper tests ---------------------------------------- */
    
    func testShortReturningShopperExistingCcFlow() {
        
        // no full billing, no shipping, no email, new CC
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: false, withShipping: false, withEmail: false, amount: 20, currency: "USD")
        initialData.priceDetails = nil
        
        gotoPaymentScreen(app: app, initialData: initialData, returningShopper: true, tapExistingCc: true)
        
        let _ = waitForExistingCcScreen(app: app)
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 20.00")
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText: "Success!")
        
        print("done")
    }
    
    func testShortReturningShopperExistingCcFlowWithShipping() {
        
        // no full billing, with shipping, no email, new CC
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: false, withShipping: true, withEmail: false, amount: 20, currency: "USD")
        initialData.priceDetails = nil
        
        gotoPaymentScreen(app: app, initialData: initialData, returningShopper: true, tapExistingCc: true)
        
        let _ = waitForExistingCcScreen(app: app)
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 20.00")
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText: "Success!")
        
        print("done")
    }
    
    func testShortReturningShopperExistingCcFlowWithEdit() {
        
        // full billing, with shipping, no email, new CC
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: true, withEmail: false, amount: 20, currency: "USD")
        initialData.priceDetails = nil
        
        gotoPaymentScreen(app: app, initialData: initialData, returningShopper: true, tapExistingCc: true)
        
        let existingCcHelper = waitForExistingCcScreen(app: app)
        
        existingCcHelper.editBillingButton.tap()
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)
        paymentHelper.setFieldValues(billingDetails: getDummyBillingDetails(), initialData: initialData)
        paymentHelper.closeKeyboard()
        let editBillingPayButton = checkPayButton(app: app, expectedPayText: "Done")
        editBillingPayButton.tap()
        
        existingCcHelper.editShippingButton.tap()

        let shippingHelper = BSShippingScreenUITestHelper(app: app)
        shippingHelper.setFieldValues(shippingDetails: getDummyShippingDetails(countryCode: "IL", stateCode: nil), initialData: initialData)
        shippingHelper.closeKeyboard()
        let editShippingPayButton = checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Done")
        editShippingPayButton.tap()
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 20.00")
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText: "Success!")
        
        print("done")
    }

    // full billing, with shipping, check "shipping same as billing"
    
    func testShortReturningShopperNewCcFlow() {
        
        // no full billing, no shipping, no email, new CC
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: false, withShipping: false, withEmail: false, amount: 30, currency: "USD")
        initialData.priceDetails = nil
        
        gotoPaymentScreen(app: app, initialData: initialData, returningShopper: true)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)
        
        fillBillingDetails(paymentHelper: paymentHelper, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails(countryCode: "US"), ignoreCountry: true)
        
        let elementsQuery = app.scrollViews.otherElements
        let textField = elementsQuery.element(matching: .any, identifier: "Name")
        if textField.exists {
            textField.tap()
            app.keyboards.buttons["Done"].tap()
        }
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 20.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText: "Success!")
        
        print("done")
    }
    
    
    
    /* -------------------------------- New shopper tests ---------------------------------------- */
    
    func testFlowFullBillingNoShippingNoEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: false, withEmail: false, amount: 30, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)

        fillBillingDetails(paymentHelper: paymentHelper, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 30.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingNoEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: true, withEmail: false, amount: 30, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)
        
        let _ = checkPayButton(app: app, expectedPayText: "Pay $ 31.50")

        fillBillingDetails(paymentHelper: paymentHelper, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        paymentHelper.closeKeyboard()
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: true)
        let _ = checkPayButton(app: app, expectedPayText: "Pay $ 30.30")
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: false)
        let payButton = checkPayButton(app: app, expectedPayText: "Shipping >")
        
        payButton.tap()
        waitForShippingScreen(app: app)
        
        let shippingPayButton = checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Pay $ 31.50")
        let shippingHelper = fillShippingDetails(app: app, initialData: initialData, shippingDetails: getDummyShippingDetails())
        let _ = checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Pay $ 30.30")
        
        shippingHelper.closeKeyboard()
        shippingPayButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingWithEmailNostate() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: true, withEmail: true, amount: 20, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "IL"
        billingDetails.state = nil
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)
        
        let _ = checkPayButton(app: app, expectedPayText: "Pay $ 21.00")
        
        fillBillingDetails(paymentHelper: paymentHelper, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: billingDetails)
        
        paymentHelper.closeKeyboard()
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: true)
        let _ = checkPayButton(app: app, expectedPayText: "Pay $ 20.00")
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: false)
        let payButton = checkPayButton(app: app, expectedPayText: "Shipping >")
        
        payButton.tap()
        waitForShippingScreen(app: app)
        
        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GB"
        shippingDetails.state = nil

        let shippingPayButton = checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Pay $ 21.00")
        
        let shippingHelper = fillShippingDetails(app: app, initialData: initialData, shippingDetails: shippingDetails)
        let _ = checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Pay $ 20.00")
        
        shippingHelper.closeKeyboard()
        shippingPayButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    func testFlowFullBillingWithShippingWithEmailNoZip() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: true, withEmail: true, amount: 20, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let billingDetails = getDummyBillingDetails()
        billingDetails.country = "GH"
        billingDetails.state = nil
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)

        fillBillingDetails(paymentHelper: paymentHelper, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: billingDetails)
        
        paymentHelper.closeKeyboard()
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: true)
        let _ = checkPayButton(app: app, expectedPayText: "Pay $ 20.00")
        
        paymentHelper.setShippingSameAsBillingSwitch(shouldBeOn: false)
        let payButton = checkPayButton(app: app, expectedPayText: "Shipping >")
        
        payButton.tap()
        waitForShippingScreen(app: app)
        
        let shippingDetails = getDummyShippingDetails()
        shippingDetails.country = "GH"
        shippingDetails.state = nil
        let shippingHelper = fillShippingDetails(app: app, initialData: initialData, shippingDetails: shippingDetails)
        let shippingPayButton = checkAPayButton(app: app, buttonId: "ShippingPayButton", expectedPayText: "Pay $ 20.00")
        
        shippingHelper.closeKeyboard()
        shippingPayButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowFullBillingNoShippingWithEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: true, withShipping: false, withEmail: true, amount: 30, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)
        fillBillingDetails(paymentHelper: paymentHelper, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 30.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowNoFullBillingNoShippingWithEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: false, withShipping: false, withEmail: true, amount: 30, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)

        fillBillingDetails(paymentHelper: paymentHelper, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 30.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText:  "Success!")
        
        print("done")
    }
    
    
    func testFlowNoFullBillingNoShippingNoEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: false, withShipping: false, withEmail: false, amount: 30, currency: "USD")
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)

        fillBillingDetails(paymentHelper: paymentHelper, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails())
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 30.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText: "Success!")
        
        print("done")
    }
    
    func testShortestFlowNoFullBillingNoShippingNoEmail() {
        
        let app = XCUIApplication()
        
        let initialData = prepareInitialData(fullBilling: false, withShipping: false, withEmail: false, amount: 30, currency: "USD")
        initialData.priceDetails = nil
        
        gotoPaymentScreen(app: app, initialData: initialData)
        
        let paymentHelper = BSPaymentScreenUITestHelper(app:app)
        
        fillBillingDetails(paymentHelper: paymentHelper, initialData: initialData, ccn: "4111 1111 1111 1111", exp: "1126", cvv: "333", billingDetails: getDummyBillingDetails(countryCode: "US"), ignoreCountry: true)
        
        let elementsQuery = app.scrollViews.otherElements
        let textField = elementsQuery.element(matching: .any, identifier: "Name")
        if textField.exists {
            textField.tap()
            app.keyboards.buttons["Done"].tap()
        }
        
        let payButton = checkPayButton(app: app, expectedPayText: "Pay $ 20.00")
        paymentHelper.closeKeyboard()
        payButton.tap()
        
        checkResult(app: app, expectedSuccessText: "Success!")
        
        print("done")
    }
    

    
    //------------------------------------ Helper functions ----------------------------
    
     
    private func checkResult(app: XCUIApplication, expectedSuccessText: String) {
        
        let successLabel = app.staticTexts["SuccessLabel"]
        waitForElementToExist(element: successLabel, waitTime: 100)
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
    
    private func getDummyBillingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSBillingAddressDetails {
        
        let billingDetails = BSBillingAddressDetails(email: "shevie@gmail.com", name: "Shevie Chen", address: "58 somestreet", city : "somecity", zip : "4282300", country : countryCode, state : stateCode)
        return billingDetails
    }
    
    private func getDummyShippingDetails(countryCode: String? = "CA", stateCode: String? = "ON") -> BSShippingAddressDetails {
        
        let shippingDetails = BSShippingAddressDetails(phone: "18008007070", name: "Shevie Chen", address: "58 somestreet", city : "somecity", zip : "4282300", country : countryCode, state : stateCode)
        return shippingDetails
    }
    
    private func prepareInitialData(fullBilling: Bool, withShipping: Bool, withEmail: Bool, amount: Double!, currency: String) -> BSInitialData {

        let taxAmount = amount * 0.05 // according to updateTax() in ViewController
        let priceDetails = BSPriceDetails(amount: amount, taxAmount: taxAmount, currency: currency)
        let initialData = BSInitialData(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: {_ in }, updateTaxFunc: nil)
        return initialData
    }
    
    private func fillBillingDetails(paymentHelper: BSPaymentScreenUITestHelper, initialData: BSInitialData, ccn: String, exp: String, cvv: String, billingDetails: BSBillingAddressDetails, ignoreCountry: Bool? = false) {
        
        // fill CC values
        paymentHelper.setCcDetails(isOpen: true, ccn: ccn, exp: exp, cvv: cvv)
        
        // make sure fields are shown according to configuration
        paymentHelper.checkInputs(initialData: initialData)
        
        // fill field values
        paymentHelper.setFieldValues(billingDetails: billingDetails, initialData: initialData, ignoreCountry: ignoreCountry)
        
        // check that the values are in correctly
        initialData.billingDetails = billingDetails
        paymentHelper.checkInputs(initialData: initialData)
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
    
    private func gotoPaymentScreen(app: XCUIApplication, initialData: BSInitialData, returningShopper: Bool = false, tapExistingCc: Bool = false) {
        
        let paymentTypeHelper = BSPaymentTypeScreenUITestHelper(app: app)
        
        // set switches and amounts in merchant checkout screen
        setMerchantCheckoutScreen(app: app, initialData: initialData, newShopper: !returningShopper)
        
        // click "Checkout" button
        app.buttons["CheckoutButton"].tap()
        
        // wait for payment type screen to load
        
        let ccButton = paymentTypeHelper.getCcButtonElement()
        waitForElementToExist(element: ccButton, waitTime: 10)
        
        // make sure payment type buttons are visible
        paymentTypeHelper.checkPaymentTypes(expectedApplePay: true, expectedPayPal: true, expectedCC: true)
        
        if tapExistingCc {
            // click existing CC
            app.buttons["existingCc0"].tap()
            
        } else {
            // click New CC button
            app.buttons["CcButton"].tap()
        }
    }
    
    private func setMerchantCheckoutScreen(app: XCUIApplication, initialData: BSInitialData, newShopper: Bool = true) {
        
        // set new/returning shopper
        let newShopperSwitch = app.switches["NewShopperSwitch"]
        waitForElementToExist(element: newShopperSwitch, waitTime: 30)
        let newShopperSwitchValue = (newShopperSwitch.value as? String) ?? "0"
        if (newShopperSwitchValue == "0" && newShopper) || (newShopperSwitchValue == "1" && !newShopper) {
            newShopperSwitch.tap()
        }
        
        // set with Shipping switch = on
        let withShippingSwitch = app.switches["WithShippingSwitch"]
        waitForElementToExist(element: withShippingSwitch, waitTime: 30)
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
        }
        
    }
    
    private func waitForExistingCcScreen(app: XCUIApplication) -> BSExistingCcScreenUITestHelper {
        
        let existingCcHelper = BSExistingCcScreenUITestHelper(app:app)
        waitForElementToExist(element: existingCcHelper.billingNameLabel, waitTime: 5)
        return existingCcHelper
    }
    
    private func waitForPaymentScreen(app: XCUIApplication) {
        
        let payButton = app.buttons["PayButton"]
        waitForElementToExist(element: payButton, waitTime: 5)
    }
    
    private func waitForShippingScreen(app: XCUIApplication) {
        
        let payButton = app.buttons["ShippingPayButton"]
        waitForElementToExist(element: payButton, waitTime: 5)
    }
    
    private func waitForElementToExist(element: XCUIElement, waitTime: TimeInterval) {
        
        let exists = NSPredicate(format: "exists == 1")
        let ex: XCTestExpectation = expectation(for: exists, evaluatedWith: element)
        wait(for: [ex], timeout: waitTime)
        //waitForExpectations(timeout: waitTime, handler: { error in
         //   NSLog("Finished waiting")
        //})
    }
}

//extension XCTestCase {
//    
//    func wait(for duration: TimeInterval) {
//        let waitExpectation = expectation(description: "Waiting")
//        
//        let when = DispatchTime.now() + duration
//        DispatchQueue.main.asyncAfter(deadline: when) {
//            waitExpectation.fulfill()
//        }
//        
//        // We use a buffer here to avoid flakiness with Timer on CI
//        waitForExpectations(timeout: duration + 0.5)
//    }
//}
