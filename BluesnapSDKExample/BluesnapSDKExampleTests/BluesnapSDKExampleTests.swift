//
//  BluesnapSDKExampleTests.swift
//  BluesnapSDKExampleTests
//
//  Created by Oz on 26/03/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import XCTest
import BluesnapSDK
@testable import BluesnapSDKExample

class BluesnapSDKExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let semaphore = DispatchSemaphore(value: 0)
        BlueSnapSDK.createSandboxTestToken(completion: { token, error in
            
            XCTAssertNotNil(token, "Failed to get token")
            NSLog("Token: \(token?.getTokenStr() ?? "")")
            
            BlueSnapSDK.initBluesnap(bsToken: token, generateTokenFunc: self.generateAndSetBsToken, initKount: false, fraudSessionId: nil, applePayMerchantIdentifier: nil, merchantStoreCurrency: nil, completion: { error in
            
                BlueSnapSDK.getCurrencyRates(completion: { bsCurrencies, errors in
                    
                    XCTAssertNil(errors, "Got errors while trying to get currencies")
                    XCTAssertNotNil(bsCurrencies, "Failed to get currencies")
                    
                    let gbpCurrency : BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
                    XCTAssertNotNil(gbpCurrency)
                    NSLog("testGetTokenAndCurrencies; GBP currency name is: \(gbpCurrency.getName()), its rate is \(gbpCurrency.getRate())")
                    
                    let eurCurrencyRate : Double! = bsCurrencies?.getCurrencyRateByCurrencyCode(code: "EUR")
                    XCTAssertNotNil(eurCurrencyRate)
                    NSLog("testGetTokenAndCurrencies; EUR currency rate is: \(eurCurrencyRate)")
                    
                    semaphore.signal()
                })
            
            })
            
        })

        semaphore.wait()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    /**
     Called by the BlueSnapSDK when token expired error is recognized.
     Here we generate and set a new token, so that when the action re-tries, it will succeed.
     */
    private func generateAndSetBsToken(completion: @escaping (_ token: BSToken?, _ error: BSErrors?)->Void) {
        
        NSLog("Got BS token expiration notification!")
        
        BlueSnapSDK.createSandboxTestToken(completion: { resultToken, errors in
            NSLog("Got BS token= \(resultToken?.getTokenStr() ?? "")")
            DispatchQueue.main.async {
                completion(resultToken, errors)
            }
        })
    }

    
}
