//
//  BSErrors.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 07/06/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

public enum BSErrors : Error {
    
    // CC
    case invalidCcNumber
    case invalidCvv
    case invalidExpDate

    // ApplePay
    case cantMakePaymentError
    case usedTokenForCC
    case usedTokenApplePay
    case applePayOperationError
    case applePayCanceled

    // generic
    case invalidInput
    case expiredToken
    case tokenNotFound
    case unknown
}
