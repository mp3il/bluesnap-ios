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
    private var tokenWasRecreated = false

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("----------------------------------------------------")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //------------------------------------------------------
    // MARK: Is Token Expired
    //------------------------------------------------------
    func testIsTokenExpiredExpectsFalse() {
        
        let semaphore = DispatchSemaphore(value: 0)
        createToken(completion: { token, error in
        
            NSLog("testIsTokenExpiredExpectsFalse; token str=\(token!.getTokenStr())")

            let result = BSApiCaller.isTokenExpired(bsToken: token, completion: { isExpired in
                assert(isExpired == false)
                semaphore.signal()
            })
        })
        semaphore.wait()
    }
    
    func testIsTokenExpiredExpectsTrue() {
        
        let expiredToken = "fcebc8db0bcda5f8a7a5002ca1395e1106ea668f21200d98011c12e69dd6bceb_"
        let token = BSToken(tokenStr: expiredToken, isProduction: false)
        BlueSnapSDK.setBsToken(bsToken: token)
        
        let semaphore = DispatchSemaphore(value: 0)
        let result = BSApiCaller.isTokenExpired(bsToken: token, completion: { isExpired in
            assert(isExpired == true)
            semaphore.signal()
        })
        semaphore.wait()
    }
    
    //------------------------------------------------------
    // MARK: PayPal
    //------------------------------------------------------
    
    func testGetPayPalToken() {
        
        
        let initialData = BSInitialData()
        initialData.priceDetails = BSPriceDetails(amount: 30, taxAmount: 0, currency: "USD")
        let paymentRequest: BSPayPalPaymentRequest = BSPayPalPaymentRequest(initialData: initialData)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        createToken(completion: { token, error in
            BSApiManager.createPayPalToken(paymentRequest: paymentRequest, withShipping: false, completion: { resultToken, resultError in
                
                XCTAssertNil(resultError)
                NSLog("*** testGetPayPalToken; Test result: resultToken=\(resultToken ?? ""), resultError= \(resultError)")
                semaphore.signal()
            })
        })
        
        semaphore.wait()
    }
    
    func testGetPayPalTokenWithInvalidTokenNoRegeneration() {
        
        createExpiredTokenNoRegeneration()
        let initialData = BSInitialData()
        initialData.priceDetails = BSPriceDetails(amount: 30, taxAmount: 0, currency: "USD")
        let paymentRequest: BSPayPalPaymentRequest = BSPayPalPaymentRequest(initialData: initialData)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        BSApiManager.createPayPalToken(paymentRequest: paymentRequest, withShipping: false, completion: { resultToken, resultError in
            
            XCTAssertNotNil(resultError)
            assert(resultError == BSErrors.unAuthorised)
            NSLog("*** testGetPayPalTokenWithInvalidTokenNoRegeneration; Test result: resultToken=\(resultToken ?? ""), resultError= \(resultError)")
            
            assert(self.tokenWasRecreated == false)
            semaphore.signal()
        })
        
        semaphore.wait()
    }
    
    func testGetPayPalTokenWithExpiredToken() {
        
        createExpiredTokenWithRegeneration()
        
        let initialData = BSInitialData()
        initialData.priceDetails = BSPriceDetails(amount: 30, taxAmount: 0, currency: "USD")
        let paymentRequest: BSPayPalPaymentRequest = BSPayPalPaymentRequest(initialData: initialData)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        BSApiManager.createPayPalToken(paymentRequest: paymentRequest, withShipping: false,completion: { resultToken, resultError in
            
            XCTAssertNil(resultError)
            NSLog("*** testGetPayPalTokenWithExpiredToken; Test result: resultToken=\(resultToken ?? ""), resultError= \(resultError)")
            
            assert(self.tokenWasRecreated == true)
            semaphore.signal()
        })
        
        semaphore.wait()
    }

    
    //------------------------------------------------------
    // MARK: Supported Payment Methods
    //------------------------------------------------------
    
    func testGetSupportedPaymentMethods() {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        createToken(completion: { token, error in
            BSApiManager.getSupportedPaymentMethods(completion: { resultPaymentMethods, resultError in
                
                XCTAssertNil(resultError)
                NSLog("*** testGetSupportedPaymentMethods; Test result: resultPaymentMethods=\(resultPaymentMethods ?? []), resultError= \(resultError)")
                
                // check that CC and ApplePay are supported
                let ccIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.CreditCard, supportedPaymentMethods: resultPaymentMethods)
                XCTAssertTrue(ccIsSupported)
                let applePayIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.ApplePay, supportedPaymentMethods: resultPaymentMethods)
                XCTAssertTrue(applePayIsSupported)
                let payPalIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.PayPal, supportedPaymentMethods: resultPaymentMethods)
                XCTAssertTrue(payPalIsSupported)

                semaphore.signal()
            })
        })
        
        semaphore.wait()
    }
    
    func testGetSupportedPaymentMethodsWithExpiredToken() {
        
        createExpiredTokenWithRegeneration()

        let semaphore = DispatchSemaphore(value: 0)
        
        BSApiManager.getSupportedPaymentMethods(completion: { resultPaymentMethods, resultError in
            
            XCTAssertNil(resultError)
            NSLog("*** testGetSupportedPaymentMethodsWithExpiredToken; Test result: resultPaymentMethods=\(resultPaymentMethods ?? []), resultError= \(resultError)")
            
            // check that CC and ApplePay are supported
            let ccIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.CreditCard, supportedPaymentMethods: resultPaymentMethods)
            XCTAssertTrue(ccIsSupported)
            let applePayIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.ApplePay, supportedPaymentMethods: resultPaymentMethods)
            XCTAssertTrue(applePayIsSupported)
            let payPalIsSupported = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.PayPal, supportedPaymentMethods: resultPaymentMethods)
            XCTAssertTrue(payPalIsSupported)
            
            semaphore.signal()
        })
        
        semaphore.wait()
    }

    
    //------------------------------------------------------
    // MARK: Currency rates
    //------------------------------------------------------

    // test get currencies with a valid token
    func testGetTokenAndCurrencies() {
        
        let semaphore = DispatchSemaphore(value: 0)
        createToken(completion: { token, error in
        
            BSApiManager.getCurrencyRates(completion: { bsCurrencies, errors in
                
                XCTAssertNil(errors, "Got errors while trying to get currencies")
                XCTAssertNotNil(bsCurrencies, "Failed to get currencies")
                
                let gbpCurrency : BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
                XCTAssertNotNil(gbpCurrency)
                NSLog("testGetTokenAndCurrencies; GBP currency name is: \(gbpCurrency.name), its rate is \(gbpCurrency.rate)")
                
                let eurCurrencyRate : Double! = bsCurrencies?.getCurrencyRateByCurrencyCode(code: "EUR")
                XCTAssertNotNil(eurCurrencyRate)
                NSLog("testGetTokenAndCurrencies; EUR currency rate is: \(eurCurrencyRate)")
                
                semaphore.signal()
            })
        })
        semaphore.wait()
    }
    
    // test get currencies with an expired valid token and no proper re-generation
    func testGetCurrenciesWithExpiredTokenNoRegeneration() {
        
        createExpiredTokenNoRegeneration()
        
        let semaphore = DispatchSemaphore(value: 0)
        BSApiManager.getCurrencyRates(completion: { bsCurrencies, errors in
            
            XCTAssert(errors == BSErrors.unAuthorised)
            semaphore.signal()
        })
        semaphore.wait()
    }
    
    // test get currencies with an expired valid token and a proper re-generation
    func testGetCurrenciesWithExpiredTokenWithRegeneration() {
        
        createExpiredTokenWithRegeneration()
        
        let semaphore = DispatchSemaphore(value: 0)
        BSApiManager.getCurrencyRates(completion: { bsCurrencies, errors in
            
            XCTAssertNil(errors, "Got errors while trying to get currencies")
            XCTAssertNotNil(bsCurrencies, "Failed to get currencies")
            
            let gbpCurrency : BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
            XCTAssertNotNil(gbpCurrency)
            NSLog("testGetCurrenciesWithExpiredTokenWithRegeneration; GBP currency name is: \(gbpCurrency.name), its rate is \(gbpCurrency.rate)")
            
            let eurCurrencyRate : Double! = bsCurrencies?.getCurrencyRateByCurrencyCode(code: "EUR")
            XCTAssertNotNil(eurCurrencyRate)
            NSLog("testGetCurrenciesWithExpiredTokenWithRegeneration; EUR currency rate is: \(eurCurrencyRate)")
            
            XCTAssert(self.tokenWasRecreated == true)
            semaphore.signal()
        })
        semaphore.wait()
    }
    

    //------------------------------------------------------
    // MARK: Submit CC details
    //------------------------------------------------------
    
    func testSubmitCCDetailsSuccess() {
        
        let ccn = "4111 1111 1111 1111"
        let cvv = "111"
        let exp = "10/2020"

        let semaphore = DispatchSemaphore(value: 0)
        createToken(completion: { token, error in
            
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
                semaphore.signal()
            })
        })
        semaphore.wait()
    }
    
    func testSubmitCCDetailsSuccessWithExpiredToken() {
        
        createExpiredTokenWithRegeneration()

        let ccn = "4111 1111 1111 1111"
        let cvv = "111"
        let exp = "10/2020"
        
        let semaphore = DispatchSemaphore(value: 0)
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
            XCTAssert(self.tokenWasRecreated == true)
            semaphore.signal()
        })
        semaphore.wait()
    }

    func testSubmitCCDetailsErrorInvalidCcNumber() {
        
        submitCCDetailsExpectError(ccn: "4111", cvv: "111", exp: "12/2020", expectedError: BSErrors.invalidCcNumber)
    }
    
    func testSubmitCCDetailsErrorEmptyCcNumber() {
        
        submitCCDetailsExpectError(ccn: "", cvv: "111", exp: "12/2020", expectedError: BSErrors.invalidCcNumber)
    }
    
    func testSubmitCCDetailsErrorInvalidCvv() {
        
        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "3", exp: "12/2020", expectedError: BSErrors.invalidCvv)
    }
    
    func testSubmitCCDetailsErrorInvalidExp() {
        
        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "111", exp: "1220", expectedError: BSErrors.invalidExpDate)
    }

    
    //------------------------------------------------------
    // MARK: Submit CCN
    //------------------------------------------------------

    func testSubmitCCNSuccess() {

        let ccn = "4111 1111 1111 1111"
        
        let semaphore = DispatchSemaphore(value: 0)
        createToken(completion: { token, error in
            
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
                semaphore.signal()
            })
        })
        semaphore.wait()
    }

    func testSubmitCCNError() {

        let ccn = "4111"
        let semaphore = DispatchSemaphore(value: 0)
        createToken(completion: { token, error in
            BSApiManager.submitCcn(ccNumber: ccn, completion: {
                (result, error) in
                XCTAssert(error == BSErrors.invalidCcNumber, "error: \(error) should have been BSErrors.invalidCcNumber")
                semaphore.signal()
            })
        })
        semaphore.wait()
   }

    func testSubmitEmptyCCNError() {

        let ccn = ""
        let semaphore = DispatchSemaphore(value: 0)
        createToken(completion: { token, error in
            BSApiManager.submitCcn(ccNumber: ccn, completion: {
                (result, error) in
                XCTAssert(error == BSErrors.invalidCcNumber, "error: \(error) should have been BSErrors.invalidCcNumber")
                semaphore.signal()
            })
        })
        semaphore.wait()
    }

    //------------------------------------------------------
    // MARK: BlueSnap Token
    //------------------------------------------------------


