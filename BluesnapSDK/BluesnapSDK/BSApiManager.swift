//
//  BSApiManager.swift
//  BluesnapSDK
//
// Contains methods that access BlueSnap API
//
//  Created by Shevie Chen on 06/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

@objc class BSApiManager: NSObject {

    // MARK: Constants

    internal static let BS_PRODUCTION_DOMAIN = "https://api.bluesnap.com/"
    internal static let BS_SANDBOX_DOMAIN = "https://sandbox.bluesnap.com/" // "https://us-qa-fct02.bluesnap.com/"
    internal static let BS_SANDBOX_TEST_USER = "sdkuser"
    internal static let BS_SANDBOX_TEST_PASS = "SDKuser123"
    internal static let TIME_DIFF_TO_RELOAD: Double = -60 * 60
    // every hour (interval should be negative, and in seconds)
 
    // MARK: private properties
    internal static var bsCurrencies: BSCurrencies?
    internal static var supportedPaymentMethods: [String]?
    internal static var lastCurrencyFetchDate: Date?
    internal static var lastSupportedPaymentMethodsFetchDate: Date?
    internal static var apiToken: BSToken?
    internal static var payPalToken : String?
    internal static var apiGenerateTokenFunc: (_ completion: @escaping (BSToken?, BSErrors?) -> Void) -> Void = { completion in
        NSLog("no token regeneration method was supplied")
        completion(nil, BSErrors.invalidInput)
    }

    // MARK: bsToken functions

    /**
    Set the bsToken used in all API calls
    */
    static func setBsToken(bsToken: BSToken!) {
        apiToken = bsToken
        payPalToken = nil
    }

    /**
     Set the token re-generation method to be used for BS API when token expires
     - parameters:
     - completion: function to be called after token is generated; will receive optional token and optional error
     */
    open class func setGenerateBsTokenFunc(generateTokenFunc: @escaping (_ completion: @escaping (BSToken?, BSErrors?) -> Void) -> Void) {
        
        apiGenerateTokenFunc = generateTokenFunc
    }

    /**
     Get the bsToken used in all API calls - if empty, throw fatal error
     */
    static func getBsToken() -> BSToken! {

        if apiToken != nil {
            return apiToken
        } else {
            fatalError("BsToken has not been initialized")
        }
    }
    
    /**
     Use this method only in tests to get a token for sandbox
     - parameters:
     - completion: function to be called after token is generated; will receive optional token and optional error
     */
    static func createSandboxBSToken(completion: @escaping (BSToken?, BSErrors?) -> Void) {
        
        createBSToken(domain: BS_SANDBOX_DOMAIN, user: BS_SANDBOX_TEST_USER, password: BS_SANDBOX_TEST_PASS, completion: completion)
    }
    
    
    // MARK: Main functions
    
    
    /**
        Return a list of currencies and their rates from BlueSnap server
     - parameters:
     - completion: function to be called after data is received; will receive optional currency data and optional error
    */
    static func getCurrencyRates(completion: @escaping (BSCurrencies?, BSErrors?) -> Void) {

        let bsToken = getBsToken()

        if let lastCurrencyFetchDate = lastCurrencyFetchDate, let _ = bsCurrencies {
            let diff = lastCurrencyFetchDate.timeIntervalSinceNow as Double // interval in seconds
            if (diff > TIME_DIFF_TO_RELOAD) {
                completion(bsCurrencies, nil)
                return
            }
        }

        NSLog("BlueSnap; getCurrencyRates")
        BSApiCaller.getCurrencyRates(bsToken: bsToken, completion: {
            resultCurrencies, resultError in
            
            NSLog("BlueSnap; getCurrencyRates completion")
            if resultError == .unAuthorised {
                BSApiCaller.isTokenExpired(bsToken: bsToken, completion: { isExpired in
                    if isExpired {
                        // regenerate Token and try again
                        regenerateToken(executeAfter: { _ in
                            BSApiCaller.getCurrencyRates(bsToken: getBsToken(), completion: { resultCurrencies2, resultError2 in
                                
                                if resultError2 == nil {
                                    bsCurrencies = resultCurrencies2
                                    self.lastCurrencyFetchDate = Date()
                                }
                                completion(bsCurrencies, resultError2)
                            })
                        })
                    } else {
                        completion(bsCurrencies, resultError)
                    }
                })
                
            } else {
                if (resultError == nil) {
                    bsCurrencies = resultCurrencies
                    self.lastCurrencyFetchDate = Date()
                }
                completion(bsCurrencies, resultError)
            }
        })
    }


