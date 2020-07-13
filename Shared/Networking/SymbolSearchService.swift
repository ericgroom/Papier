//
//  SymbolSearchService.swift
//  Papier
//
//  Created by Eric Groom on 7/13/20.
//

import Foundation
import Combine

protocol SymbolSearchServicing {
    typealias SearchQuery = String // TODO: dedup
    func searchSymbols(matching query: SearchQuery) -> AnyPublisher<[SearchResult], ServiceError> // TODO Error
}

class SymbolSearchService: SymbolSearchServicing {
    let requestServicer: RequestServicing
    let requestFactory: IEXCloudRequestProducing
    
    private var searchCache: [SearchQuery: [SearchResult]] = [:]
    
    init(requestServicer: RequestServicing, requestFactory: IEXCloudRequestProducing) {
        self.requestServicer = requestServicer
        self.requestFactory = requestFactory
    }
    
    func searchSymbols(matching query: SearchQuery) -> AnyPublisher<[SearchResult], ServiceError> {
        if let previousResult = searchCache[query] {
            return Just(previousResult)
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        }
        
        let constructionResult = requestFactory.searchSymbols(matching: query)
        let request = fromResult(constructionResult)
        
        return request
            .mapError { ServiceError.requestConstruction($0) }
            .flatMap { [self] request -> AnyPublisher<[SearchResult], ServiceError> in
                requestServicer.fetch(request: request)
                    .mapError { ServiceError.network($0) }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] results in
                self?.searchCache[query] = results
            })
            .eraseToAnyPublisher()
    }
}

func fromResult<Success, Failure: Error>(_ result: Result<Success, Failure>) -> Future<Success, Failure> {
    return Future.init { promise in
        switch result {
        case .success(let value):
            promise(.success(value))
        case .failure(let error):
            promise(.failure(error))
        }
    }
}

enum ServiceError: Swift.Error {
    case requestConstruction(RequestConstructionError)
    case network(NetworkError)
}
