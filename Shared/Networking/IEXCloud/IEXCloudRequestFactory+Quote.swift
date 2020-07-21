//
//  IEXCloudRequestFactory+Quote.swift
//  Papier
//
//  Created by Eric Groom on 7/15/20.
//

import Foundation

typealias Symbol = String

struct Quote: Decodable {
    let symbol: Symbol
    let companyName: String
    let open: Decimal?
    let close: Decimal?
    let high: Decimal?
    let low: Decimal?
    let latestPrice: Decimal
    
    enum CodingKeys: String, CodingKey {
        case symbol, companyName, open, close, high, low, latestPrice
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        symbol = try container.decode(String.self, forKey: .symbol)
        companyName = try container.decode(String.self, forKey: .companyName)
        open = try container.decodeShittyDecimalIfPresent(forKey: .open)
        close = try container.decodeShittyDecimalIfPresent(forKey: .close)
        low = try container.decodeShittyDecimalIfPresent(forKey: .low)
        high = try container.decodeShittyDecimalIfPresent(forKey: .high)
        latestPrice = try container.decodeShittyDecimal(forKey: .latestPrice)
    }
}

extension Quote: Identifiable {
    var id: Symbol { symbol }
}

extension IEXCloudRequestFactory {
    func quote(for symbol: Symbol) -> ConstructionResult<Quote> {
        baseComponents(to: "/stock/\(symbol)/quote")
            .flatMap { components in
                guard let url = components.url else {
                    return .failure(.unableToCreateURLFromComponents)
                }
                return .success(url)
            }
            .map { (url: URL) in
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                return Request(request)
            }
    }
    
    func batch(for symbols: Set<Symbol>, with info: [StockInfoType]) -> ConstructionResult<BatchResponse> {
        // https://cloud.iexapis.com/stable/stock/aapl/batch?types=quote,news,chart&range=1m&last=10
        baseComponents(to: "/stock/market/batch")
            .map { components -> URLComponents in
                var components = components
                let symbols = URLQueryItem(name: "symbols", value: symbols.joined(separator: ","))
                let types = URLQueryItem(name: "types", value: info.map(\.urlParam).joined(separator: ","))
                components.queryItems?.append(symbols)
                components.queryItems?.append(types)
                return components
            }
            .flatMap { components in
                guard let url = components.url else {
                    return .failure(.unableToCreateURLFromComponents)
                }
                return .success(url)
            }
            .map { (url: URL) in
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                return Request(request)
            }
    }
}

typealias BatchResponse = [Symbol: BatchTypes]

struct BatchTypes: Decodable {
    let quote: Quote?
}

enum StockInfoType {
    case quote
    case news
    case chart
    
    var urlParam: String {
        switch self {
        case .quote:
            return "quote"
        case .news:
            return "news"
        case .chart:
            return "chart"
        }
    }
}
