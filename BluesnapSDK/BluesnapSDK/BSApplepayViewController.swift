//
// Created by oz on 15/06/2017.
// Copyright (c) 2017 Bluesnap. All rights reserved.
//

import Foundation

import UIKit
import PassKit


class BSApplePayViewController: UIViewController {

    @IBOutlet weak var applePayView: UIView!

    var paymentSummaryItems:[PKPaymentSummaryItem] = [];


    //TODO, read payment from BSCheckoutDetails (paymentRequest)
    func payPressed(_ sender: Any) {


        let fare = PKPaymentSummaryItem(label: "Minimum Fare", amount: NSDecimalNumber(string: "9.99"), type: .final)
        let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "1.00"), type: .final)
        let total = PKPaymentSummaryItem(label: "Emporium", amount: NSDecimalNumber(string: "10.99"), type: .pending)

        paymentSummaryItems = [fare, tax, total];


        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems;
        paymentRequest.merchantIdentifier = BSApplePayConfiguration.Merchant.identifier
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        paymentRequest.requiredShippingAddressFields = [.email, .phone, .postalAddress];
        paymentRequest.requiredBillingAddressFields = [.postalAddress];
        paymentRequest.supportedNetworks = [
                .amex,
                .discover,
                .masterCard,
                .visa
        ];



        // set up the operation with the paymaket request
        let paymentOperation = PaymentOperation(request: paymentRequest);

        paymentOperation.delegate = self;

        paymentOperation.completionBlock = {[weak op = paymentOperation] in
            NSLog("PK payment completion \(op?.error)")
        };


        //Send the payment operation via queue
        InternalQueue.addOperation(paymentOperation);

    }

    func setupPressed(sender: AnyObject) {
        let passLibrary = PKPassLibrary()
        passLibrary.openPaymentSetup()
    }
}



//TODO: move this extention to a BS file
extension BSApplePayViewController: PaymentOperationDelegate
{
    func validate(payment: PKPayment, completion: @escaping (PaymentValidationResult) -> Void) {
        completion(.valid);
    }

    func send(paymentInformation: BSApplePayInfo, completion: @escaping (Error?) -> Void) {
//        let url = URL(string: "https://com/post")!;
//        var request = URLRequest(url: url);
//        //request.addValue("Bearer SomeToken", forHTTPHeaderField: "Authorization");
//        print(paymentInformation.toDictionary());
//        request.httpBody = paymentInformation.toJSON();
//        request.httpMethod = "POST";
        //let task  = URLSession.shared.dataTask(with: request, completionHandler: { data, response , error in
            //completion(nil); // or with some Error;
        //});
        //task.resume();



    }


    func didSelectPaymentMethod(method: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {
        completion(self.paymentSummaryItems);
    }

    func didSelectShippingContact(contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        completion(.success, [], self.paymentSummaryItems);
    }

}


