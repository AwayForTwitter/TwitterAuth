//
//  Logger.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 26/10/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation
import os.log

final class Logger {
    
    enum Visibility {
        case debugOnly
        case debugAndRelease
    }
    
    static func logDebug(visibility: Visibility = .debugOnly, _ args: Any...) {
        logEverywhere(visibility: visibility, type: .debug, args)
    }
    
    static func logError(visibility: Visibility = .debugOnly,_ args: Any...) {
        logEverywhere(visibility: visibility, type: .error, args)
    }
    
    private static func logEverywhere(visibility: Visibility, type: OSLogType, _ params: [Any]) {
        let emoji = type == .error ? "❌" : "🛠"
        let descriptions = params.map({ "\($0)" })
        switch visibility {
        case .debugOnly:
            os_log("[TwitterAuth] %{public}@ %@", type: type, emoji, descriptions.joined(separator: " "))
        case .debugAndRelease:
            os_log("[TwitterAuth] %{public}@ %{public}@", type: type, emoji, descriptions.joined(separator: " "))
        }
    }
}
