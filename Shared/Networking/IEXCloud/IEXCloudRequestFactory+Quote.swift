//
//  IEXCloudRequestFactory+Quote.swift
//  Papier
//
//  Created by Eric Groom on 7/15/20.
//

import Foundation

typealias Symbol = String

struct Quote: Codable {
    let symbol: String
    let companyName: String
    let open: Double
    let close: Double
    let high: Double
    let low: Double
    let latestPrice: Double
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
