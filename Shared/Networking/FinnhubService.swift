//
//  FinnhubService.swift
//  Papier
//
//  Created by Eric Groom on 6/27/20.
//

import Foundation
import Combine

class FinnhubService {
    typealias ApiKey = String
    private let apiKey: ApiKey
    private let host: String = "finnhub.io"
    private let baseUrl: String = "/api/v1/"
    
    public init(apiKey: ApiKey) {
        self.apiKey = apiKey
    }
    
    // All GET request require a token parameter token=apiKey in the URL or a header X-Finnhub-Token : apiKey
    
    // If your limit is exceeded, you will receive a response with status code 429
    // On top of all plan's limit, there is a 30 API calls/ second limit.
    
    private enum HeaderKeys {
        static let auth = "X-Finnhub-Token"
    }
    
    func authenticate(_ request: inout URLRequest) {
        request.setValue(apiKey, forHTTPHeaderField: HeaderKeys.auth)
    }
    
    func baseComponents(to endpoint: String) -> URLComponents {
        let normalizedEndpointPostfix = endpoint.first == "/" ? String(endpoint.dropFirst()) : endpoint
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = baseUrl + normalizedEndpointPostfix
        return components
    }
    
    /**
        Fetches a list of available symbols for a particular stock exchange.
     
     Example request: `GET https://finnhub.io/api/v1/stock/symbol?exchange=US`
     
     - Parameter exchange: defaults to "US", exhaustive list here   https://docs.google.com/spreadsheets/d/1I3pBxjfXB056-g_JYf_6o3Rns3BV2kMGG1nCatb91ls/edit#gid=0
     */
    func getAvailableSymbols(exchange: String = "US") -> URLRequest {
        var components = baseComponents(to: "stock/symbol")
        components.queryItems = [URLQueryItem(name: "exchange", value: exchange)]
        
        let url = components.url! // FIXME
        var request = URLRequest(url: url)
        authenticate(&request)
        return request
    }
}

struct SymbolSummary: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
}

extension SymbolSummary: Identifiable {
    var id: String {
        symbol
    }
}

extension SymbolSummary: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
