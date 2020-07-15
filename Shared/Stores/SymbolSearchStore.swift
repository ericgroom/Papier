//
//  SymbolSearchService.swift
//  Papier
//
//  Created by Eric Groom on 7/13/20.
//

import Foundation
import Combine

protocol SymbolSearchStoring {
    typealias SearchQuery = String
    func searchSymbols(matching query: SearchQuery) -> AnyPublisher<[SearchResult], ServiceError>
}

class SymbolSearchStore: SymbolSearchStoring {
    let requestServicer: RequestServicing
    let requestFactory: IEXCloudRequestProducing
    
    private var searchCache: [SearchQuery: [SearchResult]] = [:] // move to a global store?
    
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
        let request = FromResult(constructionResult)
        
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
