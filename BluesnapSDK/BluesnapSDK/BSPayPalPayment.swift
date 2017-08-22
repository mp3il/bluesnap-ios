//
//  BSPayPalPayment.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 07/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation


/**
 PayPal details for the purchase
 */
@objc public class BSPayPalPaymentRequest: BSBasePaymentRequest {
    
    public var payPalInvoiceId : String?
    
    override public init(initialData: BSInitialData) {
        super.init(initialData: initialData)
    }
}
