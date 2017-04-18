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
    
 /*   func testGetTokenAndCurrencies() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let token = getToken()
        XCTAssertNotNil(token, "Failed to get token")
        
        let bsCurrencies = getCurrencies(token: token)
        XCTAssertNotNil(bsCurrencies, "Failed to get currencies")
        
        let gbpCurrency : BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
        print("GBP currency name is: \(gbpCurrency.name), its rate is \(gbpCurrency.rate)")
            
        let eurCurrencyRate : Double! = bsCurrencies?.getCurrencyRateByCurrencyCode(code: "EUR")
        print("EUR currency rate is: \(eurCurrencyRate)")
    }
    
    func testSubmitCCDetailsSuccess() {
 
        let token = getToken()
        XCTAssertNotNil(token, "Failed to get token")

        let ccn = "4111 1111 1111 1111"
        let cvv = "111"
        let exp = "10/2020"
        do {
            let result = try BSApiManager.submitCcDetails(bsToken: token, ccNumber: ccn, expDate: exp, cvv: cvv)
        
            let ccType = result!.ccType
            let last4 = result!.last4Digits
            let country = result!.ccIssuingCountry
            print("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
        } catch {
            XCTAssert(false, "Unexpected error")
        }
        
    }
    */
    func testSubmitCCDetailsError() {
        
        let token = getToken()
        XCTAssertNotNil(token, "Failed to get token")
        
        submitCCDetailsExpectError(token: token!, ccn: "4111", cvv: "111", exp: "12/2020", expectedError: BSCcDetailErrors.invalidCcNumber)
        submitCCDetailsExpectError(token: token!, ccn: "4111111111111111", cvv: "1", exp: "12/2020", expectedError: BSCcDetailErrors.invalidCvv)
        submitCCDetailsExpectError(token: token!, ccn: "4111111111111111", cvv: "111", exp: "22/2020", expectedError: BSCcDetailErrors.invalidExpDate)
    }
    
    
    private func submitCCDetailsExpectError(token : BSToken!, ccn: String!, cvv: String!, exp: String!, expectedError: BSCcDetailErrors) {
        
        do {
            let result = try BSApiManager.submitCcDetails(bsToken: token, ccNumber: ccn, expDate: exp, cvv: cvv)
            XCTAssert(false, "Should have thrown error")
        } catch let error as BSCcDetailErrors {
            XCTAssertEqual(error, expectedError)
            print("Got the right error!")
        } catch {
            XCTAssert(false, "Unexpected error")
        }
    }

   
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/
    
    private func getToken() -> BSToken! {
        
        let token = BSApiManager.getSandboxBSToken()
        print("Token: \(token?.tokenStr) @ \(token?.serverUrl)")
        return token!
    }
    
    private func getCurrencies(token : BSToken!) -> BSCurrencies! {
        
        let bsCurrencies = BSApiManager.getCurrencyRates(bsToken: token!)
        return bsCurrencies!
    }
    
}
