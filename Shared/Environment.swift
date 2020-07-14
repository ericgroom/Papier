//
//  Container.swift
//  Papier
//
//  Created by Eric Groom on 7/12/20.
//

import Foundation

protocol Environment {
    var requestServicer: RequestServicing { get }
    
    func symbolSearchInteractor() -> SymbolSearchInteractor
}

class RealEnvironment: Environment {
    let requestServicer: RequestServicing
    let symbolSearchService: SymbolSearchService
    
    static let shared: Environment = RealEnvironment()
    
    init() {
        // something has gone seriously wrong if this fails outside of development
        let keys = try! Keys.fetch(from: UserDefaults.standard)

        let iex = IEXCloudRequestFactory(keys: keys.iexcloud, enviornment: .sandbox)
        self.requestServicer = RequestServicer()
        self.symbolSearchService = SymbolSearchService(requestServicer: requestServicer, requestFactory: iex)
    }
    
    func symbolSearchInteractor() -> SymbolSearchInteractor {
        SymbolSearchInteractor(service: self.symbolSearchService)
    }
}
