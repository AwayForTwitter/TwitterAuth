//
//  OAuthFlow.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 15/07/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation
import Combine
import AuthenticationServices

final class OAuthFlow {
    
    typealias CompletionHandler = (Result<Token, Error>) -> Void
    
    let credentials: ClientCredentials
    let completion: CompletionHandler
    
    private var cancelBag: Set<AnyCancellable> = []

    init(credentials: ClientCredentials, completion: @escaping CompletionHandler) {
        self.credentials = credentials
        self.completion = completion
    }
    
    func start() {
        guard cancelBag.isEmpty else {
            return
        }
        
        // request token
        // handle (show to user)
        // finalize - request access token
        // save token (not in here)

        requestToken()
            .flatMap({ self.handleAuth($0) })
            .flatMap({ self.finalizeAuth(response: $0) })
            
            .sink { [self] (c) in
                print(c)
                switch c {
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { [self] (value) in
                print(value)
                completion(.success(value.token))
                
            }.store(in: &cancelBag)
    }
    
    private func requestToken() -> AnyPublisher<Endpoints.RequestToken.Response, Error> {
        let request = Endpoints.RequestToken.request(clientCredentials: credentials, identifier: .new, timestamp: Date())

        let publisher: AnyPublisher<Data, Error> = APIClient.makeRequest(urlRequest: request)
        let p = publisher
            .tryMap({ try Endpoints.RequestToken.Response(data: $0) })
 
        return p.eraseToAnyPublisher()
    }
    
    private func handleAuth(_ response: Endpoints.RequestToken.Response) -> Future<Endpoints.Authorize.Response, Error> {
        
        enum AuthError: Error {
            case underlying(Error?)
        }
        
        let credentials = self.credentials
        return Future { promise in
            // TODO: do we need to ensure main thread here?
            
            var context: AuthPresenter? = AuthPresenter()
            let url = Endpoints.Authorize.webAuthURL(tokenResponse: response)

            let authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: credentials.urlScheme) { (callbackURL, error) in
                print("auth done", callbackURL as Any, error as Any)
                context = nil
                
                guard error == nil, let callbackURL = callbackURL else {
                    promise(.failure(AuthError.underlying(error)))
                    return
                }
                
                let response = Result(catching: { try Endpoints.Authorize.Response(url: callbackURL, secret: response.secret) })
                promise(response)
            }
            authSession.presentationContextProvider = context
            authSession.start()
        }
    }
    
    private func finalizeAuth(response: Endpoints.Authorize.Response) -> AnyPublisher<Endpoints.AccessToken.Response, Error> {
        let request = Endpoints.AccessToken.request(webAuthResponse: response, clientCredentials: credentials, identifier: .new, timestamp: Date())
        
        let publisher: AnyPublisher<Data, Error> = APIClient.makeRequest(urlRequest: request)
        let p = publisher.tryMap({ try Endpoints.AccessToken.Response(data: $0) })
        
        return p.eraseToAnyPublisher()
    }
}

private class AuthPresenter: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow! // TODO: make sure it picks the current window
    }
}
