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

class BSApiManager  {
    
    // MARK: Constants
    
    static let BS_PRODUCTION_DOMAIN = "https://api.bluesnap.com/"
    static let BS_SANDBOX_DOMAIN = "https://sandbox.bluesnap.com/"
    static let BS_SANDBOX_TEST_USER = "sdkuser"
    static let BS_SANDBOX_TEST_PASS = "SDKuser123"
    static let TIME_DIFF_TO_RELOAD : Double = -60 * 60 // every hour (interval should be negative, and in seconds)
    
    // MARK: private properties
    static var bsCurrencies : BSCurrencies?
    static var lastCurrencyFetchDate : Date?
    

    // Use this method only in tests to get a token for sandbox
    static func getSandboxBSToken() -> BSToken? {
                
        return getBSToken(domain: BS_SANDBOX_DOMAIN, user: BS_SANDBOX_TEST_USER, password: BS_SANDBOX_TEST_PASS)
    }
    
    
    /**
        Get BlueSnap Token from BlueSnap server
    */
    static func getBSToken(domain: String, user: String, password: String) -> BSToken? {
        
        // create request
        let authorization = getBasicAuth(user: user, password: password)
        let urlStr = domain + "services/2/payment-fields-tokens"
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        //request.timeoutInterval = 60
        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.setValue("0", forHTTPHeaderField: "Content-Length")
        
        // fire request

        var result : BSToken?
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            defer {
                semaphore.signal()
            }
            if let error = error {
                NSLog("error getting BSToken: \(error.localizedDescription)")
                return
            }
            let httpResponse = response as? HTTPURLResponse
            if let httpStatusCode:Int = (httpResponse?.statusCode) {
                if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                    result = extractTokenFromResponse(httpResponse : httpResponse, domain : domain)
                } else {
                    NSLog("Http error getting BSToken; http status = \(httpStatusCode)")
                }
            } else {
                NSLog("Http error getting response for BSToken")
            }
        }
        task.resume()
        semaphore.wait()
        
        return result
    }
    
    /**
        Build the basic authentication header from username/password
    */
    static func getBasicAuth(user: String!, password: String!) -> String {
        let loginStr = String(format: "%@:%@", user, password)
        let loginData = loginStr.data(using: String.Encoding.utf8)!
        let base64LoginStr = loginData.base64EncodedString()
        return "Basic \(base64LoginStr)"
    }
    
    
    /**
        Return a list of currencies and their rates from BlueSnap server
    */
    static func getCurrencyRates(bsToken : BSToken!) -> BSCurrencies? {
        
        if let lastCurrencyFetchDate = lastCurrencyFetchDate, let _ = bsCurrencies {
            let diff = lastCurrencyFetchDate.timeIntervalSinceNow as Double // interval in seconds
            if (diff > TIME_DIFF_TO_RELOAD) {
                return  bsCurrencies
            }
        }
        
        let domain : String! = bsToken.serverUrl
        let urlStr = domain + "services/2/tokenized-services/rates"
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        //request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(bsToken.tokenStr, forHTTPHeaderField: "Token-Authentication")
        
        // fire request
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data : Data?, response, error) in
            if let error = error {
                NSLog("Error getting BS currencies: \(error.localizedDescription)")
                return
            }
            let httpResponse = response as? HTTPURLResponse
            if let httpStatusCode:Int = (httpResponse?.statusCode) {
                if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                    bsCurrencies = parseCurrenciesJSON(data: data)
                    self.lastCurrencyFetchDate = Date()

                } else {
                    NSLog("Http error getting BS currencies; HTTP status = \(httpStatusCode)")
                }
            } else {
                NSLog("Http error getting BS currencies response")
            }
            defer {
                semaphore.signal()
            }
        }
        task.resume()
        semaphore.wait()
        
        return bsCurrencies
    }

    
    /**
    Submit CC details to BlueSnap server
    */
    static func submitCcDetails(bsToken : BSToken!, ccNumber: String, expDate: String, cvv: String) throws -> BSResultCcDetails? {
        
        let requestBody = ["ccNumber": ccNumber.removeWhitespaces(), "cvv":cvv, "expDate": expDate]
        do {
            let result = try submitPaymentDetails(bsToken: bsToken, requestBody: requestBody)
            return result
        } catch let error {
            throw error
        }
    }
    
    /**
     Submit CCN only to BlueSnap server
     */
    static func submitCcn(bsToken : BSToken!, ccNumber: String) throws -> BSResultCcDetails? {
        
        let requestBody = ["ccNumber": ccNumber.removeWhitespaces()]
        do {
            let result = try submitPaymentDetails(bsToken: bsToken, requestBody: requestBody)
            return result
        } catch let error {
            throw error
        }
    }

    // MARK: Private functions
    
    
    
    /**
     Submit CCN only to BlueSnap server
     */
    private static func submitPaymentDetails(bsToken : BSToken!, requestBody: [String:String]) throws -> BSResultCcDetails? {
        
        let domain : String! = bsToken.serverUrl
        let urlStr = domain + "services/2/payment-fields-tokens/" + bsToken.getTokenStr();
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "PUT"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
        } catch let error {
            NSLog("Error serializing CC details: \(error.localizedDescription)")
        }
        //request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // fire request
        
        var result : BSResultCcDetails?
        var resultError : BSCcDetailErrors?
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print("error")
                return
            }
            let httpResponse = response as? HTTPURLResponse
            if let httpStatusCode:Int = (httpResponse?.statusCode) {
                if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                    result = parseResultCCDetailsFromResponse(data: data)
                    
                } else if (httpStatusCode == 400) {
                    resultError = .unknown
                    if let data = data {
                        let errStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                        if (errStr == "\"INVALID_CC_NUMBER\"") {
                            resultError = .invalidCcNumber
                        } else if (errStr == "\"INVALID_CVV\"") {
                            resultError = .invalidCvv
                        } else if (errStr == "\"INVALID_EXP_DATE\"") {
                            resultError = .invalidExpDate
                        } else if (errStr == "\"EXPIRED_TOKEN\"") {
                            resultError = .expiredToken
                        }
                    }
                } else {
                    print("Http error submitting CC details to BS; HTTP status = \(httpStatusCode)")
                    resultError = .unknown
                }
            } else {
                NSLog("Error getting response from BS on submitting Payment details")
            }
            defer {
                semaphore.signal()
            }
        }
        task.resume()
        semaphore.wait()
        if let resultError = resultError {
            throw resultError
        }
        return result
    }
    
    private static func parseResultCCDetailsFromResponse(data: Data?) -> BSResultCcDetails? {
        
        var result : BSResultCcDetails?
        if let data = data {
            do {
                // Parse the result JSOn object
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject] {
                    result = BSResultCcDetails()
                    result!.ccType = json["ccType"] as? String
                    result!.last4Digits = json["last4Digits"] as? String
                    result!.ccIssuingCountry = json["issuingCountry"] as? String
                } else {
                    NSLog("Error parsing BS result on CC detauils submit")
                }
            } catch let error as NSError {
                NSLog("Error parsing BS result on CC detauils submit: \(error.localizedDescription)")
            }
        } else {
            NSLog("No data in BS result on CC detauils submit")
        }
        return result
    }
    
    private static func extractTokenFromResponse(httpResponse: HTTPURLResponse?, domain: String!) -> BSToken? {
        
        var result : BSToken?
        if let location:String = httpResponse?.allHeaderFields["Location"] as? String {
            if let lastIndexOfSlash = location.range(of:"/", options:String.CompareOptions.backwards, range:nil, locale:nil) {
                let tokenStr = location.substring(with: lastIndexOfSlash.upperBound..<location.endIndex)
                result = BSToken(tokenStr: tokenStr, serverUrl: domain)
            }
        }
        return result
    }
    
    private static func parseCurrenciesJSON(data: Data?) -> BSCurrencies? {
        
        var resultData : BSCurrencies?
        if let data = data {
            do {
                // Parse the result JSOn object
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject] {
                    var currencies : [BSCurrency] = []
                    if let currencyName = json["baseCurrencyName"] as? String
                    , let currencyCode = json["baseCurrency"] as? String {
                        let bsCurrency = BSCurrency(name: currencyName, code: currencyCode, rate: 1.0)
                        currencies.append(bsCurrency)
                    }
                    if let exchangeRatesArr = json["exchangeRate"] as? [[String : Any]] {
                        for exchangeRateItem in exchangeRatesArr {
                            if let currencyName = exchangeRateItem["quoteCurrencyName"] as? String
                                , let currencyCode = exchangeRateItem["quoteCurrency"] as? String
                                , let currencyRate = exchangeRateItem["conversionRate"] as? Double {
                                let bsCurrency = BSCurrency(name: currencyName, code: currencyCode, rate: currencyRate)
                                currencies.append(bsCurrency)
                            }
                        }
                    }
                    currencies = currencies.sorted { $0.name < $1.name }
                    resultData = BSCurrencies(currencies: currencies)
                } else {
                    NSLog("Error parsing BS currency rates")
                }
            } catch let error as NSError {
                NSLog("Error parsing BS currency rates: \(error.localizedDescription)")
            }
        } else {
            NSLog("No BS currency data exists")
        }
        return resultData
    }
    
}

enum BSCcDetailErrors : Error {
    case invalidCcNumber
    case invalidCvv
    case invalidExpDate
    case expiredToken
    case unknown
}

