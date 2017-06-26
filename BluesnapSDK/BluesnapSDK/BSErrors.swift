//
//  BSErrors.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 07/06/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

public enum BSCcDetailErrors : Error {
    case usedTokenApplePay
    case usedTokenForCC
    case invalidCcNumber
    case invalidCvv
    case invalidExpDate
    case expiredToken
    case unknown
}

public enum BSApiErrors : Error {
    case invalidInput
    case expiredToken
    case unknown
}

public enum BSApplePayErrors: Error {
    case cantMakePaymentError
    case unknown
}

//
//public struct ApplepayErrors {
//
//    static let domain = "com.bluesnap.applepay.error";
//
//    static let undefinedError = NSError(domain: ApplepayErrors.domain, code: 0,
//            userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("UNDEFINED_ERROR_KEY", comment: "")]);
//
//    static let cantMakePaymentError = NSError(domain: ApplepayErrors.domain, code: 1,
//            userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("CANT_MAKE_PAYMENTS_ERROR_KEY", comment: "")]);
//
//    static let failed = NSError(domain: ApplepayErrors.domain, code: 2,
//            userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("FAILED_PAYMENT_ERROR_KEY", comment: "")]);
//}

