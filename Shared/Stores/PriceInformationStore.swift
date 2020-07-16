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
}

class PriceInformationStore: PriceInformationStoring {
    let requestServicer: RequestServicing
    let requestFactory: IEXCloudRequestProducing
    
    init(requestServicer: RequestServicing, requestFactory: IEXCloudRequestProducing) {
        self.requestServicer = requestServicer
        self.requestFactory = requestFactory
    }
    
    func quote(for symbol: Symbol) -> AnyPublisher<Quote, ServiceError> {
        FromResult(requestFactory.quote(for: symbol))
            .mapError { ServiceError.requestConstruction($0) }
            .flatMap { [self] request in
                requestServicer.fetch(request: request)
                    .mapError { ServiceError.network($0) }
            }
            .eraseToAnyPublisher()
    }
}