    /**
     Submit CC details to BlueSnap server
     - parameters:
     - ccNumber: Credit card number
     - expDate: CC expiration date in format MM/YYYY
     - cvv: CC security code (CVV)
     - completion: callback with either result details if OK, or error details if not OK
    */
    static func submitCcDetails(ccNumber: String, expDate: String, cvv: String, completion: @escaping (BSCcDetails, BSErrors?) -> Void) {

        let requestBody = ["ccNumber": BSStringUtils.removeWhitespaces(ccNumber), "cvv": cvv, "expDate": expDate]
        submitCcDetails(requestBody: requestBody, completion: completion)
    }

    
    /**
     Submit CCN only to BlueSnap server
     - parameters:
     - ccNumber: Credit card number
     - completion: callback with either result details if OK, or error details if not OK
     */
    static func submitCcn(ccNumber: String, completion: @escaping (BSCcDetails, BSErrors?) -> Void) {
        
        let requestBody = ["ccNumber": BSStringUtils.removeWhitespaces(ccNumber)]
        submitCcDetails(requestBody: requestBody, completion: completion)
    }
    

    /**
     Fetch a list of merchant-supported payment methods from BlueSnap server
     - parameters:
     - completion: function to be called after data is fetched; will receive optional string list and optional error
     */
    static func getSupportedPaymentMethods(completion: @escaping ([String]?, BSErrors?) -> Void) {
        
        let bsToken = getBsToken()
        
        if let lastSupportedPaymentMethodsFetchDate = lastSupportedPaymentMethodsFetchDate, let supportedPaymentMethods = supportedPaymentMethods {
            let diff = lastSupportedPaymentMethodsFetchDate.timeIntervalSinceNow as Double // interval in seconds
            if (diff > TIME_DIFF_TO_RELOAD) {
                completion(supportedPaymentMethods, nil)
                return
            }
        }
        
        NSLog("BlueSnap; getSupportedPaymentMethods")
        BSApiCaller.getSupportedPaymentMethods(bsToken: bsToken, completion: {
            resultSupportedPaymentMethods, resultError in
            
            NSLog("BlueSnap; getSupportedPaymentMethods completion")
            if resultError == .unAuthorised {
                BSApiCaller.isTokenExpired(bsToken: bsToken, completion: { isExpired in
                    if isExpired {
                        // regenerate Token and try again
                        regenerateToken(executeAfter: { _ in
                            NSLog("BlueSnap; getSupportedPaymentMethods retry")
                            BSApiCaller.getSupportedPaymentMethods(bsToken: getBsToken(), completion: { resultSupportedPaymentMethods2, resultError2 in
                                
                                NSLog("BlueSnap; getSupportedPaymentMethods retry completion")
                                if resultError2 == nil {
                                    supportedPaymentMethods = resultSupportedPaymentMethods2
                                    self.lastSupportedPaymentMethodsFetchDate = Date()
                                }
                                completion(supportedPaymentMethods, resultError2)
                            })
                        })
                    } else {
                        completion(supportedPaymentMethods, resultError)
                    }
                })
                
            } else {
                if resultError == nil {
                    supportedPaymentMethods = resultSupportedPaymentMethods
                    self.lastSupportedPaymentMethodsFetchDate = Date()
                }
                completion(supportedPaymentMethods, resultError)
            }
        })
    }
    
    /**
     Return a list of merchant-supported payment methods from BlueSnap server
     */
    static func isSupportedPaymentMethod(paymentType: BSPaymentType, supportedPaymentMethods: [String]?) -> Bool {
        
        if let supportedPaymentMethods = supportedPaymentMethods {
            let exists = supportedPaymentMethods.index(of: paymentType.rawValue)
            return exists != nil
        } else {
            return false
        }
    }
    
