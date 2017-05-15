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
    
    func testGetTokenAndCurrencies() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let token = getToken()
        XCTAssertNotNil(token, "Failed to get token")
        
        let bsCurrencies = getCurrencies(token: token)
        XCTAssertNotNil(bsCurrencies, "Failed to get currencies")
        
        let gbpCurrency : BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
        NSLog("GBP currency name is: \(gbpCurrency.name), its rate is \(gbpCurrency.rate)")
            
        let eurCurrencyRate : Double! = bsCurrencies?.getCurrencyRateByCurrencyCode(code: "EUR")
        NSLog("EUR currency rate is: \(eurCurrencyRate)")
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
            NSLog("Result: ccType=\(ccType!), last4Digits=\(last4!), ccIssuingCountry=\(country!)")
        } catch {
            XCTAssert(false, "Unexpected error")
        }
        
    }
    
    func testSubmitCCDetailsError() {
        
        let token = getToken()
        XCTAssertNotNil(token, "Failed to get token")
        
        submitCCDetailsExpectError(token: token!, ccn: "4111", cvv: "111", exp: "12/2020", expectedError: BSCcDetailErrors.invalidCcNumber)
        submitCCDetailsExpectError(token: token!, ccn: "4111111111111111", cvv: "1", exp: "12/2020", expectedError: BSCcDetailErrors.invalidCvv)
        submitCCDetailsExpectError(token: token!, ccn: "4111111111111111", cvv: "111", exp: "22/2020", expectedError: BSCcDetailErrors.invalidExpDate)
    }
    
    func testGetTokenWithBadCredentials() {
        
        do {
            let _ = try BSApiManager.getBSToken(domain: BSApiManager.BS_SANDBOX_DOMAIN, user: "dummy", password: "dummypass")
            print("We should have crashed here")
            fatalError()
        } catch let error as BSApiErrors {
            if error == BSApiErrors.invalidInput {
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

   
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/
    
    private func submitCCDetailsExpectError(token : BSToken!, ccn: String!, cvv: String!, exp: String!, expectedError: BSCcDetailErrors) {
        
        do {
            let _ = try BSApiManager.submitCcDetails(bsToken: token, ccNumber: ccn, expDate: exp, cvv: cvv)
            XCTAssert(false, "Should have thrown error")
        } catch let error as BSCcDetailErrors {
            XCTAssertEqual(error, expectedError)
            NSLog("Got the right error!")
        } catch {
            XCTAssert(false, "Unexpected error")
        }
    }
    
    

    
    private func getToken() -> BSToken! {
        
        do {
            let token = try BSApiManager.getSandboxBSToken()
            NSLog("Token: \(token?.tokenStr) @ \(token?.serverUrl)")
            return token!
        } catch let error {
            print("Got error \(error.localizedDescription)")
            fatalError()
        }
    }
    
    private func getCurrencies(token : BSToken!) -> BSCurrencies! {
        
        do {
            let bsCurrencies = try BSApiManager.getCurrencyRates(bsToken: token!)
            return bsCurrencies!
        } catch let error {
            print("Got wrong error \(error.localizedDescription)")
            fatalError()
        }
    }
    
}
