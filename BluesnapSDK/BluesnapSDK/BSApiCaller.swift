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

@objc class BSApiCaller: NSObject {
    
    internal static let PAYPAL_SERVICE = "services/2/tokenized-services/paypal-token?amount="
    internal static let PAYPAL_SHIPPING = "&req-confirm-shipping=0&no-shipping=2"
    internal static let TOKENIZED_SERVICE = "services/2/payment-fields-tokens/"
    internal static let BLUESNAP_VERSION_HEADER = "BLUESNAP_VERSION_HEADER"
    internal static let BLUESNAP_VERSION_HEADER_VAL = "2.0"
    internal static let SDK_VERSION_HEADER = "BLUESNAP_ORIGIN_HEADER"
    internal static let SDK_VERSION_HEADER_VAL = "IOS SDK 0.2.0"

    private static func createRequest(_ urlStr: String, bsToken: BSToken!) -> NSMutableURLRequest {

        let url = NSURL(string: urlStr)!
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(bsToken!.tokenStr, forHTTPHeaderField: "Token-Authentication")
        request.setValue(BLUESNAP_VERSION_HEADER_VAL, forHTTPHeaderField: BLUESNAP_VERSION_HEADER)
        request.setValue(SDK_VERSION_HEADER_VAL, forHTTPHeaderField: SDK_VERSION_HEADER)
        return request
    }
    
