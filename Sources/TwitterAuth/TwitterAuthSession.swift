//
//  TwitterAuthSession.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 30/04/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation

public protocol TokenStorage: AnyObject {
    func storeToken(_ token: Token) throws
    func tokenForUserID(_ userID: String) -> Token?
    func deleteTokenForUserID(_ userID: String) throws
}

public enum TokenStorageKind {
    case keychain(service: String?)
    case custom(TokenStorage)
    
    public static var `default`: TokenStorageKind { return .keychain(service: nil) }
    
    public func storage() -> TokenStorage {
        switch self {
        case .keychain:
            return KeychainStorage()
        case .custom(let tokenStorage):
            return tokenStorage
        }
    }
}

public final class TwitterAuthSession {
        
    public let tokenStorage: TokenStorage
    public let clientCredentials: ClientCredentials
    public let configuration: Configuration
    
    public init(clientCredentials: ClientCredentials, tokenStorage: TokenStorageKind = .default, configuration: Configuration = .init()) {
        self.tokenStorage = tokenStorage.storage()
        self.clientCredentials = clientCredentials
        self.configuration = configuration
    }
    
    public func startFlow(completion: @escaping (Result<Token, Error>) -> Void) {
        OAuthFlow(credentials: clientCredentials, usePrivateSession: true) { result in
            let resultToReturn: Result<Token, Error>
            
            switch result {
            case .failure(let error):
                print(error)
                resultToReturn = result
            case .success(let token):
                
                do {
                    try self.tokenStorage.storeToken(token)
                    resultToReturn = result
                }
                catch {
                    resultToReturn = .failure(error)
                }
            }
            
            completion(resultToReturn)
        }.start()
    }
    
    public func deleteToken(forUserWithID userID: String) throws {
        try self.tokenStorage.deleteTokenForUserID(userID)
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
