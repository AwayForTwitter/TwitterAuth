//
//  TwitterAuthSession.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 30/04/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation

public protocol TokenStorage: AnyObject {
    func storeToken(_ token: Token)
    func tokenForUserID(_ userID: String) -> Token?
    func deleteTokenForUserID(_ userID: String)
}

public final class TwitterAuthSession {
        
    public let tokenStorage: TokenStorage
    public let clientCredentials: ClientCredentials
    public let configuration: Configuration
    
    public init(tokenStorage: TokenStorage, clientCredentials: ClientCredentials, configuration: Configuration = .init()) {
        self.tokenStorage = tokenStorage
        self.clientCredentials = clientCredentials
        self.configuration = configuration
    }
    
    public func startFlow(completion: @escaping (Result<Token, Error>) -> Void) {
        OAuthFlow(credentials: clientCredentials, usePrivateSession: true) { result in
            
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

extension TwitterAuthSession {
    
    public struct Configuration {
        
        public var usePrivateSession = true
        
        public init(usePrivateSession: Bool = true) {
            self.usePrivateSession = usePrivateSession
        }
    }
}