    /**
     Fetch all the initial data required for the SDK from BlueSnap server:
     - BlueSnap Kount MID
     - Exchange rates
     - Returning shopper data
     - Supported Payment methods
     
     - parameters:
     - bsToken: a token for BlueSnap tokenized services
     - baseCurrency: optional base currency for currency rates; default = USD
     - completion: a callback function to be called once the data is fetched; receives optional data and optional error
     */
    static func getSdkData(bsToken: BSToken!, baseCurrency: String?, completion: @escaping (BSSdkConfiguration?, BSErrors?) -> Void) {
        
        let urlStr = bsToken.serverUrl + "services/2/tokenized-services/sdk-init?base-currency=" + (baseCurrency ?? "USD")
        let request = createRequest(urlStr, bsToken: bsToken)
        
        // fire request
        
        var sdkConfig : BSSdkConfiguration?
        var resultError: BSErrors?
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response, error) in
            if let error = error {
                let errorType = type(of: error)
                NSLog("error getting supportedPaymentMethods - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
                resultError = .unknown
            } else {
                let httpStatusCode:Int? = (response as? HTTPURLResponse)?.statusCode
                if (httpStatusCode != nil && httpStatusCode! >= 200 && httpStatusCode! <= 299) {
                    (sdkConfig, resultError) = parseSdkDataJSON(data: data)
                } else {
                    resultError = parseHttpError(data: data, httpStatusCode: httpStatusCode)
                }
            }
            defer {
                completion(sdkConfig, resultError)
            }
        }
        task.resume()
    }
    
    private static func parseSdkDataJSON(data: Data?) -> (BSSdkConfiguration?, BSErrors?) {
        
        var resultData: BSSdkConfiguration?
        var resultError: BSErrors?
        
        if let data = data {
            do {
                // Parse the result JSOn object
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                    
                    resultData = BSSdkConfiguration()
                    if let kountMID = json["kountMerchantId"] as? Int {
                        resultData?.kountMID = kountMID
                    }
                    if let rates = json["rates"] as? [String: AnyObject] {
                        let currencies = parseCurrenciesJSON(json: rates)
                        resultData?.currencies = currencies
                    }
                    if let shopper = json["shopper"] as? [String: AnyObject] {
                        let shopper = parseShopperJSON(json: shopper)
                        resultData?.shopper = shopper
                    }
                    if let supportedPaymentMethods = json["supportedPaymentMethods"] as? [String: AnyObject] {
                        let methods = parseSupportedPaymentMethodsJSON(json: supportedPaymentMethods)
                        resultData?.supportedPaymentMethods = methods
                    }

                } else {
                    resultError = .unknown
                    NSLog("Error parsing BS currency rates")
                }
            } catch let error as NSError {
                resultError = .unknown
                NSLog("Error parsing BS currency rates: \(error.localizedDescription)")
            }
        } else {
            resultError = .unknown
            NSLog("No BS currency data exists")
        }
        return (resultData, resultError)
    }
    

    /**
     Get BlueSnap Token from BlueSnap server
     Normally you will not do this from the app.
     
     - parameters:
     - user: username
     - password: password
     - completion: callback function for after the token is created; recfeives optional token and optional error
     */
    internal static func createSandboxBSToken(shopperId: Int?, user: String, password: String, completion: @escaping (BSToken?, BSErrors?) -> Void) {

        let domain: String = BSApiManager.BS_SANDBOX_DOMAIN
        
        // create request
        let authorization = getBasicAuth(user: user, password: password)
        var urlStr = domain + "services/2/payment-fields-tokens"
        if let shopperId = shopperId {
            urlStr = urlStr + "?shopperId=\(shopperId)"
        }
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        //request.timeoutInterval = 60
        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.setValue("0", forHTTPHeaderField: "Content-Length")
        request.setValue(BLUESNAP_VERSION_HEADER_VAL, forHTTPHeaderField: BLUESNAP_VERSION_HEADER)
        request.setValue(SDK_VERSION_HEADER_VAL, forHTTPHeaderField: SDK_VERSION_HEADER)

        // fire request
        
        var result: BSToken?
        var resultError: BSErrors?
        NSLog("BlueSnap; createSandboxBSToken")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            NSLog("BlueSnap; createSandboxBSToken completion")
            if let error = error {
                let errorType = type(of: error)
                NSLog("error getting BSToken - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
                resultError = .unknown
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode: Int = (httpResponse?.statusCode) {
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result = extractTokenFromResponse(httpResponse: httpResponse)
                        if let result = result {
                            NSLog("createSandboxBSToken result: \(result.tokenStr)")
                        } else {
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
                completion(result, resultError)
            }
        }
        task.resume()
    }
    
    /**
     Calls BlueSnap server to create a PayPal token
     - parameters:
     - bsToken: a token for BlueSnap tokenized services
     - purchaseDetails: details of the purchase: specifically amount and currency are used
     - withShipping: setting for the PayPal flow - do we want to request shipping details from the shopper
     - completion: a callback function to be called once the PayPal token is fetched; receives optional PayPal Token string data and optional error
    */
    static func createPayPalToken(bsToken: BSToken!, purchaseDetails: BSPayPalSdkResult, withShipping: Bool, completion: @escaping (String?, BSErrors?) -> Void) {
        
        var urlStr = bsToken.serverUrl + PAYPAL_SERVICE  + "\(purchaseDetails.getAmount() ?? 0)" + "&currency=" + purchaseDetails.getCurrency()
        if withShipping {
            urlStr += PAYPAL_SHIPPING
        }
        
        NSLog("Calling \(urlStr)")
        let request = createRequest(urlStr, bsToken: bsToken)

        // fire request
        
        var resultToken: String?
        var resultError: BSErrors?
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                let errorType = type(of: error)
                NSLog("error creating PayPal token - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
            }  else {
                let httpStatusCode:Int? = (response as? HTTPURLResponse)?.statusCode
                if (httpStatusCode != nil && httpStatusCode! >= 200 && httpStatusCode! <= 299) {
                    (resultToken, resultError) = parsePayPalTokenJSON(data: data)
                } else {
                    resultError = parseHttpError(data: data, httpStatusCode: httpStatusCode)
                }
            }
            defer {
                completion(resultToken, resultError)
            }
        }
        task.resume()
    }
    
    
    /**
     Fetch a list of merchant-supported payment methods from BlueSnap server
     - parameters:
     - bsToken: a token for BlueSnap tokenized services
     - completion: a callback function to be called once the data is fetched; receives optional payment method list and optional error
     */
    static func getSupportedPaymentMethods(bsToken: BSToken!, completion: @escaping ([String]?, BSErrors?) -> Void) {
        
        let urlStr = bsToken.serverUrl + "services/2/tokenized-services/supported-payment-methods"
        let request = createRequest(urlStr, bsToken: bsToken)

        // fire request
        
        var supportedPaymentMethods: [String]?
        var resultError: BSErrors?
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response, error) in
            if let error = error {
                let errorType = type(of: error)
                NSLog("error getting supportedPaymentMethods - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
                resultError = .unknown
            } else {
                let httpStatusCode:Int? = (response as? HTTPURLResponse)?.statusCode
                if (httpStatusCode != nil && httpStatusCode! >= 200 && httpStatusCode! <= 299) {
                    (supportedPaymentMethods, resultError) = parsePaymentMethodsData(data: data)
                } else {
                    resultError = parseHttpError(data: data, httpStatusCode: httpStatusCode)
                }
            }
            defer {
                completion(supportedPaymentMethods, resultError)
            }
        }
        task.resume()
    }

    /**
    Submit payment fields to BlueSnap
    */
    static func submitPaymentDetails(bsToken: BSToken!,
                                    requestBody: [String: String],
                                    parseFunction: @escaping (Int, Data?) -> ([String:String],BSErrors?),
                                    completion: @escaping ([String:String], BSErrors?) -> Void) {
        
        let domain: String! = bsToken!.serverUrl
        // If you want to test expired token, use this:
        //let urlStr = domain + TOKENIZED_SERVICE + "fcebc8db0bcda5f8a7a5002ca1395e1106ea668f21200d98011c12e69dd6bceb_"
        let urlStr = domain + TOKENIZED_SERVICE + bsToken!.getTokenStr()
        var request = createRequest(urlStr, bsToken: bsToken)
        request.httpMethod = "PUT"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
        } catch let error {
            NSLog("Error serializing CC details: \(error.localizedDescription)")
        }

        // fire request
        
        var resultError: BSErrors?
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            var resultData: [String:String] = [:]
            if let error = error {
                let errorType = type(of: error)
                NSLog("error submitting BS Payment details - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
                completion(resultData, .unknown)
                return
            }
            let httpResponse = response as? HTTPURLResponse
            if let httpStatusCode: Int = (httpResponse?.statusCode) {
                (resultData, resultError) = parseFunction(httpStatusCode, data)
            } else {
                NSLog("Error getting response from BS on submitting Payment details")
            }
            defer {
                completion(resultData, resultError)
            }
        }
        task.resume()
    }
    
    
    static func parseCCResponse(httpStatusCode: Int, data: Data?) -> ([String:String], BSErrors?) {
        
        var resultData: [String:String] = [:]
        var resultError: BSErrors?
        
        if (httpStatusCode >= 200 && httpStatusCode <= 299) {
            (resultData, resultError) = parseResultCCDetailsFromResponse(data: data)
        } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
            resultError = parseHttpError(data: data, httpStatusCode: httpStatusCode)
        } else {
            NSLog("Http error submitting CC details to BS; HTTP status = \(httpStatusCode)")
            resultError = .unknown
        }
        return (resultData, resultError)
    }
    
    static func parseGenericResponse(httpStatusCode: Int, data: Data?) -> ([String:String], BSErrors?) {
        
        var resultData: [String:String] = [:]
        var resultError: BSErrors?
        
        if (httpStatusCode >= 200 && httpStatusCode <= 299) {
            
        } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
            resultError = parseHttpError(data: data, httpStatusCode: httpStatusCode)
        } else {
            NSLog("Http error submitting CC details to BS; HTTP status = \(httpStatusCode)")
            resultError = .unknown
        }
        return (resultData, resultError)
    }

    static func parseResultCCDetailsFromResponse(data: Data?) -> ([String:String], BSErrors?) {
        
        var resultData: [String:String] = [:]
        var resultError: BSErrors? = nil
        if let data = data {
            if !data.isEmpty {
                do {
                    // Parse the result JSOn object
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                        resultData["ccType"] = json["ccType"] as? String
                        resultData["last4Digits"] = json["last4Digits"] as? String
                        resultData["ccIssuingCountry"] = (json["issuingCountry"] as? String ?? "").uppercased()
                    } else {
                        NSLog("Error parsing BS result on CC details submit")
                        resultError = .unknown
                    }
                } catch let error as NSError {
                    NSLog("Error parsing BS result on CC details submit: \(error.localizedDescription)")
                    resultError = .unknown
                }
            }
        }
        return (resultData, resultError)
    }
    
    
    internal static func parseApplePayResponse(httpStatusCode: Int, data: Data?) -> ([String:String], BSErrors?) {
        
        let resultData: [String:String] = [:]
        var resultError: BSErrors?
        
        if (httpStatusCode >= 200 && httpStatusCode <= 299) {
            NSLog("ApplePay data submitted successfully")
        } else if (httpStatusCode >= 400 && httpStatusCode <= 499) {
            resultError = parseHttpError(data: data, httpStatusCode: httpStatusCode)
        } else {
            NSLog("Http error submitting ApplePay details to BS; HTTP status = \(httpStatusCode)")
            resultError = .unknown
        }
        return (resultData, resultError)
    }

    
    /**
     This function checks if a token is expired by trying to submit payment fields,
     then checking the response.
    */
    static func isTokenExpired(bsToken: BSToken?, completion: @escaping (Bool) -> Void) {
        
        if let bsToken = bsToken {
            
            // create request
            let urlStr = bsToken.serverUrl + TOKENIZED_SERVICE + bsToken.getTokenStr()
            var request = createRequest(urlStr, bsToken: bsToken)
            request.httpMethod = "PUT"
            do {
                let requestBody = ["dummy":"check:"]
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            } catch let error {
                NSLog("Error serializing CC details: \(error.localizedDescription)")
            }
            
            // fire request
            
            var result: Bool = false
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                var resultData: [String:String] = [:]
                if let error = error {
                    let errorType = type(of: error)
                    NSLog("error submitting to check if token is expired - \(errorType) for URL \(urlStr). Error: \(error.localizedDescription)")
                    return
                }
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode: Int = (httpResponse?.statusCode) {
                    if httpStatusCode == 400 {
                        let errStr = extractError(data: data)
                        result = errStr == "EXPIRED_TOKEN" || errStr == "TOKEN_NOT_FOUND"
                    }
                } else {
                    NSLog("Error getting response from BS on check if token is expired")
                }
                defer {
                    completion(result)
                }
            }
            task.resume()
        } else {
            completion(true)
        }
    }

    // MARK: private functions
    
    
    private static func parseHttpError(data: Data?, httpStatusCode: Int?) -> BSErrors {
        
        var resultError : BSErrors = .invalidInput
        let errStr : String? = extractError(data: data)
        
        if (httpStatusCode != nil && httpStatusCode! >= 400 && httpStatusCode! <= 499) {
            if (errStr == "EXPIRED_TOKEN") {
                resultError = .expiredToken
            } else if (errStr == "INVALID_CC_NUMBER") {
                resultError = .invalidCcNumber
            } else if (errStr == "INVALID_CVV") {
                resultError = .invalidCvv
            } else if (errStr == "INVALID_EXP_DATE") {
                resultError = .invalidExpDate
            } else if (errStr == "CARD_TYPE_NOT_SUPPORTED") {
                resultError = .cardTypeNotSupported
            } else if (BSStringUtils.startsWith(theString: errStr ?? "", subString: "TOKEN_WAS_ALREADY_USED_FOR_")) {
                resultError = .tokenAlreadyUsed
            } else if httpStatusCode == 403 && errStr == "Unauthorized" {
                resultError = .tokenAlreadyUsed // PayPal
            } else if (errStr == "PAYPAL_UNSUPPORTED_CURRENCY") {
                resultError = .paypalUnsupportedCurrency
            } else if (errStr == "TOKEN_NOT_FOUND") {
                resultError = .tokenNotFound
            } else if httpStatusCode == 401 {
                resultError = .unAuthorised
            }
        } else {
            resultError = .unknown
            NSLog("Http error; HTTP status = \(httpStatusCode)")
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
    
    private static func parseCurrenciesJSON(json: [String: AnyObject]) -> BSCurrencies {
        
        var currencies: [BSCurrency] = []
        var baseCurrency = "USD"
        if let currencyName = json["baseCurrencyName"] as? String
            , let currencyCode = json["baseCurrency"] as? String {
            let bsCurrency = BSCurrency(name: currencyName, code: currencyCode, rate: 1.0)
            currencies.append(bsCurrency)
            baseCurrency = currencyCode
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
        return BSCurrencies(baseCurrency: baseCurrency, currencies: currencies)
    }
    
    private static func parseShopperJSON(json: [String: AnyObject]) -> BSShopper {
        
        let shopper = BSShopper()
        if let firstName = json["firstName"] as? String
            , let lastName = json["lastName"] as? String {
            shopper.name = firstName + " " + lastName
        }
        if let email = json["email"] as? String {
            shopper.email = email
        }
        if let country = json["country"] as? String {
            shopper.countryCode = country
        }
        if let state = json["state"] as? String {
            shopper.stateCode = state
        }
        if let address = json["address"] as? String {
            shopper.address = address
        }
        if let address2 = json["address2"] as? String {
            if (shopper.address == nil) {
                shopper.address = address2
            } else {
                shopper.address = shopper.address! + " " + address2
            }
        }
        if let city = json["city"] as? String {
            shopper.city = city
        }
        if let zip = json["zip"] as? String {
            shopper.zip = zip
        }
        if let phone = json["phone"] as? String {
            shopper.phone = phone
        }
        if let shipping = json["shippingContactInfo"] as? [String: AnyObject] {
            let shippingDetails = BSShippingAddressDetails()
            shopper.shippingDetails = shippingDetails
            if let firstName = shipping["firstName"] as? String
                , let lastName = shipping["lastName"] as? String {
                shippingDetails.name = firstName + " " + lastName
            }
            if let country = shipping["country"] as? String {
                shippingDetails.country = country
            }
            if let state = shipping["state"] as? String {
                shippingDetails.state = state
            }
            if let address = shipping["address1"] as? String {
                shippingDetails.address = address
            }
            if let address2 = shipping["address2"] as? String {
                if (shopper.address == nil) {
                    shippingDetails.address = address2
                } else {
                    shippingDetails.address = shopper.address! + " " + address2
                }
            }
            if let city = shipping["city"] as? String {
                shippingDetails.city = city
            }
            if let zip = shipping["zip"] as? String {
                shippingDetails.zip = zip
            }
            if let phone = shipping["phone"] as? String {
                shippingDetails.phone = phone
            }
        }
        if let paymentSources = json["paymentSources"] as? [String: AnyObject] {
            if let creditCardInfo = paymentSources["creditCardInfo"] as? [[String: AnyObject]] {
                for ccDetailsJson in creditCardInfo {
                    var billingDetails : BSBillingAddressDetails?
                    if let billingContactInfo = ccDetailsJson["billingContactInfo"] as? [String: AnyObject] {
                        billingDetails = BSBillingAddressDetails()
                        if let firstName = billingContactInfo["firstName"] as? String
                            , let lastName = billingContactInfo["lastName"] as? String {
                            billingDetails?.name = firstName + " " + lastName
                        }
                        if let country = billingContactInfo["country"] as? String {
                            billingDetails?.country = country
                        }
                        if let state = billingContactInfo["state"] as? String {
                            billingDetails?.state = state
                        }
                        if let address = billingContactInfo["address1"] as? String {
                            billingDetails?.address = address
                        }
                        if let address2 = billingContactInfo["address2"] as? String {
                            if (shopper.address == nil) {
                                billingDetails?.address = address2
                            } else {
                                billingDetails?.address = shopper.address! + " " + address2
                            }
                        }
                        if let city = billingContactInfo["city"] as? String {
                            billingDetails?.city = city
                        }
                        if let zip = billingContactInfo["zip"] as? String {
                            billingDetails?.zip = zip
                        }
                    }
                    let cc = BSCreditCard()
                    if let creditCardJson = ccDetailsJson["creditCard"] as? [String: AnyObject] {
                        if let cardLastFourDigits = creditCardJson["cardLastFourDigits"] as? String {
                            cc.last4Digits = cardLastFourDigits
                        }
                        if let cardType = creditCardJson["cardType"] as? String {
                            cc.ccType = cardType
                        }
                        if let expirationMonth = creditCardJson["expirationMonth"] as? String, let expirationYear = creditCardJson["expirationYear"] as? String {
                            cc.expirationMonth = expirationMonth
                            cc.expirationYear = expirationYear
                        }
                    }
                    // add the CC only if it's not expired
                    let validCc : (Bool, String) = BSValidator.isCcValidExpiration(mm: cc.expirationMonth ?? "", yy: cc.expirationYear ?? "")
                    if validCc.0 {
                        let ccInfo = BSCreditCardInfo(creditCard: cc, billingDetails: billingDetails)
                        shopper.existingCreditCards.append(ccInfo)
                    }
                }
            }
        }
        return shopper
    }

    private static func parsePayPalTokenJSON(data: Data?) -> (String?, BSErrors?) {
        
        var resultToken: String?
        var resultError: BSErrors?
        
        if let data = data {
            do {
                // Parse the result JSOn object
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                    resultToken = json["paypalUrl"] as? String
                } else {
                    resultError = .unknown
                    NSLog("Error parsing BS result on getting PayPal Token")
                }
            } catch let error as NSError {
                resultError = .unknown
                NSLog("Error parsing BS result on getting PayPal Token: \(error.localizedDescription)")
            }
        } else {
            resultError = .unknown
            NSLog("No data in BS result on getting PayPal Token")
        }
        
        return (resultToken, resultError)
    }
    
    private static func parsePaymentMethodsData(data: Data?) -> ([String]?, BSErrors?)  {
        
        var resultArr: [String]?
        var resultError: BSErrors?
        if let data = data {
            do {
                // Parse the result JSOn object
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                    resultArr = parseSupportedPaymentMethodsJSON(json: json)
                } else {
                    resultError = .unknown
                    NSLog("Error parsing BS Supported Payment Methods")
                }
            } catch let error as NSError {
                resultError = .unknown
                NSLog("Error parsing Bs Supported Payment Methods: \(error.localizedDescription)")
            }
        } else {
            resultError = .unknown
            NSLog("No BS Supported Payment Methods data exists")
        }
        return (resultArr, resultError)
    }
    
    private static func parseSupportedPaymentMethodsJSON(json: [String: AnyObject]) -> [String]?  {

        // insert SDKInit Regex data to the cardTypeRegex Validator while maintaining order
        if let cardTypesRegex = json["creditCardRegex"] as? [String: String] {
            var index: Int = 0
            for (k,v) in cardTypesRegex {
                BSValidator.cardTypesRegex[index] = (cardType: k, regexp: v)
                index += 1
            }

        }

        var resultArr: [String]?
        if let arr = json["paymentMethods"] as? [String] {
            resultArr = arr
        }
         return resultArr
    }
    
    private static func extractTokenFromResponse(httpResponse: HTTPURLResponse?) -> BSToken? {
        
        var result: BSToken?
        if let location: String = httpResponse?.allHeaderFields["Location"] as? String {
            if let lastIndexOfSlash = location.range(of: "/", options: String.CompareOptions.backwards, range: nil, locale: nil) {
                let tokenStr = location.substring(with: lastIndexOfSlash.upperBound..<location.endIndex)
                result = BSToken(tokenStr: tokenStr)
            } else {
                NSLog("Error: BS Token does not contain /")
            }
        } else {
            NSLog("Error: BS Token does not appear in response headers")
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


}
