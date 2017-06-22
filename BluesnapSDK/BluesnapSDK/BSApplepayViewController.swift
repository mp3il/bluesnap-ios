//
// Created by oz on 15/06/2017.
// Copyright (c) 2017 Bluesnap. All rights reserved.
//

import Foundation

import UIKit
import PassKit


//TODO: we can split the delagate from the controller
extension BSStartViewController : PaymentOperationDelegate {


    func payPressed(_ sender: Any) {

        let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(floatLiteral: paymentRequest.getTaxAmount()), type: .final)
        let total = PKPaymentSummaryItem(label: "Payment", amount: NSDecimalNumber(floatLiteral: paymentRequest.getAmount()), type: .final)

        paymentSummaryItems = [tax, total];

        let pkPaymentRequest = PKPaymentRequest()
        pkPaymentRequest.paymentSummaryItems = paymentSummaryItems;
        pkPaymentRequest.merchantIdentifier = BSApplePayConfiguration.Merchant.identifier
        pkPaymentRequest.merchantCapabilities = .capability3DS
        pkPaymentRequest.countryCode = "US"
        pkPaymentRequest.currencyCode = paymentRequest.getCurrency()

        if self.withShipping {
            pkPaymentRequest.requiredShippingAddressFields = [.email, .phone, .postalAddress]
        }
        if self.fullBilling {
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
            NSLog("PK payment completion \(op?.error)")
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
        NSLog("Send to server");
        let url = URL(string: "https://api.bluesnap.com/services/2")!;
        var request = URLRequest(url: url);
        //TODO: set API token
        request.addValue("Bearer APITOOKEN", forHTTPHeaderField: "Authorization");
        //TODO: remove this log
        print(paymentInformation.toDictionary());
        request.httpBody = paymentInformation.toJSON();
        request.httpMethod = "POST";
        //        let task  = URLSession.shared.dataTask(with: request, completionHandler: { data, response , error in
        //            //HEre you choose something
            completion(nil); // or with some Error;
        //        });
        //task.resume();

    }

    func didSelectPaymentMethod(method: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {
        completion(self.paymentSummaryItems);
    }
    func didSelectShippingContact(contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        completion(.success, [], self.paymentSummaryItems);
    }
}


