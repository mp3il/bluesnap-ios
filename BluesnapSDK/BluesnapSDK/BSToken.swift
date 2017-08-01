//
//  BSToken.swift


import Foundation

/**
 This class holds the basic data for a BlueShap token: the server URL and the token we got from it.
 The token is the String you get from BlueSnap API when generating a new token (/services/2/payment-fields-tokens).
 The serverURL should look liker this: https://api.bluesnap.com/ meaning: it should include the https, the domain, and end with a /
 */
@objc public class BSToken: NSObject {
    internal var tokenStr: String! = ""
    internal var serverUrl: String! = ""

    public init(tokenStr : String!, isProduction : Bool) {
        self.tokenStr = tokenStr
        self.serverUrl = isProduction ? BSApiManager.BS_PRODUCTION_DOMAIN : BSApiManager.BS_SANDBOX_DOMAIN
    }

    public init(tokenStr : String!, serverUrl : String!) {
        self.tokenStr = tokenStr
        self.serverUrl = serverUrl
    }
    
    public func getTokenStr() -> String! {
        return self.tokenStr
    }
    
    public func getServerUrl() -> String! {
        return self.serverUrl
    }
}

/**
 This is the notification that gets thrown when the SDK recognizes that the token has expired
 */
public extension Notification.Name {
    
    static let bsTokenExpirationNotification = Notification.Name("bsTokenExpirationNotification")
}
