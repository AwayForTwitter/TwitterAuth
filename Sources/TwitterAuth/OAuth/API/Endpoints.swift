//
//  Endpoints.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 16/07/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation

// https://developer.twitter.com/en/docs/authentication/oauth-1-0a/obtaining-user-access-tokens

enum Endpoints {
}

// MARK: - Step 1: Request token -

extension Endpoints {

    enum RequestToken {
        
        static func request(clientCredentials: ClientCredentials,
                            identifier: RequestIdentifier,
                            timestamp: Date) -> URLRequest {
            
            let urlString = "https://api.twitter.com/oauth/request_token"
            let method = "POST"
            
            let auth = try? AuthorizationHeader.headerFor(
                urlString: urlString,
                query: [:],
                method: method,
                additionalOAuthParams: [Parameter(key: "oauth_callback", value: clientCredentials.callbackURL)],
                consumerKey: clientCredentials.key,
                consumerSecret: clientCredentials.secret,
                token: nil,
                tokenSecret: nil,
                identifier: identifier.identifier,
                timestamp: timestamp)
            
            var request = URLRequest(url: URL(string: urlString)!)
            if let auth = auth {
                request.addValue(auth.value, forHTTPHeaderField: auth.key)
            }
            request.httpMethod = method
            return request
        }
        
        struct Response {
            
            enum Error: Swift.Error {
                case notSatisfiable
                case notAString
            }
            
            var token: String
            var secret: String
            var oauthCallbackConfirmed: Bool
            
            init(data: Data) throws {
                guard let string = String(data: data, encoding: .utf8) else {
                    throw Error.notAString
                }
                
                let queryItems = string.split(separator: "&").map({ $0.split(separator: "=").map({ String($0) }) })
                
                guard let token = queryItems.first(where: { $0.count == 2 && $0[0] == "oauth_token" })?[1],
                      let secret = queryItems.first(where: { $0.count == 2 && $0[0] == "oauth_token_secret" })?[1],
                      let oauthCallbackConfirmed = queryItems.first(where: { $0.count == 2 && $0[0] == "oauth_callback_confirmed" })?[1],
                      oauthCallbackConfirmed == "true"
                else {
                    throw Error.notSatisfiable
                }
                self.token = token
                self.secret = secret
                self.oauthCallbackConfirmed = true
            }
        }
        
    }
}

// MARK: - Step 2: Web auth -

extension Endpoints {

    enum Authorize {
        
        // TODO: should timestamp go here?
        static func webAuthURL(tokenResponse: RequestToken.Response) -> URL {
            let urlString = "https://api.twitter.com/oauth/authorize?oauth_token=\(tokenResponse.token)"
            return URL(string: urlString)!
        }
        
        struct Response {
            
            enum Error: Swift.Error {
                case notSatisfiable
            }
            
            var token: String
            var verifier: String
            var secret: String
            
            init(url: URL, secret: String) throws {
                guard let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
                    let token = queryItems.filter({ $0.name == "oauth_token" }).first?.value,
                    let verifier = queryItems.filter({ $0.name == "oauth_verifier" }).first?.value
                else {
                    throw Error.notSatisfiable
                }
                self.token = token
                self.verifier = verifier
                self.secret = secret
            }
        }
    }
}

// MARK: - Step 3: Obtain access token -

extension Endpoints {

    enum AccessToken {
        
        static func request(webAuthResponse: Authorize.Response,
                            clientCredentials: ClientCredentials,
                            identifier: RequestIdentifier,
                            timestamp: Date) -> URLRequest {
            
            let urlString = "https://api.twitter.com/oauth/access_token"
            let method = "POST"
            
            let auth = try? AuthorizationHeader.headerFor(
                urlString: urlString,
                query: ["oauth_token": webAuthResponse.token, "oauth_verifier": webAuthResponse.verifier],
                method: method,
                additionalOAuthParams: [Parameter(key: "oauth_verifier", value: webAuthResponse.verifier)],
                consumerKey: clientCredentials.key,
                consumerSecret: clientCredentials.secret,
                token: webAuthResponse.token,
                tokenSecret: webAuthResponse.secret,
                identifier: identifier.identifier,
                timestamp: timestamp)
            
            var request = URLRequest(url: URL(string: urlString)!)
            if let auth = auth {
                request.addValue(auth.value, forHTTPHeaderField: auth.key)
            }
            request.httpMethod = method
            return request
        }
        
        struct Response {
            
            enum Error: Swift.Error {
                case notSatisfiable
                case notAString
            }
            
            let credentials: TokenCredentials

            let username: String
            let userID: String
            
            let data: Data
            
            init(data: Data) throws {
                guard let string = String(data: data, encoding: .utf8) else {
                    throw Error.notAString
                }
                
                let queryItems = string.split(separator: "&").map({ $0.split(separator: "=").map({ String($0) }) })
                
                guard let token = queryItems.first(where: { $0.count == 2 && $0[0] == "oauth_token" })?[1],
                      let secret = queryItems.first(where: { $0.count == 2 && $0[0] == "oauth_token_secret" })?[1],
                      let userID = queryItems.first(where: { $0.count == 2 && $0[0] == "user_id" })?[1],
                      let username = queryItems.first(where: { $0.count == 2 && $0[0] == "screen_name" })?[1]
                else {
                    throw Error.notSatisfiable
                }
                self.credentials = TokenCredentials(token: token, secret: secret)
                self.username = username
                self.userID = userID
                self.data = data
            }
        }
    }
}
