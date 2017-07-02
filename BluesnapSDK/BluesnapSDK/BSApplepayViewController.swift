//
// Created by oz on 15/06/2017.
// Copyright (c) 2017 Bluesnap. All rights reserved.
//

import Foundation

import UIKit
import PassKit


//TODO: we can split the delagate from the controller
extension BSStartViewController : PaymentOperationDelegate {


    func applePayPressed(_ sender: Any, completion: @escaping (Error?) -> Void) {

        let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(floatLiteral: paymentRequest.getTaxAmount()), type: .final)
        let total = PKPaymentSummaryItem(label: "Payment", amount: NSDecimalNumber(floatLiteral: paymentRequest.getAmount()), type: .final)

        paymentSummaryItems = [tax, total];

        let pkPaymentRequest = PKPaymentRequest()
        pkPaymentRequest.paymentSummaryItems = paymentSummaryItems;
        pkPaymentRequest.merchantIdentifier = BSApplePayConfiguration.getIdentifier()
        pkPaymentRequest.merchantCapabilities = .capability3DS
        pkPaymentRequest.countryCode = "US"
        pkPaymentRequest.currencyCode = paymentRequest.getCurrency()

        if self.withShipping {
            pkPaymentRequest.requiredShippingAddressFields = [.email, .phone, .postalAddress]
        }
        //if self.fullBilling {
            pkPaymentRequest.requiredBillingAddressFields = [.postalAddress]
        //}

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
            completion(nil)
        };

        //Send the payment operation via queue
        InternalQueue.addOperation(paymentOperation);

    }

    func setupPressed(sender: AnyObject) {
        let passLibrary = PKPassLibrary();
        passLibrary.openPaymentSetup();
    }

    func validate(payment: PKPayment, completion: @escaping (PaymentValidationResult) -> Void) {
        completion(.valid);
    }

    func send(paymentInformation: BSApplePayInfo, completion: @escaping (Error?) -> Void) {
        let jsonData = String(data: paymentInformation.toJSON(), encoding: .utf8)!.data(using: String.Encoding.utf8)!.base64EncodedString()
        print(String(data: paymentInformation.toJSON(), encoding: .utf8)!)
        BSApiManager.submitApplepayData(data: jsonData, completion: { (result, error) in
            if let error = error {
                completion(error)
                debugPrint(error.localizedDescription)
                return
            }
            completion(nil) // no result from BS on 200
        }
        )

    }

    func didSelectPaymentMethod(method: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {
        completion(self.paymentSummaryItems);
    }
    func didSelectShippingContact(contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        completion(.success, [], self.paymentSummaryItems);
    }
}


