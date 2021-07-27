//
//  Credentials.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 15/07/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation

public struct ClientCredentials {
    
    public init(key: String, secret: String, urlScheme: String, callbackURL: String) {
        self.key = key
        self.secret = secret
        self.urlScheme = urlScheme
        self.callbackURL = callbackURL
    }
    
    var key: String
    var secret: String
    var urlScheme: String
    var callbackURL: String
}

struct TokenCredentials {
    var token: String
    var secret: String
}
