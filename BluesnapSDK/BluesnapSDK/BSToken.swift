//
//  BSToken.swift


import Foundation

/**
 This class holds the basic data for a BlueShap token: the server URL and the token we got from it.
 */
public class BSToken {
    internal var tokenStr: String! = ""
    internal var serverUrl: String! = ""
    
    public init(tokenStr : String!, serverUrl : String!) {
        self.tokenStr = tokenStr
        self.serverUrl = serverUrl
    }
    
    public func getTokenStr() -> String! {
        return self.tokenStr
    }
}

/**
 This is the notification that gets thrown when the SDK recognizes that the token has expired
 */
public extension Notification.Name {
    
    static let bsTokenExpirationNotification = Notification.Name("bsTokenExpirationNotification")
}
