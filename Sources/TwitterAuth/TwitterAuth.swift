//
//  TwitterAuth.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 30/04/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

public protocol TokenStorage {
    var token: String? { get set }
}

public final class TwitterAuth {
    
    public struct Consumer {
        public init(key: String, secret: String) {
            self.key = key
            self.secret = secret
        }
        
        var key: String
        var secret: String
    }
    
    public private(set) var token: Token?
    public let tokenStorage: TokenStorage
    public let consumer: Consumer
    
    init(tokenStorage: TokenStorage, consumer: Consumer) {
        self.tokenStorage = tokenStorage
        self.consumer = consumer
    }
}
