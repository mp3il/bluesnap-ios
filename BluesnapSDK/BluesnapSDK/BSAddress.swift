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
  public class BSBaseAddressDetails: NSObject {
    
    public var name : String! = ""
    public var address : String?
    public var city : String?
    public var zip : String?
    public var country : String?
    public var state : String?
    
    public override init() {
        super.init()
    }
    
    public func getSplitName() -> (firstName: String, lastName: String)? {
        return BSStringUtils.splitName(name)
    }
}

/**
 Shopper billing details - basically address + email
 */
  public class BSBillingAddressDetails : BSBaseAddressDetails, NSCopying {
    
    public var email : String?

    public override init() { super.init() }
    
    public init(email: String?, name: String!, address: String?, city: String?, zip: String?, country: String?, state: String?) {
        super.init()
        self.email = email
        self.name = name
        self.address = address
        self.city = city
        self.zip = zip
        self.country = country
        self.state = state
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSBillingAddressDetails(email: email, name:name, address: address, city: city, zip: zip, country: country, state: state)
        return copy
    }
}

/**
 Shopper shipping details - basically address + phone
 */
  public class BSShippingAddressDetails : BSBaseAddressDetails, NSCopying {
    
    public var phone : String?
    
    public override init() { super.init() }
    
    public init(phone: String?, name: String!, address: String?, city: String?, zip: String?, country: String?, state: String?) {
        super.init()
        self.phone = phone
        self.name = name
        self.address = address
        self.city = city
        self.zip = zip
        self.country = country
        self.state = state
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = BSShippingAddressDetails(phone: phone, name:name, address: address, city: city, zip: zip, country: country, state: state)
        return copy
    }
}


