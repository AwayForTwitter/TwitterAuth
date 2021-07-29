//
//  TwitterRequestSigner.swift
//  
//
//  Created by Marina Gornostaeva on 28/07/2021.
//

import Foundation

public final class TwitterRequestSigner {
    
    public let userID: String
    public let tokenStorage: TokenStorage
    public let clientCredentials: ClientCredentials
    
    public init(userID: String, tokenStorage: TokenStorage, clientCredentials: ClientCredentials) {
        self.userID = userID
        self.tokenStorage = tokenStorage
        self.clientCredentials = clientCredentials
    }
    
    public func makeSignedRequest(path: String, queryParams: [String: String], method: String) throws -> URLRequest {
        
        guard let token = tokenStorage.tokenForUserID(userID) else {
            throw SignatureError.noToken
        }

        let urlWithPath = "https://api.twitter.com/" + path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let encodedQuery = queryParams.map({ "\($0.key)=\((try? $0.value.percentEncoded()) ?? "")" }).joined(separator: "&")
        let string = urlWithPath + "?" + encodedQuery
        
        var request = URLRequest(url: URL(string: string)!)
        request.httpMethod = method
        
        let authHeader = try AuthorizationHeader.headerFor(urlString: urlWithPath,
                                                           query: queryParams,
                                                           method: method,
                                                           additionalOAuthParams: [],
                                                           consumerKey: clientCredentials.key,
                                                           consumerSecret: clientCredentials.secret,
                                                           token: token.credentials.token,
                                                           tokenSecret: token.credentials.secret,
                                                           identifier: .new,
                                                           timestamp: Date())
        
        request.addValue(authHeader.value, forHTTPHeaderField: authHeader.key)
        return request
    }
}

extension TwitterRequestSigner {
    
    public enum SignatureError: Swift.Error {
        case noToken
        case invalidRequest
    }
}
