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
    func quote(for symbol: Symbol) -> Result<Request<Quote>, RequestConstructionError> {
        guard let endpoint = "/stock/\(symbol)/quote"
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return .failure(.unableToPercentEncodeString)
        }
        let components = baseComponents(to: endpoint)
        guard let url = components.url else {
            return .failure(.unableToCreateURLFromComponents)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return .success(Request(request))
    }
}
