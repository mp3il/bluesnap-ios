//
//  BSAddress.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 07/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation


/**
 Shopper address details for purchase.
 State is mandfatopry only if the country has state (USA, Canada and Brazil).
 For not-full billing details, only name, country and zip are filled, email is optional
 For full billing details, everything is mandatory except email which is optional.
 For shipping details all field are mandatory except phone which is optional.
 */
@objc public class BSBaseAddressDetails: NSObject {
    
    public override init() {}
    
    public var name : String! = ""
    public var address : String?
    public var city : String?
    public var zip : String?
    public var country : String?
    public var state : String?
    
    public func getSplitName() -> (firstName: String, lastName: String)? {
        return BSStringUtils.splitName(name)
    }
}

/**
 Shopper billing details - basically address + email
 */
@objc public class BSBillingAddressDetails : BSBaseAddressDetails, NSCopying {
    
    public override init() { super.init() }
    
    public var email : String?
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSBillingAddressDetails()
        copy.name = name
        copy.address = address
        copy.city = city
        copy.zip = zip
        copy.country = country
        copy.state = state
        copy.email = email
        return copy
    }
}

/**
 Shopper shipping details - basically address + phone
 */
@objc public class BSShippingAddressDetails : BSBaseAddressDetails, NSCopying {
    
    public override init() { super.init() }
    
    public var phone : String?
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSShippingAddressDetails()
        copy.name = name
        copy.address = address
        copy.city = city
        copy.zip = zip
        copy.country = country
        copy.state = state
        copy.phone = phone
        return copy
    }
}


