//
//  IEXCloudRequestFactory+Search.swift
//  Papier
//
//  Created by Eric Groom on 7/15/20.
//

import Foundation

struct SearchResult: Codable {
    let symbol: String
    let securityName: String
    let securityType: String
    let region: String
    let exchange: String
}

extension SearchResult: Identifiable {
    var id: String { symbol }
}

typealias SearchQuery = String

extension IEXCloudRequestFactory {
    func searchSymbols(matching query: SearchQuery) -> Result<Request<[SearchResult]>, RequestConstructionError> {
        guard let endpoint = "/search/\(query)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
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
