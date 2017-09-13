//
//  BSApiCaller.swift
//  BluesnapSDK
//
// Holds all the messy code for executing http calls
//
//  Created by Shevie Chen on 13/09/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

import Foundation

@objc class BSApiCaller: NSObject {
    
    
    /**
     Return a list of currencies and their rates from BlueSnap server
     */
    static func getCurrencyRates(bsToken: BSToken!, completion: @escaping (BSCurrencies?, BSErrors?) -> Void) {
        
        let domain: String! = bsToken.serverUrl
        let urlStr = domain + "services/2/tokenized-services/rates"
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(bsToken.tokenStr, forHTTPHeaderField: "Token-Authentication")
        
        // fire request
        
        var resultError: BSErrors?
        var resultCurrencies: BSCurrencies?
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response, error) in
            if let error = error {
                let errorType = type(of: error)
                NSLog("error getting BS currencies - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
                resultError = .unknown
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        resultCurrencies = parseCurrenciesJSON(data: data)
                        if resultCurrencies == nil {
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
                completion(resultCurrencies, resultError)
            }
        }
        task.resume()
    }
    
    private static func parseError(data: Data?, httpStatusCode: Int) -> BSErrors {
        
        var resultError : BSErrors = .invalidInput
        let errStr : String? = extractError(data: data)
        
        if (errStr == "EXPIRED_TOKEN") {
            resultError = .expiredToken
        } else if (errStr == "INVALID_CC_NUMBER") {
            resultError = .invalidCcNumber
        } else if (errStr == "INVALID_CVV") {
            resultError = .invalidCvv
        } else if (errStr == "INVALID_EXP_DATE") {
            resultError = .invalidExpDate
        } else if (BSStringUtils.startsWith(theString: errStr ?? "", subString: "TOKEN_WAS_ALREADY_USED_FOR_")) {
            resultError = .tokenAlreadyUsed
        } else if (errStr == "PAYPAL_UNSUPPORTED_CURRENCY") {
            resultError = .paypalUnsupportedCurrency
        } else if (errStr == "TOKEN_NOT_FOUND") {
            resultError = .tokenNotFound
        } else if httpStatusCode == 401 {
            resultError = .unAuthorised
        }        
        return resultError
    }

    private static func extractError(data: Data?) -> String {
        
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
        }
        return errStr ?? ""
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
}
