//
//  File.swift
//  
//
//  Created by Marina Gornostaeva on 15/07/2021.
//

import Foundation

struct Parameter {
    var key: String
    var value: String
    
    var percentEncoded: Parameter? {
        guard
            let key = try? key.percentEncoded(),
            let value = try? value.percentEncoded()
        else { return nil }
        return Parameter(key: key, value: value)
    }
}
