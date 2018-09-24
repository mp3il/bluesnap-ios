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
  public class BSPayPalSdkResult: BSBaseSdkResult {
    
    public var payPalInvoiceId : String?
    
    override public init(sdkRequest: BSSdkRequest) {
        super.init(sdkRequest: sdkRequest)
    }
}
