//
//  KeyedDecodingContainer.swift
//  iOS
//
//  Created by Eric Groom on 7/17/20.
//

import Foundation

/*
 Unbelievable after all this time there is no way to decode a floating point JSON number
 as a `Decimal` or even just a `String` to later convert it.
 */
extension KeyedDecodingContainer {
    func decodeShittyDecimalIfPresent(forKey key: Self.Key) throws -> Decimal? {
        let double = try decodeIfPresent(Double.self, forKey: key)
        guard let roundedString = Formatter.rounded.string(for: double) else {
            throw ShittyDecimalDecodingError.cantMakeString
        }
        return Decimal(string: roundedString)
    }
    
    func decodeShittyDecimal(forKey key: Self.Key) throws -> Decimal {
        guard let decimal = try decodeShittyDecimalIfPresent(forKey: key) else {
            throw ShittyDecimalDecodingError.cantInitDecimal
        }
        return decimal
    }
}

enum ShittyDecimalDecodingError: Error {
    case cantMakeString
    case cantInitDecimal
}
