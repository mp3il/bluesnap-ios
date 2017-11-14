//
//  DemoTransactions.swift
//  BluesnapSDKExample
//
// This file contains the functionality of creating a BlueSnap transaction using
// the payment details we got from BlueSnap SDK. This will only work on BlueSnap
// Sandbox for demo purposes; in your real application, this part should be implemented
// on your server code - you should call BlueSnap server-to-server and not from the app,
// otherwise you'll be compromising your authentication details.
//
//  Created by Shevie Chen on 30/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation
import BluesnapSDK

class DemoTreansactions {
    
    static let BS_SANDBOX_TEST_USER : String  = "sdkuser"
    static let BS_SANDBOX_TEST_PASS : String  = "SDKuser123"
//    static let BS_SANDBOX_TEST_USER = "HostedPapi"
//    static let BS_SANDBOX_TEST_PASS = "Plimus12345"


    func createApplePayTransaction(purchaseDetails: BSApplePaySdkResult!,
                                   bsToken: BSToken!,
                                   completion: @escaping (_ success: Bool, _ data: String?) -> Void) {

        var requestBody = [
                "recurringTransaction": "ECOMMERCE",
                "softDescriptor": "MobileSDKtest",
                "cardTransactionType": "AUTH_CAPTURE",
                "amount": "\(purchaseDetails.getAmount()!)",
                "currency": "\(purchaseDetails.getCurrency()!)",
                "pfToken": "\(bsToken.getTokenStr()!)",
        ] as [String: Any]
        if let fraudSessionId: String = purchaseDetails.getFraudSessionId() {
            requestBody["transactionFraudInfo"] = ["fraudSessionId": fraudSessionId]
        }
        print("requestBody= \(requestBody)")
        let authorization = getBasicAuth()

        let urlStr = bsToken.getServerUrl() + "services/2/transactions";
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
        } catch let error {
            NSLog("Error serializing CC details: \(error.localizedDescription)")
        }


        // fire request

        var result: (success: Bool, data: String?) = (success: false, data: nil)

        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let error = error {
                NSLog("error calling create transaction: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode: Int = (httpResponse?.statusCode) {

                    if let data = data {
                        result.data = String(data: data, encoding: .utf8)
                        NSLog("Response body = \(result.data ?? "Empty")")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.success = true
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                DispatchQueue.main.async {
                    completion(result.success, result.data)
                }
            }
        }
        task.resume()
    }


    func createCreditCardTransaction(
        purchaseDetails: BSCcSdkResult!,
        bsToken: BSToken!,
        completion: @escaping (_ success: Bool, _ data: String?)->Void) {
        
        let name = purchaseDetails.getBillingDetails().getSplitName()!
        
        var cardHolderInfo: [String:String] = [
            "firstName": "\(name.firstName)",
            "lastName": "\(name.lastName)"
        ]
        if let zip = purchaseDetails.getBillingDetails().zip {
            cardHolderInfo["zip"] = "\(zip)"
        }
        var requestBody = [
            "amount": "\(purchaseDetails.getAmount()!)",
            "recurringTransaction": "ECOMMERCE",
            "softDescriptor": "MobileSDKtest",
            "cardHolderInfo": cardHolderInfo,
            "currency": "\(purchaseDetails.getCurrency()!)",
            "cardTransactionType": "AUTH_CAPTURE",
            "pfToken": "\(bsToken.getTokenStr()!)",
        ] as [String : Any]
        if let fraudSessionId: String = purchaseDetails.getFraudSessionId() {
            requestBody["transactionFraudInfo"] = ["fraudSessionId": fraudSessionId]
        }
        print("requestBody= \(requestBody)")
        let authorization = getBasicAuth()
        
        let urlStr = bsToken.getServerUrl() + "services/2/transactions";
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
        } catch let error {
            NSLog("Error serializing CC details: \(error.localizedDescription)")
        }
        
        
        // fire request
        
