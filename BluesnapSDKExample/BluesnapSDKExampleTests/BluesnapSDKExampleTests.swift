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
        
        let token = BlueSnapSDK.getSandboxTestToken()
        XCTAssertNotNil(token, "Failed to get token")
        print("Token: \(token?.getTokenStr())")
        
        let bsCurrencies = BlueSnapSDK.getCurrencyRates(bsToken: token!)
        XCTAssertNotNil(bsCurrencies, "Failed to get currencies")
            
        let gbpCurrency : BSCurrency! = bsCurrencies?.getCurrencyByCode(code: "GBP")
        print("GBP currency name is: \(gbpCurrency.getName()), and its rate is \(gbpCurrency.getRate())")
                
        let eurCurrencyRate : Double! = bsCurrencies?.getCurrencyRateByCurrencyCode(code: "EUR")
        print("EUR currency rate is: \(eurCurrencyRate)")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
