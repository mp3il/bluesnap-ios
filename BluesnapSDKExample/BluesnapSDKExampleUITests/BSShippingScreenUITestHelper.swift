//
//  BSShippingScreenUITestHelper.swift
//  BluesnapSDKExample
//
//  Created by Shevie Chen on 12/09/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import XCTest
import BluesnapSDK

class BSShippingScreenUITestHelper {
    
    var app: XCUIApplication!
    var nameInput : XCUIElement!
    var phoneInput : XCUIElement!
    var zipInput : XCUIElement!
    var cityInput : XCUIElement!
    var streetInput : XCUIElement!
    var stateInput : XCUIElement!
    var keyboardIsHidden = true

    let bsCountryManager = BSCountryManager.getInstance()
    
    init(app: XCUIApplication!, keyboardIsHidden : Bool) {
        self.app = app
        let elementsQuery = app.scrollViews.otherElements
        nameInput = elementsQuery.element(matching: .any, identifier: "ShippingName")
        phoneInput = elementsQuery.element(matching: .any, identifier: "ShippingPhone")
        zipInput = elementsQuery.element(matching: .any, identifier: "ShippingZip")
        cityInput = elementsQuery.element(matching: .any, identifier: "ShippingCity")
        streetInput = elementsQuery.element(matching: .any, identifier: "ShippingStreet")
        stateInput = elementsQuery.element(matching: .any, identifier: "ShippingState")
        self.keyboardIsHidden = keyboardIsHidden
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

    func closeKeyboard() {
        if (!keyboardIsHidden) {
            nameInput.tap()
            if (app.keyboards.count > 0) {
                let doneBtn = app.keyboards.buttons["Done"]
                if doneBtn.exists && doneBtn.isHittable {
                    doneBtn.tap()
                }
            }
        }
    }

    // check visibility of inputs - make sure fields are shown according to configuration
    func checkInputs(sdkRequest: BSSdkRequest) {
        
        if let shippingDetails = sdkRequest.shippingDetails {
            checkInput(input: nameInput, expectedExists: true, expectedValue: shippingDetails.name ?? "", expectedLabelText: "Name")
            checkInput(input: phoneInput, expectedExists: true, expectedValue: shippingDetails.phone ?? "", expectedLabelText: "Phone")
            checkInput(input: cityInput, expectedExists: true, expectedValue: shippingDetails.city ?? "", expectedLabelText: "City")
            checkInput(input: streetInput, expectedExists: true, expectedValue: shippingDetails.address ?? "", expectedLabelText: "Street")
            // zip should be hidden only for country that does not have zip; label also changes according to country
            let expectedZipLabelText = (shippingDetails.country ?? "US" == "US") ? "Shipping Zip" : "Postal Code"
            let zipShouldBeVisible = !BSCountryManager.getInstance().countryHasNoZip(countryCode: shippingDetails.country ?? "")
            checkInput(input: zipInput, expectedExists: zipShouldBeVisible, expectedValue: shippingDetails.zip ?? "", expectedLabelText: expectedZipLabelText)
            if let countryCode = shippingDetails.country {
                // check country image - this does not work, don't know how to access the image
                
                // state should be visible for US/Canada/Brazil
                let stateIsVisible = BSCountryManager.getInstance().countryHasStates(countryCode: countryCode)
                var expectedStateValue = ""
                if let stateName = bsCountryManager.getStateName(countryCode : countryCode, stateCode: shippingDetails.state ?? "") {
                    expectedStateValue = stateName
                }
                checkInput(input: stateInput, expectedExists: stateIsVisible, expectedValue: expectedStateValue, expectedLabelText: "State")
            }
        }
    }

    func setFieldValues(shippingDetails: BSShippingAddressDetails, sdkRequest: BSSdkRequest) {
        
        setInputValue(input: nameInput, value: shippingDetails.name ?? "")
        setInputValue(input: phoneInput, value: shippingDetails.phone ?? "")
        setInputValue(input: zipInput, value: shippingDetails.zip ?? "")
        setInputValue(input: cityInput, value: shippingDetails.city ?? "")
        setInputValue(input: streetInput, value: shippingDetails.address ?? "")
        if let countryCode = shippingDetails.country {
            setCountry(countryCode: countryCode)
            if let stateCode = shippingDetails.state {
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
        
        let textField = getInputFieldElement(input)
        if textField.exists {
            let oldValue = textField.value as! String
            if oldValue != value {
                textField.tap()
                if oldValue.count > 0 {
                    let deleteString = oldValue.map { _ in "\u{8}" }.joined(separator: "")
                    textField.typeText(deleteString)
                }
                textField.typeText(value)
            }
        }
    }
    
    func checkInput(input: XCUIElement, expectedExists: Bool, expectedValue: String, expectedLabelText: String) {
        
        let textField = getInputFieldElement(input)
        assert(textField.exists == expectedExists)
        
        if textField.exists {
            let value = textField.value as! String
            assert(expectedValue == value)
            
            let label = getInputLabelElement(input)
            let labelText: String = label.label
            assert(labelText == expectedLabelText)
        }
    }

}
