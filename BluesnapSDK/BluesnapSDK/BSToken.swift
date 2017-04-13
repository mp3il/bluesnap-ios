//
//  BSToken.swift


import Foundation

public class BSToken {
    internal var tokenStr: String! = ""
    internal var serverUrl: String! = ""
    
    init(tokenStr : String!, serverUrl : String!) {
        self.tokenStr = tokenStr
        self.serverUrl = serverUrl
    }
    
    public func getTokenStr() -> String! {
        return self.tokenStr
    }
}