//    func testGetTokenWithBadCredentials() {
//
//        listenForBsTokenExpiration(expected: false)
//        do {
//            let _ = try BSApiManager.createBSToken(domain: BSApiManager.BS_SANDBOX_DOMAIN, user: "dummy", password: "dummypass")
//            print("We should have crashed here")
//            fatalError()
//        } catch let error as BSErrors {
//            if error == BSErrors.invalidInput {
//                print("Got the correct error")
//            } else {
//                print("Got wrong error \(error.localizedDescription)")
//                fatalError()
//            }
//        } catch let error {
//            print("Got wrong error \(error.localizedDescription)")
//            fatalError()
//        }
//    }


    //------------------------------------------------------
    // MARK: private functions
    //------------------------------------------------------

    private func submitCCDetailsExpectError(ccn: String!, cvv: String!, exp: String!, expectedError: BSErrors) {

        let semaphore = DispatchSemaphore(value: 0)
        createToken(completion: { token, error in
            
            BSApiManager.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, completion: {
                (result, error) in
                
                if let error = error {
                    XCTAssertEqual(error, expectedError)
                    NSLog("Got the right error!")
                } else {
                    XCTAssert(false, "Should have thrown error")
                }
                semaphore.signal()
            })
        })
        semaphore.wait()
    }
    

    /**
    Create token in async manner
     */
    func createToken(completion: @escaping (BSToken?, BSErrors?) -> Void) {
        
        BSApiManager.createSandboxBSToken(completion: { bsToken, error in
            
            XCTAssertNil(error)
            XCTAssertNotNil(bsToken)
            BlueSnapSDK.setBsToken(bsToken: bsToken)
            completion(bsToken, error)
        })
    }
    
    func createExpiredTokenNoRegeneration() {
        
        let expiredToken = "fcebc8db0bcda5f8a7a5002ca1395e1106ea668f21200d98011c12e69dd6bceb_"
        BlueSnapSDK.setBsToken(bsToken: BSToken(tokenStr: expiredToken, isProduction: false))
        BSApiManager.setGenerateBsTokenFunc(generateTokenFunc: { completion in
            NSLog("*** Not recreating token!!!")
            completion(nil, nil)
        })
    }
    
    func createExpiredTokenWithRegeneration() {
        tokenWasRecreated = false
        let expiredToken = "fcebc8db0bcda5f8a7a5002ca1395e1106ea668f21200d98011c12e69dd6bceb_"
        BSApiManager.setBsToken(bsToken: BSToken(tokenStr: expiredToken, isProduction: false))
        BSApiManager.setGenerateBsTokenFunc(generateTokenFunc: { completion in
            NSLog("*** Recreating token!!!")
            self.tokenWasRecreated = true
            BSApiManager.createSandboxBSToken(completion: completion)
        })
    }
}
