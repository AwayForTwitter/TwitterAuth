//
//  TwitterAuth.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 30/04/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

public protocol TokenStorage: AnyObject {
    var token: Token? { get set }
}

public final class TwitterAuthSession {
    
//    public private(set) var token: Token?
    
    public let tokenStorage: TokenStorage
    public let clientCredentials: ClientCredentials
    
    public init(tokenStorage: TokenStorage, clientCredentials: ClientCredentials) {
        self.tokenStorage = tokenStorage
        self.clientCredentials = clientCredentials
    }
    
    public func startFlow() {
        OAuthFlow(credentials: clientCredentials) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let token):
                self.tokenStorage.token = token
            }
            
        }.start()
    }
}
