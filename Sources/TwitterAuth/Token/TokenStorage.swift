//
//  TokenStorage.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 25/10/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation
import KeychainAccess

public final class KeychainStorage: TokenStorage {
    
    public let keychain: Keychain

    public init(keychain: Keychain) {
        self.keychain = keychain
    }
    
    public convenience init(service: String? = nil) {
        let serviceAttribute: String
        if let service = service {
            serviceAttribute = service
        }
        else {
            var serviceComponents: [String] = []
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                serviceComponents.append(bundleIdentifier)
            }
            serviceComponents.append("auth")
            serviceAttribute = serviceComponents.joined(separator: ".")
        }
        
        let keychain = Keychain(service: serviceAttribute)
            .accessibility(.afterFirstUnlockThisDeviceOnly)
            .synchronizable(true)
        
        self.init(keychain: keychain)
    }
    
    public func storeToken(_ token: Token) throws {
        let key = key(for: token)
        do {
            try keychain.set(token.rawValue, key: key)
        }
        catch {
            Logger.logError("Couldn't save token to keychain")
            Logger.logError(visibility: .debugOnly, "\(error)", "\(token)")
            throw error
        }
    }
    
    public func tokenForUserID(_ userID: String) -> Token? {
        let key = key(for: userID)
        do {
            guard let existing = try keychain.get(key) else {
                Logger.logError("No item found in keychain for userID \(userID) (returned nil)")
                return nil
            }
            guard let token = Token(rawValue: existing) else {
                Logger.logError("Token found but is not decodable for \(userID)")
                Logger.logError(visibility: .debugOnly, "Raw value token: \(existing)")
                return nil
            }
            return token
        }
        catch {
            Logger.logError("Error getting token from keychain")
            Logger.logError(visibility: .debugOnly, "Error: \(error)")
            return nil
        }
    }
    
    public func deleteTokenForUserID(_ userID: String) throws {
        let key = key(for: userID)
        do {
            try keychain.remove(key)
        }
        catch {
            Logger.logError("Error removing token from keychain for userID \(userID)")
            Logger.logError(visibility: .debugOnly, "Error: \(error)")
            throw error
        }
    }
}


private func key(for userID: String) -> String {
    return "token_\(userID)"
}
private func key(for token: Token) -> String {
    return "token_\(token.userID)"
}
