//
//  OAuthAPIClient.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 15/07/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation
import Combine

final class APIClient {

    private static let verboseLog = false

    static func makeRequest(urlRequest: URLRequest) -> AnyPublisher<Data, Error> {
        let publisher =
            URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap() { element -> Data in
                if verboseLog {
                    print(element)
                }
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                if verboseLog {
                    print("response:", String(data: element.data, encoding: .utf8) as Any)
                }
                return element.data
                }
            .mapError({ e -> Error in
                print(e);
                return e
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    static func makeRequest<T: Decodable>(urlRequest: URLRequest) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .multiple
        let publisher = makeRequest(urlRequest: urlRequest)
            .decode(type: T.self, decoder: decoder)
//            .print("->> request event \(urlRequest.url?.absoluteString ?? "")\n", to: nil)
            .eraseToAnyPublisher()
        return publisher
    }
    
}
