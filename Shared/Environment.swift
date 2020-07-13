//
//  Container.swift
//  Papier
//
//  Created by Eric Groom on 7/12/20.
//

import Foundation

protocol Environment {
    var symbolStore: SymbolStoring { get }
    var requestServicer: RequestServicing { get }
}

class RealEnvironment: Environment {
    let symbolStore: SymbolStoring
    let requestServicer: RequestServicing
    let symbolSearchService: SymbolSearchService
    
    static let shared: Environment = RealEnvironment()
    
    init() {
        // something has gone seriously wrong if this fails outside of development
        let keys = try! Keys.fetch(from: UserDefaults.standard)

        let iex = IEXCloudRequestFactory(keys: keys.iexcloud, enviornment: .sandbox)
        self.requestServicer = RequestServicer()
        self.symbolSearchService = SymbolSearchService(requestServicer: requestServicer, requestFactory: iex)
        self.symbolStore = SymbolStore(searchService: symbolSearchService)
    }
}
