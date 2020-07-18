//
//  IEXCloudService.swift
//  Papier
//
//  Created by Eric Groom on 7/10/20.
//

import Foundation

protocol IEXCloudRequestProducing {
    func searchSymbols(matching query: String) -> Result<Request<[SearchResult]>, RequestConstructionError>
    func quote(for symbol: Symbol) -> Result<Request<Quote>, RequestConstructionError>
}

class IEXCloudRequestFactory: IEXCloudRequestProducing {
    // MARK: - Common
    
    typealias ApiKey = String

    private let keys: Keys.IEXCloud
    public let enviornment: IEXEnvironment
    
    private let basePath: String = "/v1/"
    
    public init(keys: Keys.IEXCloud, enviornment: IEXEnvironment) {
        self.keys = keys
        self.enviornment = enviornment
    }
    
    private var host: String {
        enviornment.hostname
    }
    
    private var apiKey: ApiKey {
        enviornment.key(from: keys)
    }
    
    private lazy var authParam = URLQueryItem(name: "token", value: apiKey)
    
    /**
            Creates URLComponents for a specific endpoint, setting standard configuration for the host, base path, auth, etc.
     
        Note: the queryItems are probably present, you can just append to them
     
     - Parameter endpoint: a string path for the desired endpoint
     */
    internal func baseComponents(to endpoint: String) -> Result<URLComponents, RequestConstructionError> {
        let normalizedEndpointPostfix = endpoint.first == "/" ? String(endpoint.dropFirst()) : endpoint
        
        guard let encodedEndpoint = normalizedEndpointPostfix
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return .failure(.unableToPercentEncodeString)
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = basePath + encodedEndpoint
        components.queryItems = [authParam]
        return .success(components)
    }
}

enum IEXEnvironment {
    case normal
    case sandbox
}

extension IEXEnvironment {
    func key(from keys: Keys.IEXCloud) -> String {
        switch self {
        case .normal:
            return keys.publishable
        case .sandbox:
            return keys.sandbox
        }
    }
}

extension IEXEnvironment {
    var hostname: String {
        switch self {
        case .normal:
            return "cloud.iexapis.com"
        case .sandbox:
            return "sandbox.iexapis.com"
        }
    }
}

enum RequestConstructionError: Error {
    case unableToPercentEncodeString
    case unableToCreateURLFromComponents
}
