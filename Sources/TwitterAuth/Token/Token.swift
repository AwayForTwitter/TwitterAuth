//
//  Token.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 30/04/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation

public struct Token: Codable {
    
    public struct Credentials: Codable {
        public var token: String
        public var secret: String
    }
    
//    public enum PermissionLevel: String, Codable {
//        case readOnly = "ro", readWrite = "rw"
//    }
    
//    public let permission: PermissionLevel
    
    public let credentials: Credentials

    public let username: String
    public let userID: String
    
    enum CodingKeys: String, CodingKey {
        case credentials, username, userID
    }
}

extension Token {
    
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(Token.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return result
    }
}

#if DEBUG
extension Token {
    public static var demo: Token {
        return .init(credentials: .init(token: "tkn", secret: "sct"), username: "demo", userID: "demo_userid")
    }
}
#endif
