//
// Created by oz on 15/06/2017.
// Copyright (c) 2017 Bluesnap. All rights reserved.
//

import Foundation

//TODO: Merge this with the rest of the API configuration, some of this can also move to the merchant app
public class BSApplePayConfiguration {

    internal var identifier: String = "com.example.bluesnap" ;


    private struct MainBundle {
        static var prefix = "com.example.bluesnap"
    }

    struct Merchant {
        static let identifier = "merchant.\(MainBundle.prefix)"
    }

    public func setIdentifier(name: String!) {
        identifier = name;
    }

}

//TODO: this shuuld move to BSPAI
let InternalQueue = OperationQueue();
