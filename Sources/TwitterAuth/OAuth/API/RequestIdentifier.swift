//
//  File.swift
//  
//
//  Created by Marina Gornostaeva on 26/07/2021.
//

import Foundation

struct RequestIdentifier {
    
    let identifier: String
    
    static var new: RequestIdentifier {
        return RequestIdentifier(identifier: "\(Date().timeIntervalSince1970)".replacingOccurrences(of: ".", with: "x"))
    }
}
