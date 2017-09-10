//
//  BSPaymentScreenUITestHelper.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 07/09/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK

class BSPaymentScreenUITestHelper {
    
    var app: XCUIApplication!
    var ccInput : XCUIElement!
    var nameInput : XCUIElement!
    var emailInput : XCUIElement!
    var zipInput : XCUIElement!
    var cityInput : XCUIElement!
    var streetInput : XCUIElement!
    var stateInput : XCUIElement!
    
    let bsCountryManager = BSCountryManager.getInstance()

    init(app: XCUIApplication!) {
        self.app = app
        let elementsQuery = app.scrollViews.otherElements
        ccInput = elementsQuery.element(matching: .any, identifier: "CCN")
        nameInput = elementsQuery.element(matching: .any, identifier: "Name")
        emailInput = elementsQuery.element(matching: .any, identifier: "Email")
        zipInput = elementsQuery.element(matching: .any, identifier: "Zip")
        cityInput = elementsQuery.element(matching: .any, identifier: "City")
        streetInput = elementsQuery.element(matching: .any, identifier: "Street")
        stateInput = elementsQuery.element(matching: .any, identifier: "State")
    }
    
    func getCcInputFieldElement() -> XCUIElement {
        return ccInput.textFields["CcTextField"]
    }
    
    func getExpInputFieldElement() -> XCUIElement {
        return ccInput.textFields["ExpTextField"]
    }
    
    func getCvvInputFieldElement() -> XCUIElement {
        return ccInput.textFields["CvvTextField"]
    }
    
    func getInputFieldElement(_ input : XCUIElement) -> XCUIElement {
        return input.textFields["TextField"]
    }
    
    func getInputErrorLabelElement(_ input : XCUIElement) -> XCUIElement {
        return input.staticTexts["ErrorLabel"]
    }
    
    func getInputLabelElement(_ input : XCUIElement) -> XCUIElement {
        return input.staticTexts["InputLabel"]
    }
    
    func getInputCoverButtonElement(_ input : XCUIElement) -> XCUIElement {
        return input.buttons["FieldCoverButton"]
    }
    
    func getInputImageButtonElement(_ input : XCUIElement) -> XCUIElement {
        return input.buttons["ImageButton"]
    }


    // check CCN component state
    func checkCcnComponentState(shouldBeOpen: Bool) {
        
        let ccnTextField = getCcInputFieldElement()
        let expTextField = getExpInputFieldElement()
        let cvvTextField = getCvvInputFieldElement()
        
        if shouldBeOpen {
            assert(ccnTextField.exists)
            assert(!expTextField.exists)
            assert(!cvvTextField.exists)
        } else {
            assert(!ccnTextField.exists)
            assert(expTextField.exists)
            assert(cvvTextField.exists)
        }
    }
    
    // check visibility of inputs - make sure fields are shown according to configuration
    func checkInputs(initialData: BSInitialData) {
        
        if let billingDetails = initialData.billingDetails {
            checkInput(input: nameInput, expectedExists: true, expectedValue: billingDetails.name ?? "", expectedLabelText: "Name")
            checkInput(input: emailInput, expectedExists: initialData.withEmail, expectedValue: billingDetails.email ?? "", expectedLabelText: "Email")
            checkInput(input: cityInput, expectedExists: initialData.fullBilling, expectedValue: billingDetails.city ?? "", expectedLabelText: "City")
            checkInput(input: streetInput, expectedExists: initialData.fullBilling, expectedValue: billingDetails.address ?? "", expectedLabelText: "Street")
            // zip should be hidden only for country that does not have zip; label also changes according to country
            let expectedZipLabelText = (billingDetails.country == "US") ? "Billing Zip" : "Postal Code"
            let zipShouldBeVisible = !BSCountryManager.getInstance().countryHasNoZip(countryCode: billingDetails.country ?? "")
            checkInput(input: zipInput, expectedExists: zipShouldBeVisible, expectedValue: initialData.billingDetails?.zip ?? "", expectedLabelText: expectedZipLabelText)
            if let countryCode = billingDetails.country {
                // check country image - this does not work, don;t know how to access the image
                //let countryFlagButton = getInputImageButtonElement(nameInput)
                //assert(countryFlagButton.exists)
                //let countryImage = countryFlagButton.otherElements.images[countryCode]
                //assert(countryImage.exists)
                
                // state should be visible for US/Canada/Brazil
                let stateIsVisible = initialData.fullBilling && BSCountryManager.getInstance().countryHasStates(countryCode: countryCode)
                var expectedStateValue = ""
                if let stateName = bsCountryManager.getStateName(countryCode : countryCode, stateCode: billingDetails.state ?? "") {
                    expectedStateValue = stateName
                }
                checkInput(input: stateInput, expectedExists: stateIsVisible, expectedValue: expectedStateValue, expectedLabelText: "State")
            }

        }
    }
    
    func setFieldValues(billingDetails: BSBillingAddressDetails) {
    
        setInputValue(input: nameInput, value: billingDetails.name ?? "")
        setInputValue(input: emailInput, value: billingDetails.email ?? "")
        setInputValue(input: zipInput, value: billingDetails.zip ?? "")
        setInputValue(input: cityInput, value: billingDetails.city ?? "")
        setInputValue(input: streetInput, value: billingDetails.address ?? "")

        if let countryCode = billingDetails.country {
            setCountry(countryCode: countryCode)
            if let stateCode = billingDetails.state {
                setState(countryCode: countryCode, stateCode: stateCode)
            }
        }
    }
    
    func setCountry(countryCode: String) {
        
        if let countryName = bsCountryManager.getCountryName(countryCode: countryCode) {
            let countryImageButton = getInputImageButtonElement(nameInput)
            countryImageButton.tap()
            app.searchFields["Search"].tap()
            app.searchFields["Search"].typeText(countryName)
            app.tables.staticTexts[countryName].tap()
        }
    }
    
    func setState(countryCode: String, stateCode: String) {
        
        if let stateName = bsCountryManager.getStateName(countryCode : countryCode, stateCode: stateCode) {
            let stateButton = getInputCoverButtonElement(stateInput)
            stateButton.tap()
            app.searchFields["Search"].tap()
            app.searchFields["Search"].typeText(stateName)
            app.tables.staticTexts[stateName].tap()
        }
    }
    
    func setInputValue(input: XCUIElement, value: String) {
        
        //sleep(1)
        let textField = getInputFieldElement(input)
        if textField.exists {
            textField.tap()
            textField.typeText(value)
        }
        //sleep(1)
    }
    
    func checkInput(input: XCUIElement, expectedExists: Bool, expectedValue: String, expectedLabelText: String) {
        
        let textField = getInputFieldElement(input)
        assert(textField.exists == expectedExists)
        
        if textField.exists {
            let value = textField.value as! String
            assert(expectedValue == value)

            let label = getInputLabelElement(input)
            let labelText: String = label.label //label.value as! String
            assert(labelText == expectedLabelText)
        }
    }
}
