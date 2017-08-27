//
//  BSApiManagerTests.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 20/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
@testable import BluesnapSDK

class BSApiManagerTests: XCTestCase {
    
    private var tokenExpiredExpectation : XCTestExpectation?

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("----------------------------------------------------")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        stopListeningForBsTokenExpiration();
        super.tearDown()
    }
    
    //------------------------------------------------------
    // MARK: PayPal
    //------------------------------------------------------
    
    func testGetPayPalToken() {
        
        listenForBsTokenExpiration(expected: false)
        createToken()
        
        let initialData = BSInitialData()
        initialData.priceDetails = BSPriceDetails(amount: 30, taxAmount: 0, currency: "USD")
        let paymentRequest: BSPayPalPaymentRequest = BSPayPalPaymentRequest(initialData: initialData)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        BSApiManager.createPayPalToken(paymentRequest: paymentRequest, withShipping: false,completion: { resultToken, resultError in
            
            XCTAssertNil(resultError)
            print("*** Test result: resultToken=\(resultToken ?? ""), resultError= \(resultError)")
            semaphore.signal()
        })
        
        semaphore.wait()
    }
    
    func testGetPayPalTokenWithInvalidToken() {
        
        listenForBsTokenExpiration(expected: false)
        let bsToken = getInvalidToken()
        BSApiManager.setBsToken(bsToken: bsToken)
        
        let initialData = BSInitialData()
        initialData.priceDetails = BSPriceDetails(amount: 30, taxAmount: 0, currency: "USD")
        let paymentRequest: BSPayPalPaymentRequest = BSPayPalPaymentRequest(initialData: initialData)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        BSApiManager.createPayPalToken(paymentRequest: paymentRequest, withShipping: false,completion: { resultToken, resultError in
            
            XCTAssertNotNil(resultError)
            print("*** Test result: resultToken=\(resultToken ?? ""), resultError= \(resultError)")
            semaphore.signal()
        })
        
        semaphore.wait()
    }
    
    func testGetPayPalTokenWithExpiredToken() {
        
        listenForBsTokenExpiration(expected: true)
        let bsToken = getExpiredToken()
        BSApiManager.setBsToken(bsToken: bsToken)
        
        let initialData = BSInitialData()
        initialData.priceDetails = BSPriceDetails(amount: 30, taxAmount: 0, currency: "USD")
        let paymentRequest: BSPayPalPaymentRequest = BSPayPalPaymentRequest(initialData: initialData)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        BSApiManager.createPayPalToken(paymentRequest: paymentRequest, withShipping: false,completion: { resultToken, resultError in
            
            XCTAssertNotNil(resultError)
            print("*** Test result: resultToken=\(resultToken ?? ""), resultError= \(resultError)")
            semaphore.signal()
        })
        
        semaphore.wait()
        self.waitForExpiredTokenEvent()
    }

    
    //------------------------------------------------------
    // MARK: Supported Payment Methods
    //------------------------------------------------------

    func testGetSupportedPaymentMethods() {
        
        listenForBsTokenExpiration(expected: false)
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
    
    //------------------------------------------------------
    // MARK: Currency rates
    //------------------------------------------------------

    func testGetTokenAndCurrencies() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        listenForBsTokenExpiration(expected: false)
        createToken()
        
        let bsCurrencies = getCurrencies()
        XCTAssertNotNil(bsCurrencies, "Failed to get currencies")
        
        let gbpCurrency : BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
        NSLog("GBP currency name is: \(gbpCurrency.name), its rate is \(gbpCurrency.rate)")
        
        let eurCurrencyRate : Double! = bsCurrencies?.getCurrencyRateByCurrencyCode(code: "EUR")
        NSLog("EUR currency rate is: \(eurCurrencyRate)")
    }
    
    //------------------------------------------------------
    // MARK: Submit CC details
    //------------------------------------------------------
    
    func testSubmitCCDetailsSuccess() {
        
        listenForBsTokenExpiration(expected: false)
        createToken()
        
        let ccn = "4111 1111 1111 1111"
        let cvv = "111"
        let exp = "10/2020"
        
        BSApiManager.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, completion: {
            (result, error) in
            
            XCTAssert(error == nil, "error: \(error)")
            let ccType = result.ccType
            let last4 = result.last4Digits
            let country = result.ccIssuingCountry
            NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
            assert(last4 == "1111", "last4 should be 1111")
            assert(ccType == "VISA", "CC Type should be VISA")
            assert(country == "US", "country should be US")
        })
    }
    
    func testSubmitCCDetailsError() {
        
        listenForBsTokenExpiration(expected: false)
        createToken()
        
        submitCCDetailsExpectError(ccn: "4111", cvv: "111", exp: "12/2020", expectedError: BSErrors.invalidCcNumber)
        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "1", exp: "12/2020", expectedError: BSErrors.invalidCvv)
        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "111", exp: "22/2020", expectedError: BSErrors.invalidExpDate)
        submitCCDetailsExpectError(ccn: "", cvv: "", exp: "", expectedError: BSErrors.invalidCcNumber)
    }
    
    //------------------------------------------------------
    // MARK: Submit CCN
    //------------------------------------------------------
    
    func testSubmitCCNSuccess() {
        
        listenForBsTokenExpiration(expected: false)
        createToken()
        
        let ccn = "4111 1111 1111 1111"
        
        BSApiManager.submitCcn(ccNumber: ccn, completion: {
            (result, error) in
            
            XCTAssert(error == nil, "error: \(error)")
            let ccType = result.ccType
            let last4 = result.last4Digits
            let country = result.ccIssuingCountry
            NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
            assert(last4 == "1111", "last4 should be 1111")
            assert(ccType == "VISA", "CC Type should be VISA")
            assert(country == "US", "country should be US")
        })
    }
    
    func testSubmitCCNError() {
        
        listenForBsTokenExpiration(expected: false)
        createToken()
        
        let ccn = "4111"
        BSApiManager.submitCcn(ccNumber: ccn, completion: {
            (result, error) in
            XCTAssert(error == BSErrors.invalidCcNumber, "error: \(error) should have been BSErrors.invalidCcNumber")
        })
    }
    
    func testSubmitEmptyCCNError() {
        
        listenForBsTokenExpiration(expected: false)
        createToken()
        
        let ccn = ""
        BSApiManager.submitCcn(ccNumber: ccn, completion: {
            (result, error) in
            XCTAssert(error == BSErrors.invalidCcNumber, "error: \(error) should have been BSErrors.invalidCcNumber")
        })
    }
    
    //------------------------------------------------------
    // MARK: BlueSnap Token
    //------------------------------------------------------

    
    func testGetTokenWithBadCredentials() {
        
        listenForBsTokenExpiration(expected: false)
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
    
    
    //------------------------------------------------------
    // MARK: private functions
    //------------------------------------------------------
    
    private func submitCCDetailsExpectError(ccn: String!, cvv: String!, exp: String!, expectedError: BSErrors) {
        
        BSApiManager.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, completion: {
            (result, error) in
            
            if let error = error {
                XCTAssertEqual(error, expectedError)
                NSLog("Got the right error!")
            } else {
                XCTAssert(false, "Should have thrown error")
            }
            self.waitForExpiredTokenEvent()
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
    
    private func getExpiredToken() -> BSToken {
        return BSToken(tokenStr: "5e2e3f50e287eab0ba20dc1712cf0f64589c585724b99c87693a3326e28b1a3f_", isProduction: false)
    }
    
    private func getInvalidToken() -> BSToken {
        return BSToken(tokenStr: "aaaa", isProduction: false)
    }
    
    /**
     Add observer to the token expired event sent by BlueSnap SDK.
     */
    func listenForBsTokenExpiration(expected: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(bsTokenExpired), name: Notification.Name.bsTokenExpirationNotification, object: nil)
        if expected {
            tokenExpiredExpectation = expectation(description: "Token Expired expectation")
        } else {
            tokenExpiredExpectation = nil
        }
    }
    
    /**
     Remove observer to the token expired event sent by BlueSnap SDK.
     */
    private func stopListeningForBsTokenExpiration() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     Called by the observer to the token expired event sent by BlueSnap SDK.
     Here we fullfil the expectation if there is one, or fail in case this was not supposed to happen.
     */
    func bsTokenExpired() {
        
        NSLog("Got BS token expiration notification!")
        if let tokenExpiredExpectation = tokenExpiredExpectation {
            tokenExpiredExpectation.fulfill()
        } else {
            assertionFailure("Got unexpected token expiration")
        }
    }

    private func waitForExpiredTokenEvent() {
        if tokenExpiredExpectation != nil {
            waitForExpectations(timeout: 0.1, handler: {
                error in
                assert(error == nil, "No error should happen here")
            })
        }
    }

}
