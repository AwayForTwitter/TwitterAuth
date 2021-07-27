//
//  TwitterAuth.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 30/04/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

public protocol TokenStorage: AnyObject {
    func storeToken(_ token: Token)
}

public final class TwitterAuthSession {
        
    public let tokenStorage: TokenStorage
    public let clientCredentials: ClientCredentials
    
    public init(tokenStorage: TokenStorage, clientCredentials: ClientCredentials) {
        self.tokenStorage = tokenStorage
        self.clientCredentials = clientCredentials
    }
    
    public func startFlow(completion: @escaping (Result<Token, Error>) -> Void) {
        OAuthFlow(credentials: clientCredentials) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let token):
                self.tokenStorage.storeToken(token)
            }
            completion(result)
        }.start()
    }
}
