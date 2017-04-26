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
    static let BS_SANDBOX_DOMAIN = "https://us-qa-fct03.bluesnap.com/" // "https://sandbox.bluesnap.com/"
    static let BS_SANDBOX_TEST_USER = "GCpapi" //"sdkuser"
    static let BS_SANDBOX_TEST_PASS = "Plimus4321" //"SDKuser123"
    
    // MARK: Settings
    var bsDomain = BS_PRODUCTION_DOMAIN
    
    
    
    func setBSDomain(domain : String!) {
        bsDomain = domain
    }
    
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
            if error != nil {
                NSLog("error getting BSToken: \(error!.localizedDescription)")
                return
            }
            let httpResponse = response as? HTTPURLResponse
            let httpStatusCode:Int = (httpResponse?.statusCode)!
            if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                let location:String = httpResponse?.allHeaderFields["Location"] as! String
                let lastIndexOfSlash = location.range(of:"/", options:String.CompareOptions.backwards, range:nil, locale:nil)!
                let tokenStr = location.substring(with: lastIndexOfSlash.upperBound..<location.endIndex)
                result = BSToken(tokenStr: tokenStr, serverUrl: domain)
            } else {
                NSLog("Http error getting BSToken; http status = \(httpStatusCode)")
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
        
        let domain : String! = bsToken.serverUrl
        let urlStr = domain + "services/2/tokenized-services/rates"
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        //request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(bsToken.tokenStr, forHTTPHeaderField: "Token-Authentication")
        
        // fire request
        
        var resultData : BSCurrencies?
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                NSLog("Error getting BS currencies: \(error!.localizedDescription)")
                return
            }
            let httpResponse = response as? HTTPURLResponse
            let httpStatusCode:Int = (httpResponse?.statusCode)!
            if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                do {
                    
                    // Parse the result JSOn object
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                    var currencies : [BSCurrency] = []
                    var bsCurrency : BSCurrency! = BSCurrency(name: json["baseCurrencyName"] as! String!,
                                                              code: json["baseCurrency"] as! String!,
                                                              rate: 1.0)
                    currencies.append(bsCurrency)
                    let exchangeRatesArr = json["exchangeRate"] as! [[String : Any]]
                    for exchangeRateItem in exchangeRatesArr {
                        bsCurrency = BSCurrency(name: exchangeRateItem["quoteCurrencyName"] as! String!,
                            code: exchangeRateItem["quoteCurrency"] as! String!,
                            rate: exchangeRateItem["conversionRate"] as! Double!)
                        currencies.append(bsCurrency)
                    }
                    resultData = BSCurrencies(currencies: currencies)
                    
                } catch let error as NSError {
                    NSLog("Error parsing BS currency rates: \(error.localizedDescription)")
                }
                
            } else {
                NSLog("Http error getting BS currencies; HTTP status = \(httpStatusCode)")
            }
            defer {
                semaphore.signal()
            }
        }
        task.resume()
        semaphore.wait()
        return resultData
    }
    
    /**
    Submit CC details to BlueSnap server
    */
    static func submitCcDetails(bsToken : BSToken!, ccNumber: String, expDate: String, cvv: String) throws -> BSResultCcDetails? {
        
        let requestBody = ["ccNumber": ccNumber, "cvv":cvv, "expDate": expDate]
        
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
            if error != nil {
                print("error")
                return
            }
            let httpResponse = response as? HTTPURLResponse
            let httpStatusCode:Int = (httpResponse?.statusCode)!
            if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                do {
                    
                    // Parse the result JSOn object
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]

                    result = BSResultCcDetails()
                    result!.ccType = json["ccType"] as? String
                    result!.last4Digits = json["last4Digits"] as? String
                    result!.ccIssuingCountry = json["issuingCountry"] as? String
                    
                } catch let error as NSError {
                    NSLog("Error parsing BS result on CC detauils submit: \(error.localizedDescription)")
                }
                
            } else if (httpStatusCode == 400) {
                resultError = .unknown
                if (data != nil) {
                    let errStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    if (errStr == "\"INVALID_CC_NUMBER\"") {
                        resultError = .invalidCcNumber
                    } else if (errStr == "\"INVALID_CVV\"") {
                        resultError = .invalidCvv
                    } else if (errStr == "\"INVALID_EXP_DATE\"") {
                        resultError = .invalidExpDate
                    }
                }
            } else {
                print("Http error submitting CC details to BS; HTTP status = \(httpStatusCode)")
                resultError = .unknown
            }
            defer {
                semaphore.signal()
            }
        }
        task.resume()
        semaphore.wait()
        if (resultError != nil) {
            throw resultError!
        }
        return result
    }
    
    
}

enum BSCcDetailErrors : Error {
    case invalidCcNumber
    case invalidCvv
    case invalidExpDate
    case unknown
}

