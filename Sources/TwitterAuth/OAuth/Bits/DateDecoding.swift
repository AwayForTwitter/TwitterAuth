//
//  DateDecoding.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 16/07/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation

// https://stackoverflow.com/questions/64892897/decode-date-time-from-string-or-timeinterval-in-swift

private extension Formatter {
    
    static let iso8601withFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static let ddMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    
    static let multiple = custom {
        let container = try $0.singleValueContainer()
        do {
            let string = try container.decode(String.self)
            guard let value = TimeInterval(string) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
            }
            return Date(timeIntervalSince1970: value/1000)
        } catch DecodingError.typeMismatch {
            let string = try container.decode(String.self)
            if let date = Formatter.iso8601withFractionalSeconds.date(from: string) ??
                Formatter.iso8601.date(from: string) ??
                Formatter.ddMMyyyy.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
    }
}
