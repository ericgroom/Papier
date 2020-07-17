//
//  Formatter.swift
//  iOS
//
//  Created by Eric Groom on 7/17/20.
//

import Foundation

extension Formatter {
    static let rounded: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()
}
