//
// Created by oz on 15/06/2017.
// Copyright (c) 2017 Bluesnap. All rights reserved.
//

import Foundation

import UIKit
import PassKit


//TODO: we can split the delagate from the controller
extension BSStartViewController : PaymentOperationDelegate {


    func applePayPressed(_ sender: Any, completion: @escaping (BSErrors?) -> Void) {

        let priceDetails = initialData.priceDetails!
        let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(floatLiteral: priceDetails.taxAmount), type: .final)
        let total = PKPaymentSummaryItem(label: "Payment", amount: NSDecimalNumber(floatLiteral: priceDetails.amount), type: .final)

        paymentSummaryItems = [tax, total];

        let pkPaymentRequest = PKPaymentRequest()
        pkPaymentRequest.paymentSummaryItems = paymentSummaryItems;
        pkPaymentRequest.merchantIdentifier = BSApplePayConfiguration.getIdentifier()
        pkPaymentRequest.merchantCapabilities = .capability3DS
        pkPaymentRequest.countryCode = "US"
        pkPaymentRequest.currencyCode = priceDetails.currency

        if initialData.withShipping {
            pkPaymentRequest.requiredShippingAddressFields = [.email, .phone, .postalAddress]
        }
        if initialData.fullBilling {
            pkPaymentRequest.requiredBillingAddressFields = [.postalAddress]
        }

        pkPaymentRequest.supportedNetworks = [
                .amex,
                .discover,
                .masterCard,
                .visa
        ]


        // set up the operation with the paymaket request
        let paymentOperation = PaymentOperation(request: pkPaymentRequest);

        paymentOperation.delegate = self;

        paymentOperation.completionBlock = {[weak op = paymentOperation] in
            NSLog("PK payment completion \(op?.error.debugDescription ?? "No op")")
            DispatchQueue.main.async {
                completion(op?.error)
            }
        };

        //Send the payment operation via queue
        InternalQueue.addOperation(paymentOperation);

    }

    func setupPressed(sender: AnyObject) {
        let passLibrary = PKPassLibrary();
        passLibrary.openPaymentSetup();
    }

    func validate(payment: PKPayment, completion: @escaping (PaymentValidationResult) -> Void) {
        DispatchQueue.main.async {
            completion(.valid);
        }
    }

    func send(paymentInformation: BSApplePayInfo, completion: @escaping (BSErrors?) -> Void) {
        if let jsonData = try? String(data: paymentInformation.toJSON(), encoding: .utf8)!.data(using: String.Encoding.utf8)!.base64EncodedString() {

            //print(String(data: paymentInformation.toJSON(), encoding: .utf8)!)
            BSApiManager.submitApplepayData(data: jsonData, completion: { (result, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                    debugPrint(error.localizedDescription)
                    return
                }
                DispatchQueue.main.async {
                    completion(nil) // no result from BS on 200
                }
            }
            )
        } else {
            NSLog("PaymentInformation parse error")
            DispatchQueue.main.async {
                completion(BSErrors.applePayOperationError)
            }
            return
        }
    }

    func didSelectPaymentMethod(method: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {
        DispatchQueue.main.async {
            completion(self.paymentSummaryItems);
        }
    }
    
    func didSelectShippingContact(contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        DispatchQueue.main.async {
            completion(.success, [], self.paymentSummaryItems);
        }
    }
}


