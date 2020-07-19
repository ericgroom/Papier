//
//  PriceInformationStore.swift
//  Papier
//
//  Created by Eric Groom on 7/15/20.
//

import Foundation
import Combine

protocol PriceInformationStoring {
    func quote(for symbol: Symbol) -> AnyPublisher<Quote, ServiceError>
    func batchQuotes(for symbols: [Symbol]) -> AnyPublisher<[Symbol: Quote], ServiceError>
}

class PriceInformationStore: PriceInformationStoring {
    let requestServicer: RequestServicing
    let requestFactory: IEXCloudRequestProducing
    
    init(requestServicer: RequestServicing, requestFactory: IEXCloudRequestProducing) {
        self.requestServicer = requestServicer
        self.requestFactory = requestFactory
    }
    
    private var cache: [Symbol: Quote] = [:]
    
    func quote(for symbol: Symbol) -> AnyPublisher<Quote, ServiceError> {
        if let previousValue = cache[symbol] {
            return Just(previousValue)
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        }
        
        return FromResult(requestFactory.quote(for: symbol))
            .mapError { ServiceError.requestConstruction($0) }
            .flatMap { [self] request in
                requestServicer.fetch(request: request)
                    .mapError { ServiceError.network($0) }
            }
            .eraseToAnyPublisher()
    }
    
    func batchQuotes(for symbols: [Symbol]) -> AnyPublisher<[Symbol: Quote], ServiceError> {
        return FromResult(requestFactory.batch(for: symbols, with: [.quote]))
            .mapError { ServiceError.requestConstruction($0) }
            .flatMap { [self] request in
                requestServicer.fetch(request: request)
                    .mapError { ServiceError.network($0) }
            }
            .map { response in
                response.compactMapValues(\.quote)
            }
            .eraseToAnyPublisher()
    }
}
