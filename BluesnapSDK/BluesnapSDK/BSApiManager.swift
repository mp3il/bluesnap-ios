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
    internal static let BS_SANDBOX_DOMAIN = "https://sandbox.bluesnap.com/"
    internal static let BS_SANDBOX_TEST_USER = "sdkuser"
    internal static let BS_SANDBOX_TEST_PASS = "SDKuser123"
    internal static let TIME_DIFF_TO_RELOAD: Double = -60 * 60
    // every hour (interval should be negative, and in seconds)

    // MARK: private properties
    internal static var bsCurrencies: BSCurrencies?
    internal static var lastCurrencyFetchDate: Date?
    internal static var apiToken: BSToken?

    internal static var simulateTokenExpired = false

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
     - throws BSApiErrors.unknown in case of some server error
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
     - throws BSApiErrors
    */
    static func getCurrencyRates() throws -> BSCurrencies? {

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

        var resultError: BSApiErrors?
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response, error) in
            if let error = error {
                NSLog("Error getting BS currencies: \(error.localizedDescription)")
                resultError = .unknown
                return
            }
            let httpResponse = response as? HTTPURLResponse
            if let httpStatusCode: Int = (httpResponse?.statusCode) {
                if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                    let tmp = parseCurrenciesJSON(data: data)
                    if tmp != nil {
                        bsCurrencies = tmp
                        self.lastCurrencyFetchDate = Date()
                    } else {
                        resultError = .unknown
                    }
                } else if (httpStatusCode == 400) {
                    resultError = .unknown
                    if let data = data {
                        let errStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                        NSLog("Http error 400 getting BS currencies; error = \(errStr)")
                        if (errStr == "\"EXPIRED_TOKEN\"") {
                            resultError = .expiredToken
                            notifyTokenExpired()
                        }
                    }
                } else {
                    resultError = .unknown
                    NSLog("Http error getting BS currencies; HTTP status = \(httpStatusCode)")
                }
            } else {
                resultError = .unknown
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
     - parameters:
     - ccNumber: Credit card number
     - expDate: CC expiration date in format MM/YYYY
     - cvv: CC security code (CVV)
     - completion: callback with either result details if OK, or error details if not OK
    */
    static func submitCcDetails(ccNumber: String, expDate: String, cvv: String, completion: @escaping (BSResultCcDetails?, BSCcDetailErrors?) -> Void) {

        let requestBody = ["ccNumber": BSStringUtils.removeWhitespaces(ccNumber), "cvv": cvv, "expDate": expDate]
        submitPaymentDetails(requestBody: requestBody, parseFunction: parseCCResponse, completion: { (result, error) in
            if let error = error {
                completion(nil, error)
                debugPrint(error.localizedDescription)
                return
            }
            completion(result, nil)
        })
    }

    /**
     Submit CCN only to BlueSnap server
     - parameters:
     - ccNumber: Credit card number
     - completion: callback with either result details if OK, or error details if not OK
     */
    static func submitCcn(ccNumber: String, completion: @escaping (BSResultCcDetails?, BSCcDetailErrors?) -> Void) {

        let requestBody = ["ccNumber": BSStringUtils.removeWhitespaces(ccNumber)]

        submitPaymentDetails(requestBody: requestBody, parseFunction: parseCCResponse, completion: { (result, error) in
            if let error = error {
                completion(nil, error)
                debugPrint(error.localizedDescription)
                return
            }
            completion(result, nil)
        })
    }


    // MARK: Private functions

    private static func submitPaymentDetails(requestBody: [String: String], parseFunction: @escaping (Int, Data?) -> (BSResultCcDetails?, BSCcDetailErrors?), completion: @escaping (BSResultCcDetails?, BSCcDetailErrors?) -> Void) {

        DispatchQueue.global().async {

            let bsToken = getBsToken()

            let domain: String! = bsToken!.serverUrl
            let urlStr = domain + "services/2/payment-fields-tokens/" + bsToken!.getTokenStr();
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

            var result: BSResultCcDetails?
            var resultError: BSCcDetailErrors?
            //self.simulateTokenExpired = !self.simulateTokenExpired

            let semaphore = DispatchSemaphore(value: 0)
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let error = error {
                    NSLog("API error \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(nil, .unknown)
                    }
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

    private static func parseCCResponse(httpStatusCode: Int, data: Data?) -> (BSResultCcDetails?, BSCcDetailErrors?) {
        var result: BSResultCcDetails?
        var resultError: BSCcDetailErrors?

        if (httpStatusCode >= 200 && httpStatusCode <= 299 && !self.simulateTokenExpired) {
            result = parseResultCCDetailsFromResponse(data: data)
            if (result == nil) {
                resultError = .unknown
            }
        } else if (httpStatusCode == 400 || self.simulateTokenExpired) {
            resultError = .unknown
            if let data = data {
                let errStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                if (errStr == "\"EXPIRED_TOKEN\"" || self.simulateTokenExpired) {
                    resultError = .expiredToken
                    notifyTokenExpired()
                } else if (errStr == "\"INVALID_CC_NUMBER\"") {
                    resultError = .invalidCcNumber
                } else if (errStr == "\"INVALID_CVV\"") {
                    resultError = .invalidCvv
                } else if (errStr == "\"INVALID_EXP_DATE\"") {
                    resultError = .invalidExpDate
                }
            }
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


    /**
     Get BlueSnap Token from BlueSnap server
     Normally you will not do this from the app.
     
     - parameters:
     - domain: look at BS_PRODUCTION_DOMAIN / BS_SANDBOX_DOMAIN
     - user: username
     - password: password
     - throws BSApiErrors.invalidInput if user/pass are incorrect, BSApiErrors.unknown otherwise
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
        var resultError: BSApiErrors?
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            defer {
                semaphore.signal()
            }
            if let error = error {
                NSLog("error getting BSToken: \(error.localizedDescription)")
                resultError = .unknown
                return
            }
            let httpResponse = response as? HTTPURLResponse
            if let httpStatusCode: Int = (httpResponse?.statusCode) {
                if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                    result = extractTokenFromResponse(httpResponse: httpResponse, domain: domain)
                    if result == nil {
                        resultError = .unknown
                    }
                } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
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

    private static func parseApplePayResponse(httpStatusCode: Int, data: Data?) -> (BSResultCcDetails?, BSCcDetailErrors?) {
        var result: BSResultCcDetails?
        var resultError: BSCcDetailErrors?

        if (httpStatusCode >= 200 && httpStatusCode <= 299 && !self.simulateTokenExpired) {
//            if (result == nil) {
//                resultError = .unknown
//            }
        } else if (httpStatusCode == 400 || self.simulateTokenExpired) {
            resultError = .unknown
            if let data = data {
                let errStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                if (errStr == "\"EXPIRED_TOKEN\"" || self.simulateTokenExpired) {
                    resultError = .expiredToken
                    notifyTokenExpired()
                }
            }
        } else {
            NSLog("Http error submitting ApplePay details to BS; HTTP status = \(httpStatusCode)")
            resultError = .unknown
        }
        return (result, resultError)
    }



    /**
     Submit CC details to BlueSnap server
     - parameters:
     - ccNumber: Credit card number
     - expDate: CC expiration date in format MM/YYYY
     - cvv: CC security code (CVV)
     - completion: callback with either result details if OK, or error details if not OK
    */
    static func submitApplepayData(data: String!, completion: @escaping (BSResultCcDetails?, BSCcDetailErrors?) -> Void) {

        let requestBody = [
                "applepayInfo": data!
        ]
        submitPaymentDetails(requestBody: requestBody, parseFunction: parseApplePayResponse, completion: { (result, error) in
            if let error = error {
                completion(nil, error)
                debugPrint(error.localizedDescription)
                return
            }
            completion(result, nil)
        })
    }


}
