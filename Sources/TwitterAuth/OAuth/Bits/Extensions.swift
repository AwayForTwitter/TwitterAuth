//
//  Extensions.swift
//  TwitterAuth
//
//  Created by Marina Gornostaeva on 15/07/2021.
//  Copyright © 2021 Hybrid Cat ApS. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    
    func percentEncoded() throws -> String {
        enum Error: Swift.Error {
            case error
        }
        let chs = CharacterSet.decimalDigits.union(CharacterSet.letters).union(CharacterSet(charactersIn: "-._~"))
        guard let encoded = self.addingPercentEncoding(withAllowedCharacters: chs) else {
            throw Error.error
        }
        return encoded
    }
}

extension String {

    func hmac(key: String) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), key, key.count, self, self.count, &digest)
        let data = Data(digest)
        return data
    }
}
