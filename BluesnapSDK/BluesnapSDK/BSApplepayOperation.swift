//
// Created by oz on 15/06/2017.
// Copyright (c) 2017 Bluesnap. All rights reserved.
//

import Foundation
import PassKit

open class BSApplepayOperation: Operation {

    enum State {
        case initial
        case finished
        case executing
        case canceled
    }

    var state: State = .initial {
        willSet {
            willChangeValue(forKey: "state");
        }
        didSet {
            didChangeValue(forKey: "state");
        }

    }

    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state" as NSObject]
    }

    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state" as NSObject]
    }

    class func keyPathsForValuesAffectingIsCancelled() -> Set<NSObject> {
        return ["state" as NSObject]
    }


    override open func start() {
        self.state = .executing;
        self.execute();
    }

    open func execute() {
        fatalError("should be implemented");
    }


    func finish() {
        self.state = .finished;
    }

    override open var isFinished: Bool {
        return self.state == .finished;
    }

    override open var isCancelled: Bool {
        return self.state == .canceled;
    }

    override open var isExecuting: Bool {
        return self.state == .executing;
    }
}


public enum PaymentValidationResult {
    case valid
    case invalidShippingContact
    case invalidBillingPostalAddress
    case invalidShippingPostalAddress

    fileprivate func asPKPaymentStatus() -> PKPaymentAuthorizationStatus? {
        switch self {
        case .invalidShippingContact:
            return PKPaymentAuthorizationStatus.invalidShippingContact;
        case .invalidBillingPostalAddress:
            return PKPaymentAuthorizationStatus.invalidBillingPostalAddress;
        case .invalidShippingPostalAddress:
            return PKPaymentAuthorizationStatus.invalidShippingPostalAddress;
        default:
            return nil;
        }
    }

}

public protocol PaymentOperationDelegate: class {
    func validate(payment: PKPayment, completion: @escaping(PaymentValidationResult) -> Void)

    func send(paymentInformation: BSApplePayInfo, completion: @escaping (BSErrors?) -> Void)

    func didSelectPaymentMethod(method: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void)

    func didSelectShippingContact(contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void);
}


public class PaymentOperation: BSApplepayOperation, PKPaymentAuthorizationViewControllerDelegate {

    public let request: PKPaymentRequest
    private var requestController: PKPaymentAuthorizationViewController!
    private var status: PKPaymentAuthorizationStatus = .failure;
    public var error: Error?
    public weak var delegate: PaymentOperationDelegate!


    public init(request: PKPaymentRequest) {
        self.request = request;
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        delegate.validate(payment: payment) {
            switch $0 {
            case .valid:
                self.delegate.send(paymentInformation: BSApplePayInfo(payment: payment)) {
                    if let error = $0 {
                        self.status = .failure;
                        self.error = error;
                    } else {
                        self.status = .success;
                    }
                    completion(self.status);
                };
            default:
                self.status = $0.asPKPaymentStatus()!;
                completion(self.status);
            }
        }
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect paymentMethod: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {
        delegate.didSelectPaymentMethod(method: paymentMethod, completion: completion);
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        delegate.didSelectShippingContact(contact: contact, completion: completion);
    }

    func finish(with error: Error? = nil) {
        self.error = error;
        self.finish();
    }

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {

        controller.dismiss(animated: true) {
            if case .success = self.status {
                self.finish();
            } else {
                self.finish(with: BSErrors.unknown);
            }
        };
    }

    deinit {
        NSLog("BSApplepayOperation deinint");
    }

    override public func execute() {
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: self.request.supportedNetworks) {
            self.finish(with: BSErrors.cantMakePaymentError);
        }
        self.requestController = PKPaymentAuthorizationViewController(paymentRequest: self.request);
        self.requestController.delegate = self;
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self.requestController, animated: true, completion: nil) ?? {
                self.finish(with: BSErrors.unknown);
            }()
        }


    }


}