        var result : (success:Bool, data: String?) = (success:false, data: nil)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error calling create transaction: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    
                    if let data = data {
                        result.data = String(data: data, encoding: .utf8)
                        NSLog("Response body = \(result.data ?? "")")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.success = true
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                DispatchQueue.main.async {
                    completion(result.success, result.data)
                }
            }
        }
        task.resume()
    }
    
    /**
    Here all the data is on the token, we only need to send amoutn and currency
     */
    func createTokenizedTransaction(
        purchaseDetails: BSCcSdkResult!,
        bsToken: BSToken!,
        completion: @escaping (_ success: Bool, _ data: String?)->Void) {
        
        var requestBody = [
            "amount": "\(purchaseDetails.getAmount()!)",
            "recurringTransaction": "ECOMMERCE",
            "softDescriptor": "MobileSDKtest",
            "currency": "\(purchaseDetails.getCurrency()!)",
            "cardTransactionType": "AUTH_CAPTURE",
            "pfToken": "\(bsToken.getTokenStr()!)",
            ] as [String : Any]
        print("requestBody= \(requestBody)")
        let authorization = getBasicAuth()
        
        let urlStr = bsToken.getServerUrl() + "services/2/transactions";
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
        } catch let error {
            NSLog("Error serializing CC details: \(error.localizedDescription)")
        }
        
        // fire request
        
        var result : (success:Bool, data: String?) = (success:false, data: nil)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error calling create transaction: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    
                    if let data = data {
                        result.data = String(data: data, encoding: .utf8)
                        NSLog("Response body = \(result.data ?? "")")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.success = true
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                DispatchQueue.main.async {
                    completion(result.success, result.data)
                }
            }
        }
        task.resume()
    }
    
    func createCreditCardTransactionWithXml(
        purchaseDetails: BSCcSdkResult!,
        bsToken: BSToken!,
        completion: @escaping (_ success:Bool, _ data: String?)->Void) {
        
        let name = purchaseDetails.getBillingDetails().getSplitName()!
        let bodyStart: String = "<card-transaction xmlns=\"http://ws.plimus.com\">" +
            "<card-transaction-type>AUTH_CAPTURE</card-transaction-type>" +
            "<recurring-transaction>ECOMMERCE</recurring-transaction>" +
            "<soft-descriptor>MobileSDK</soft-descriptor>" +
            "<amount>\(purchaseDetails.getAmount()!)</amount>" +
        "<currency>\(purchaseDetails.getCurrency()!)</currency>"
        
        var fraudInfoXML : String = ""
        if let fraudSessionId: String = purchaseDetails.getFraudSessionId() {

            fraudInfoXML = "<transaction-fraud-info>" +
                "<fraud-session-id>" + fraudSessionId + "</fraud-session-id>" +
                "</transaction-fraud-info>"
        }

        let bodyMiddle: String = "<card-holder-info>" +
            "<first-name>\(name.firstName)</first-name>" +
            "<last-name>\(name.lastName)</last-name>" +
        "</card-holder-info>"

        let bodyEnd: String = "</card-transaction>" + fraudInfoXML
        let requestBody: String = bodyStart + bodyMiddle + "<pf-token>\(bsToken.getTokenStr()!)</pf-token>" + bodyEnd
        print("requestBody= \(requestBody)")
        let authorization = getBasicAuth()
        
        
        let urlStr = bsToken.getServerUrl() + "services/2/transactions";
        let url = NSURL(string: urlStr)!
        var request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = requestBody.data(using: String.Encoding.utf8)
        
        // fire request
        
        var result : (success:Bool, data: String?) = (success:false, data: nil)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                NSLog("error calling create transaction: \(error.localizedDescription)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let httpStatusCode:Int = (httpResponse?.statusCode) {
                    
                    if let data = data {
                        result.data = String(data: data, encoding: .utf8)
                        NSLog("Response body = \(result.data ?? "Empty")")
                    }
                    if (httpStatusCode >= 200 && httpStatusCode <= 299) {
                        result.success = true
                    } else {
                        NSLog("Http error Creating BS Transaction; HTTP status = \(httpStatusCode)")
                    }
                }
            }
            defer {
                DispatchQueue.main.async {
                    completion(result.success, result.data)
                }
            }
        }
        task.resume()
    }

    /**
     Build the basic authentication header from username/password
     */
    func getBasicAuth() -> String {
        
        let loginStr = String(format: "%@:%@", DemoTreansactions.BS_SANDBOX_TEST_USER, DemoTreansactions.BS_SANDBOX_TEST_PASS)
        let loginData = loginStr.data(using: String.Encoding.utf8)!
        let base64LoginStr = loginData.base64EncodedString()
        return "Basic \(base64LoginStr)"
    }

}