    /**
     Create PayPal token on BlueSnap server and get back the URL for redirect
     - parameters:
     - bsToken: a token for BlueSnap tokenized services
     - paymentRequest: details of the purchase: specifically amount and currency are used
     - withShipping: setting for the PayPal flow - do we want to request shipping details from the shopper
     - completion: a callback function to be called once the PayPal token is fetched; receives optional PayPal Token string data and optional error
     */
    static func createPayPalToken(paymentRequest: BSPayPalPaymentRequest, withShipping: Bool, completion: @escaping (String?, BSErrors?) -> Void) {
        
        if (payPalToken != nil) {
            completion(payPalToken, nil)
            return
        }
        
        DispatchQueue.global().async {
            let bsToken = getBsToken()
            
            NSLog("BlueSnap; createPayPalToken")
            BSApiCaller.createPayPalToken(bsToken: bsToken, paymentRequest: paymentRequest, withShipping: withShipping, completion: {
                resultToken, resultError in
                NSLog("BlueSnap; createPayPalToken completion")
                if resultError == .unAuthorised {
                    NSLog("BlueSnap; createPayPalToken retry")
                    BSApiCaller.isTokenExpired(bsToken: bsToken, completion: { isExpired in
                        NSLog("BlueSnap; createPayPalToken retry completion")
                        if isExpired {
                            // regenerate Token and try again
                            regenerateToken(executeAfter: { _ in
                                BSApiCaller.createPayPalToken(bsToken: getBsToken(), paymentRequest: paymentRequest, withShipping: withShipping, completion: { resultToken2, resultError2 in
                                    
                                    payPalToken = resultToken2
                                    completion(resultToken2, resultError2)
                                })
                            })
                        } else {
                            completion(resultToken, resultError)
                        }
                    })
                    
                } else {
                    payPalToken = resultToken
                    completion(resultToken, resultError)
                }
            })
        }
    }


    // MARK: Private/internal functions

    /**
     Get BlueSnap Token from BlueSnap server
     Normally you will not do this from the app.
     
     - parameters:
     - domain: look at BSApiManager BS_PRODUCTION_DOMAIN / BS_SANDBOX_DOMAIN
     - user: username
     - password: password
     - completion: function to be called after result is fetched; will receive optional token and optional error
     */
    internal static func createBSToken(domain: String, user: String, password: String, completion: @escaping (BSToken?, BSErrors?) -> Void) {
        
        BSApiCaller.createBSToken(domain: domain, user: user, password: password, completion: completion)
    }

 
    /**
     Submit Apple pay data to BlueSnap server
     - parameters:
     - data: The apple pay encoded data
     - completion: callback with either result details if OK, or error details if not OK
    */
    static internal func submitApplepayData(data: String!, completion: @escaping ([String:String], BSErrors?) -> Void) {

        let requestBody = [
                "applePayToken": data!
        ]
        BSApiCaller.submitPaymentDetails(bsToken: getBsToken(), requestBody: requestBody, parseFunction: BSApiCaller.parseApplePayResponse, completion: { resultData, error in
            if let error = error {
                completion(resultData, error)
                debugPrint(error.description())
                return
            }
            completion(resultData, nil)
        })
    }

    static internal func regenerateToken(executeAfter: @escaping () -> Void) {
        
        NSLog("Regenrating new token instead of \(apiToken?.getTokenStr() ?? "")")
        apiGenerateTokenFunc({newToken, error in
            if let newToken = newToken {
                setBsToken(bsToken: newToken)
            }
            executeAfter()
        })
    }

    
    private static func submitCcDetails(requestBody: [String:String], completion: @escaping (BSCcDetails, BSErrors?) -> Void) {
        
        NSLog("BlueSnap; submitCcDetails")
        BSApiCaller.submitPaymentDetails(bsToken: getBsToken(), requestBody: requestBody, parseFunction: BSApiCaller.parseCCResponse, completion: { resultData, error in
            
            NSLog("BlueSnap; submitCcDetails completion")
            if error == BSErrors.expiredToken || error == BSErrors.tokenNotFound {
                // regenerate Token and try again
                NSLog("BlueSnap; submitCcDetails retry")
                regenerateToken(executeAfter: { _ in
                    BSApiCaller.submitPaymentDetails(bsToken: getBsToken(), requestBody: requestBody, parseFunction: BSApiCaller.parseCCResponse, completion: { resultData2, error2 in
                        
                        NSLog("BlueSnap; submitCcDetails retry completion")
                        fillCcDetailsAndComplete(resultData: resultData2, error: error2, completion: completion)
                    })
                })
            } else {
                fillCcDetailsAndComplete(resultData: resultData, error: error, completion: completion)
            }
        })
    }
    
    private static func fillCcDetailsAndComplete(resultData: [String:String], error: BSErrors?, completion: @escaping (BSCcDetails, BSErrors?) -> Void) {
        
        let ccDetails = BSCcDetails()
        if let error = error {
            completion(ccDetails, error)
            debugPrint(error.description())
            return
        }
        ccDetails.ccIssuingCountry = resultData["ccIssuingCountry"]
        ccDetails.ccType = resultData["ccType"]
        ccDetails.last4Digits = resultData["last4Digits"]
        completion(ccDetails, nil)
    }

}
