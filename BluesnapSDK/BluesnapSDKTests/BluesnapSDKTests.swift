//
//  BluesnapSDKTests.swift
//  BluesnapSDKTests
//
//  Created by Oz on 26/03/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BluesnapSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetPayPalToken() {
        
        createToken()
        let paymentRequest: BSPaymentRequest = BSPaymentRequest()
        paymentRequest.amount = 30
        paymentRequest.currency = "USD"
        
        let semaphore = DispatchSemaphore(value: 0)

        BSApiManager.createPayPalToken(paymentRequest: paymentRequest, completion: { resultToken, resultError in
            
            print("*** Test result: resultToken=\(resultToken ?? ""), resultError= \(resultError)")
            semaphore.signal()
        })
        
        semaphore.wait()
    }
    
    func testGetSupportedPaymentMethods() {
    
        createToken()
        
        do {
            let supportedPaymentMethods = try BSApiManager.getSupportedPaymentMethods()
            print(supportedPaymentMethods)
            // again, see we don't go to the server
            let supportedPaymentMethods2 = try BSApiManager.getSupportedPaymentMethods()
            print(supportedPaymentMethods2)
            // check that CC and ApplePay are supported
            let ccIsSupported = BSApiManager.isSupportedPaymentMethod(BSPaymentType.CreditCard)
            XCTAssertTrue(ccIsSupported)
            let applePayIsSupported = BSApiManager.isSupportedPaymentMethod(BSPaymentType.ApplePay)
            XCTAssertTrue(applePayIsSupported)
            let payPalIsSupported = BSApiManager.isSupportedPaymentMethod(BSPaymentType.PayPal)
            XCTAssertTrue(payPalIsSupported)
        } catch let error {
            print("Got wrong error \(error.localizedDescription)")
            fatalError()
        }
    }
    
    func testGetTokenAndCurrencies() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        createToken()
        
        let bsCurrencies = getCurrencies()
        XCTAssertNotNil(bsCurrencies, "Failed to get currencies")
        
        let gbpCurrency : BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
        NSLog("GBP currency name is: \(gbpCurrency.name), its rate is \(gbpCurrency.rate)")
            
        let eurCurrencyRate : Double! = bsCurrencies?.getCurrencyRateByCurrencyCode(code: "EUR")
        NSLog("EUR currency rate is: \(eurCurrencyRate)")
    }

    func testSubmitCCDetailsSuccess() {
 
        createToken()

        let ccn = "4111 1111 1111 1111"
        let cvv = "111"
        let exp = "10/2020"
        
        BSApiManager.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, completion: {
            (result, error) in
            
            XCTAssert(error == nil, "error: \(error)")
            let ccType = result!.ccType
            let last4 = result!.last4Digits
            let country = result!.ccIssuingCountry
            NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
       })
    }
    
    func testSubmitCCDetailsError() {
        
        createToken()
        
        submitCCDetailsExpectError(ccn: "4111", cvv: "111", exp: "12/2020", expectedError: BSErrors.invalidCcNumber)
        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "1", exp: "12/2020", expectedError: BSErrors.invalidCvv)
        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "111", exp: "22/2020", expectedError: BSErrors.invalidExpDate)
    }
    
    func testSubmitEmptyCCDetailsError() {
        
        createToken()

        submitCCDetailsExpectError(ccn: "", cvv: "", exp: "", expectedError: BSErrors.invalidCcNumber)
    }
    
    
    func testGetTokenWithBadCredentials() {
        
        do {
            let _ = try BSApiManager.createBSToken(domain: BSApiManager.BS_SANDBOX_DOMAIN, user: "dummy", password: "dummypass")
            print("We should have crashed here")
            fatalError()
        } catch let error as BSErrors {
            if error == BSErrors.invalidInput {
                print("Got the correct error")
            } else {
                print("Got wrong error \(error.localizedDescription)")
                fatalError()
            }
        } catch let error {
            print("Got wrong error \(error.localizedDescription)")
            fatalError()
        }
    }

   
    // MARK: proivate functions
    
    private func submitCCDetailsExpectError(ccn: String!, cvv: String!, exp: String!, expectedError: BSErrors) {
        
        BSApiManager.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, completion: {
            (result, error) in
            
            if let error = error {
                XCTAssertEqual(error, expectedError)
                NSLog("Got the right error!")
            } else {
                XCTAssert(false, "Should have thrown error")
            }
        })
    }

    private func createToken() {
        
        do {
            let token = try BSApiManager.createSandboxBSToken()
            NSLog("Token: \(token?.tokenStr) @ \(token?.serverUrl)")
            BSApiManager.setBsToken(bsToken: token)
        } catch let error {
            print("Got error \(error.localizedDescription)")
            fatalError()
        }
    }
    
    private func getCurrencies() -> BSCurrencies! {
        
        do {
            let bsCurrencies = try BSApiManager.getCurrencyRates()
            return bsCurrencies!
        } catch let error {
            print("Got wrong error \(error.localizedDescription)")
            fatalError()
        }
    }
    
}
