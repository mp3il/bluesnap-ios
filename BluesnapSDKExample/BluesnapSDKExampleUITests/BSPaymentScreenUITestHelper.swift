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
    func checkVisibilityOfInputs(initialData: BSInitialData) {
        
        checkInput(input: nameInput, expectedExists: true, expectedValue: "", expectedLabelText: "Name:")
        checkInput(input: emailInput, expectedExists: initialData.withEmail, expectedValue: "", expectedLabelText: "Email:")
        // zip should be hidden only for country that does not have zip, meanwhile we ignore; label also changes according to country
        checkInput(input: zipInput, expectedExists: true, expectedValue: "", expectedLabelText: "Zip Code:")
        checkInput(input: cityInput, expectedExists: initialData.fullBilling, expectedValue: "", expectedLabelText: "City:")
        checkInput(input: streetInput, expectedExists: initialData.fullBilling, expectedValue: "", expectedLabelText: "Street:")
        // state should be visible for US/Canada/Brazil, meanwhile we say true
        checkInput(input: stateInput, expectedExists: initialData.fullBilling, expectedValue: "", expectedLabelText: "State:")
    }

    func checkInput(input: XCUIElement, expectedExists: Bool, expectedValue: String, expectedLabelText: String) {
        
        let textField = getInputFieldElement(input)
        assert(textField.exists == expectedExists)
        
        if textField.exists {
            let value = textField.value as! String
            assert(expectedValue == value)

            let label = getInputLabelElement(input)
            let labelText = label.value as! String
            assert(labelText == expectedLabelText)
        }
    }
}
