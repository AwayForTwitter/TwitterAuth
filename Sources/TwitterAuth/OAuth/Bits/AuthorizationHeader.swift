//
//  AuthorizationHeader.swift
//  TwitterAuth
//  
//  Created by Marina Gornostaeva on 15/07/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation

struct AuthorizationHeader {
    let key: String
    let value: String
    
    let parameterString: String
    let signature: String
}

extension AuthorizationHeader {
    
    static func headerFor(
        urlString: String,
        query: [String: String],
        method: String,
        additionalOAuthParams: [Parameter] = [],
        consumerKey: String,
        consumerSecret: String,
        token: String?,
        tokenSecret: String?,
        identifier: RequestIdentifier,
        timestamp: Date) throws -> AuthorizationHeader {
        
        // https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature
        
        let oauthParams: [Parameter] = {
            var params = [
                Parameter(key: "oauth_consumer_key" , value: consumerKey),
                Parameter(key: "oauth_nonce", value: identifier.identifier),
                Parameter(key: "oauth_signature_method", value: "HMAC-SHA1"),
                Parameter(key: "oauth_timestamp", value: String(format: "%.0f", timestamp.timeIntervalSince1970)),
                Parameter(key: "oauth_version", value: "1.0")
            ]
            if let token = token {
                params.append(Parameter(key: "oauth_token", value: token))
            }
            params.append(contentsOf: additionalOAuthParams)
            return params.compactMap({ $0.percentEncoded })
        }()
        
        let parameterString: String = {
            var pairs = oauthParams
            pairs.append(contentsOf: query.compactMap({ Parameter(key: $0.key, value: $0.value).percentEncoded }))
                        
            pairs.sort(by: { $0.key < $1.key })
            
            let str = pairs.map({ "\($0.key)=\($0.value)"}).joined(separator: "&")
            return str
        }()
                        
       let urlPercentEncoded = try urlString.percentEncoded()
       let paramStringPercentEncoded = try parameterString.percentEncoded()
        
        let signature: String = try {
            let signatureBaseString = "\(method)&\(urlPercentEncoded)&\(paramStringPercentEncoded)"
            
            let c = try consumerSecret.percentEncoded()
            let t = try tokenSecret?.percentEncoded() ?? ""
            let secret = "\(c)&\(t)"
            
            let signatureData = signatureBaseString.hmac(key: secret)
            let signatureString = signatureData.base64EncodedString()
            return signatureString
        }()
        
        let oauth: String = try {
            var allParams = oauthParams
            allParams.append(Parameter(key: "oauth_signature", value: try signature.percentEncoded()))
            allParams.sort(by: { $0.key < $1.key })
            let str = allParams.map({ "\($0.key)=\"\($0.value)\""}).joined(separator: ", ")
            return "OAuth \(str)"
        }()
        
        return AuthorizationHeader(key: "Authorization", value: oauth, parameterString: parameterString, signature: signature)
    }
}
