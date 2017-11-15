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


    //------------------------------------------------------
    // MARK: submitCcDetails
    //------------------------------------------------------
    
    func testSubmitCCDetailsSuccess() {
 
        let ccn = "4111 1111 1111 1111"
        let cvv = "111"
        let exp = "10/2020"

        let semaphore = DispatchSemaphore(value: 0)
        createToken(completion: { token, error in
            
            BlueSnapSDK.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, purchaseDetails: nil, completion: { (result, error) in
                
                XCTAssert(error == nil, "error: \(error)")
                let ccType = result.ccType
                let last4 = result.last4Digits
                let country = result.ccIssuingCountry
                NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
                semaphore.signal()
            })
        })
        semaphore.wait()
    }
    
    func testSubmitCCDetailsError() {
        
        submitCCDetailsExpectError(ccn: "4111", cvv: "111", exp: "12/2020", expectedError: BSErrors.invalidCcNumber)
        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "1", exp: "12/2020", expectedError: BSErrors.invalidCvv)
        submitCCDetailsExpectError(ccn: "4111111111111111", cvv: "111", exp: "22/2020", expectedError: BSErrors.invalidExpDate)
    }
    
    func testSubmitEmptyCCDetailsError() {
        
        submitCCDetailsExpectError(ccn: "", cvv: "", exp: "", expectedError: BSErrors.invalidCcNumber)
    }
    
    
    //------------------------------------------------------
    // MARK: getCurrencyRates
    //------------------------------------------------------

    // test get currencies with a valid token
    func testGetTokenAndCurrencies() {
        
        let semaphore = DispatchSemaphore(value: 0)
        createToken(completion: { token, error in
            
            BlueSnapSDK.initBluesnap(bsToken: token, generateTokenFunc: {_ in }, initKount: false, fraudSessionId: nil, applePayMerchantIdentifier: nil, merchantStoreCurrency: "USD", completion: { errors in
                
                XCTAssertNil(errors, "Got errors from initBluesnap")
                
                let bsCurrencies = BlueSnapSDK.getCurrencyRates()
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
    
        
    //------------------------------------------------------
    // MARK: private functions
    //------------------------------------------------------
    
    private func submitCCDetailsExpectError(ccn: String!, cvv: String!, exp: String!, expectedError: BSErrors) {
        
        let semaphore = DispatchSemaphore(value: 0)
        createToken(completion: { token, error in
            
            BlueSnapSDK.submitCcDetails(ccNumber: ccn, expDate: exp, cvv: cvv, purchaseDetails: nil, completion: {
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
        
        BlueSnapSDK.createSandboxTestToken(completion: { bsToken, error in
            
            XCTAssertNil(error)
            XCTAssertNotNil(bsToken)
            completion(bsToken, error)
        })
    }
    
}
