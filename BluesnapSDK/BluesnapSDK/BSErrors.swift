//
//  BSErrors.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 07/06/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

public enum BSCcDetailErrors : Error {
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

