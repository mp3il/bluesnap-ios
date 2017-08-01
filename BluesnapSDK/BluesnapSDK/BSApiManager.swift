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

class BSApiManager {

    // MARK: Constants

    internal static let BS_PRODUCTION_DOMAIN = "https://api.bluesnap.com/"
    internal static let BS_SANDBOX_DOMAIN = "https://sandbox.bluesnap.com/" // "https://us-qa-fct02.bluesnap.com/"
    internal static let BS_SANDBOX_TEST_USER = "sdkuser"
    internal static let BS_SANDBOX_TEST_PASS = "SDKuser123"
    internal static let TIME_DIFF_TO_RELOAD: Double = -60 * 60
    // every hour (interval should be negative, and in seconds)

    // MARK: private properties
    internal static var bsCurrencies: BSCurrencies?
    internal static var supportedPaymentMethods: [String] = []
    internal static var lastCurrencyFetchDate: Date?
    internal static var lastSupportedPaymentMethodsFetchDate: Date?
    internal static var apiToken: BSToken?

    // MARK: bsToken setter/getter

    /**
    Set the bsToken used in all API calls
    */
    static func setBsToken(bsToken: BSToken!) {
        apiToken = bsToken
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

    // MARK: Main functions

    /**
        Use this method only in tests to get a token for sandbox
     - throws BSErrors.unknown in case of some server error
    */
    static func createSandboxBSToken() throws -> BSToken? {

        do {
            let result = try createBSToken(domain: BS_SANDBOX_DOMAIN, user: BS_SANDBOX_TEST_USER, password: BS_SANDBOX_TEST_PASS)
            return result
        } catch let error {
            throw error
        }
    }

    /**
        Return a list of currencies and their rates from BlueSnap server
    */
    static func getCurrencyRates() -> BSCurrencies? {

        let bsToken = getBsToken()

        if let lastCurrencyFetchDate = lastCurrencyFetchDate, let _ = bsCurrencies {
            let diff = lastCurrencyFetchDate.timeIntervalSinceNow as Double // interval in seconds
            if (diff > TIME_DIFF_TO_RELOAD) {
                return bsCurrencies
            }
        }

        let domain: String! = bsToken!.serverUrl
        let urlStr = domain + "services/2/tokenized-services/rates"
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        //request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(bsToken!.tokenStr, forHTTPHeaderField: "Token-Authentication")

        // fire request

        var resultError: BSErrors?
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response, error) in
            if let error = error {
                let errorType = type(of: error)
                NSLog("error getting BS currencies - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
                resultError = .unknown
                } else {
            let httpResponse = response as? HTTPURLResponse
            if let httpStatusCode:Int = (httpResponse?.statusCode) {
                if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                    let tmp = parseCurrenciesJSON(data: data)
                    if tmp != nil {
                        bsCurrencies = tmp
                        self.lastCurrencyFetchDate = Date()
                    } else {
                        resultError = .unknown
                    }
                } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
                    resultError = parseError(data: data, httpStatusCode: httpStatusCode)
                } else {
                    resultError = .unknown
                    NSLog("Http error getting BS currencies; HTTP status = \(httpStatusCode)")
                }
           } else {
                resultError = .unknown
                NSLog("Http error getting BS currencies response")}
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
     - parameters:
     - ccNumber: Credit card number
     - expDate: CC expiration date in format MM/YYYY
     - cvv: CC security code (CVV)
     - completion: callback with either result details if OK, or error details if not OK
    */
    static func submitCcDetails(ccNumber: String, expDate: String, cvv: String, completion: @escaping (BSResultCcDetails?, BSErrors?) -> Void) {

        let requestBody = ["ccNumber": BSStringUtils.removeWhitespaces(ccNumber), "cvv": cvv, "expDate": expDate]
        submitPaymentDetails(requestBody: requestBody, parseFunction: parseCCResponse, completion: { (result, error) in
            if let error = error {
                completion(nil, error)
                debugPrint(error.localizedDescription)
                return
            }
            completion(result as? BSResultCcDetails, nil)
        })
    }

    /**
     Submit CCN only to BlueSnap server
     - parameters:
     - ccNumber: Credit card number
     - completion: callback with either result details if OK, or error details if not OK
     */
    static func submitCcn(ccNumber: String, completion: @escaping (BSResultCcDetails?, BSErrors?) -> Void) {

        let requestBody = ["ccNumber": BSStringUtils.removeWhitespaces(ccNumber)]

        submitPaymentDetails(requestBody: requestBody, parseFunction: parseCCResponse, completion: { (result, error) in
            if let error = error {
                completion(nil, error)
                debugPrint(error.localizedDescription)
                return
            }
            completion(result as? BSResultCcDetails, nil)
        })
    }


    /**
     Return a list of merchant-supported payment methods from BlueSnap server
     */
    static func getSupportedPaymentMethods() -> [String] {
        
        let bsToken = getBsToken()
        
        if let lastSupportedPaymentMethodsFetchDate = lastSupportedPaymentMethodsFetchDate {
            let diff = lastSupportedPaymentMethodsFetchDate.timeIntervalSinceNow as Double // interval in seconds
            if (diff > TIME_DIFF_TO_RELOAD) {
                return supportedPaymentMethods
            }
        }
        
        let domain: String! = bsToken!.serverUrl
        let urlStr = domain + "services/2/tokenized-services/supported-payment-methods"
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(bsToken!.tokenStr, forHTTPHeaderField: "Token-Authentication")
        
        // fire request
        
        var resultError: BSErrors?
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response, error) in
            if let error = error {
                let errorType = type(of: error)
                NSLog("error getting BS currencies - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
                resultError = .unknown
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        supportedPaymentMethods = parsePaymentMethodsJSON(data: data)
                    } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
                        resultError = parseError(data: data, httpStatusCode: httpStatusCode)
                    } else {
                        resultError = .unknown
                        NSLog("Http error getting BS Supported Payment Methods; HTTP status = \(httpStatusCode)")
                    }
                } else {
                    resultError = .unknown
                    NSLog("Http error getting BS Supported Payment Methods response")}
            }
            defer {
                semaphore.signal()
            }
        }
        task.resume()
        semaphore.wait()
        
        return supportedPaymentMethods
    }
    
    /**
     Return a list of merchant-supported payment methods from BlueSnap server
     */
    static func isSupportedPaymentMethod(_ paymentType: BSPaymentType) -> Bool {
        
        let supportedPaymentMethods = getSupportedPaymentMethods()
        let exists = supportedPaymentMethods.index(of: paymentType.rawValue)
        return exists != nil
    }
    

    // MARK: Private functions

    private static func submitPaymentDetails(requestBody: [String: String], parseFunction: @escaping (Int, Data?) -> (BSResultPaymentDetails?, BSErrors?), completion: @escaping (BSResultPaymentDetails?, BSErrors?) -> Void) {

        DispatchQueue.global().async {

            let bsToken = getBsToken()

            let domain: String! = bsToken!.serverUrl
            // If you want to test expired token, use this:
            //let urlStr = domain + "services/2/payment-fields-tokens/" + "fcebc8db0bcda5f8a7a5002ca1395e1106ea668f21200d98011c12e69dd6bceb_"
            let urlStr = domain + "services/2/payment-fields-tokens/" + bsToken!.getTokenStr()
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

            var result: BSResultPaymentDetails?
            var resultError: BSErrors?

            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let error = error {
                    let errorType = type(of: error)
                    NSLog("error submitting BS Payment details - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
                    completion(nil, .unknown)
                    return
                }
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode: Int = (httpResponse?.statusCode) {
                    (result, resultError) = parseFunction(httpStatusCode, data)
                } else {
                    NSLog("Error getting response from BS on submitting Payment details")
                }
                defer {
                    DispatchQueue.main.async {
                        completion(result, resultError)
                    }
                }
            }
            task.resume()

        }
    }

    private static func parseCCResponse(httpStatusCode: Int, data: Data?) -> (BSResultCcDetails?, BSErrors?) {
        var result: BSResultCcDetails?
        var resultError: BSErrors?

        if (httpStatusCode >= 200 && httpStatusCode <= 299) {
            result = parseResultCCDetailsFromResponse(data: data)
            if (result == nil) {
                resultError = .unknown
            }
        } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
            resultError = parseError(data: data, httpStatusCode: httpStatusCode)
        } else {
            NSLog("Http error submitting CC details to BS; HTTP status = \(httpStatusCode)")
            resultError = .unknown
        }
        return (result, resultError)
    }

    private static func parseResultCCDetailsFromResponse(data: Data?) -> BSResultCcDetails? {

        var result: BSResultCcDetails?
        if let data = data {
            do {
                // Parse the result JSOn object
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                    result = BSResultCcDetails()
                    result!.ccType = json["ccType"] as? String
                    result!.last4Digits = json["last4Digits"] as? String
                    result!.ccIssuingCountry = (json["issuingCountry"] as? String ?? "").uppercased()
                } else {
                    NSLog("Error parsing BS result on CC details submit")
                }
            } catch let error as NSError {
                NSLog("Error parsing BS result on CC details submit: \(error.localizedDescription)")
            }
        } else {
            NSLog("No data in BS result on CC details submit")
        }
        return result
    }

    private static func extractTokenFromResponse(httpResponse: HTTPURLResponse?, domain: String!) -> BSToken? {

        var result: BSToken?
        if let location: String = httpResponse?.allHeaderFields["Location"] as? String {
            if let lastIndexOfSlash = location.range(of: "/", options: String.CompareOptions.backwards, range: nil, locale: nil) {
                let tokenStr = location.substring(with: lastIndexOfSlash.upperBound..<location.endIndex)
                result = BSToken(tokenStr: tokenStr, serverUrl: domain)
            } else {
                NSLog("Error: BS Token does not contain /")
            }
        } else {
            NSLog("Error: BS Token does not appear in response headers")
        }
        return result
    }

    private static func parseCurrenciesJSON(data: Data?) -> BSCurrencies? {

        var resultData: BSCurrencies?
        if let data = data {
            do {
                // Parse the result JSOn object
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                    var currencies: [BSCurrency] = []
                    if let currencyName = json["baseCurrencyName"] as? String
                    , let currencyCode = json["baseCurrency"] as? String {
                        let bsCurrency = BSCurrency(name: currencyName, code: currencyCode, rate: 1.0)
                        currencies.append(bsCurrency)
                    }
                    if let exchangeRatesArr = json["exchangeRate"] as? [[String: Any]] {
                        for exchangeRateItem in exchangeRatesArr {
                            if let currencyName = exchangeRateItem["quoteCurrencyName"] as? String
                            , let currencyCode = exchangeRateItem["quoteCurrency"] as? String
                            , let currencyRate = exchangeRateItem["conversionRate"] as? Double {
                                let bsCurrency = BSCurrency(name: currencyName, code: currencyCode, rate: currencyRate)
                                currencies.append(bsCurrency)
                            }
                        }
                    }
                    currencies = currencies.sorted {
                        $0.name < $1.name
                    }
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

    
    private static func parsePaymentMethodsJSON(data: Data?) -> [String] {
        
        if let data = data {
            do {
                // Parse the result JSOn object
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                    if let arr = json["paymentMethods"] as? [String] {
                        return arr
                    }
                } else {
                    NSLog("Error parsing BS Supported Payment Methods")
                }
            } catch let error as NSError {
                NSLog("Error parsing Bs Supported Payment Methods: \(error.localizedDescription)")
            }
        } else {
            NSLog("No BS Supported Payment Methods data exists")
        }
        return []
    }
    
    /**
     Get BlueSnap Token from BlueSnap server
     Normally you will not do this from the app.
     
     - parameters:
     - domain: look at BS_PRODUCTION_DOMAIN / BS_SANDBOX_DOMAIN
     - user: username
     - password: password
     - throws BSErrors.invalidInput if user/pass are incorrect, BSErrors.unknown otherwise
     */
    internal static func createBSToken(domain: String, user: String, password: String) throws -> BSToken? {

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

        var result: BSToken?
        var resultError: BSErrors?
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                let errorType = type(of: error)
                NSLog("error getting BSToken - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
                resultError = .unknown
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode: Int = (httpResponse?.statusCode) {
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result = extractTokenFromResponse(httpResponse: httpResponse, domain: domain)
                        if result == nil {
                            resultError = .unknown
                        }
                    } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
                        NSLog("Http error getting BSToken; http status = \(httpStatusCode)")
                        resultError = .invalidInput
                    } else {
                        resultError = .unknown
                        NSLog("Http error getting BSToken; http status = \(httpStatusCode)")
                    }
                } else {
                    resultError = .unknown
                    NSLog("Http error getting response for BSToken")
                }
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

    /**
     Build the basic authentication header from username/password
     - parameters:
     - user: username
     - password: password
     */
    private static func getBasicAuth(user: String!, password: String!) -> String {
        let loginStr = String(format: "%@:%@", user, password)
        let loginData = loginStr.data(using: String.Encoding.utf8)!
        let base64LoginStr = loginData.base64EncodedString()
        return "Basic \(base64LoginStr)"
    }

    private static func notifyTokenExpired() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name.bsTokenExpirationNotification, object: nil)
        }
    }

    private static func parseApplePayResponse(httpStatusCode: Int, data: Data?) -> (BSResultApplePayDetails?, BSErrors?) {
        var result: BSResultApplePayDetails?
        var resultError: BSErrors?

        if (httpStatusCode >= 200 && httpStatusCode <= 299) {
            NSLog("ApplePay data submitted successfully ")
            result = BSResultApplePayDetails()
            // TODO: fill result
            
        } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
            resultError = parseError(data: data, httpStatusCode: httpStatusCode)
        } else {
            NSLog("Http error submitting ApplePay details to BS; HTTP status = \(httpStatusCode)")
            resultError = .unknown
        }
        return (result, resultError)
    }

    private static func parseError(data: Data?, httpStatusCode: Int) -> BSErrors {
        
        var resultError : BSErrors = .invalidInput
        
        var errStr : String?
        if let data = data {
            do {
                // sometimes the data is not JSON :(
                let str : String = String(data: data, encoding: .utf8) ?? ""
                let p = str.characters.index(of: "{")
                if p == nil {
                    errStr = str.replacingOccurrences(of: "\"", with: "")
                } else {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                    if let messages = json["message"] as? [[String: AnyObject]] {
                        if let message = messages[0] as? [String: String] {
                            errStr = message["errorName"]
                        } else {
                            NSLog("Error - result messages does not contain message")
                        }
                    } else {
                        NSLog("Error - result data does not contain messages")
                    }
                }
            } catch let error {
                NSLog("Error parsing result data: \(data) ; error: \(error.localizedDescription)")
            }
        } else {
            NSLog("Error - result data is empty")
            return .unknown
        }
        if (errStr == "EXPIRED_TOKEN") {
            resultError = .expiredToken
            notifyTokenExpired()
        } else if (errStr == "INVALID_CC_NUMBER") {
            resultError = .invalidCcNumber
        } else if (errStr == "INVALID_CVV") {
            resultError = .invalidCvv
        } else if (errStr == "INVALID_EXP_DATE") {
            resultError = .invalidExpDate
        } else if (errStr == "TOKEN_WAS_ALREADY_USED_FOR_APPLEֹֹֹֹ_PAY") {
            resultError = .usedTokenApplePay
        } else if (errStr == "TOKEN_WAS_ALREADY_USED_FOR_CC") {
            resultError = .usedTokenForCC
        } else if (errStr == "TOKEN_NOT_FOUND") {
            resultError = .tokenNotFound
            notifyTokenExpired()
        } else if httpStatusCode == 401 {
            // unauthorized - this happens in the getRates, where the result is ubreadable HTML
            resultError = .tokenNotFound
            notifyTokenExpired()
        }
        
        return resultError
    }

    /**
     Submit Apple pay data to BlueSnap server
     - parameters:
     - data: The apple pay encoded data
     - completion: callback with either result details if OK, or error details if not OK
    */
    static internal func submitApplepayData(data: String!, completion: @escaping (BSResultApplePayDetails?, BSErrors?) -> Void) {

        let requestBody = [
                "applePayToken": data!
        ]
        submitPaymentDetails(requestBody: requestBody, parseFunction: parseApplePayResponse, completion: { (result, error) in
            if let error = error {
                completion(nil, error)
                debugPrint(error.localizedDescription)
                return
            }
            completion(result as? BSResultApplePayDetails, nil)
        })
    }


}
