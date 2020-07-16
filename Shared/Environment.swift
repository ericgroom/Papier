//
//  Container.swift
//  Papier
//
//  Created by Eric Groom on 7/12/20.
//

import Foundation
import Combine

protocol Environment {
    var requestServicer: RequestServicing { get }
    
    func symbolSearchInteractor() -> SymbolSearchInteractor
}

class RealEnvironment: Environment {
    let requestServicer: RequestServicing
    let symbolSearchStore: SymbolSearchStore
    let priceInformationStore: PriceInformationStoring
    
    /**
     Would like to eventually use SwiftUI environment, but it's not possible to access outside of SwiftUI Views,
      And you can't even use the value in the initialization of the view
     */
    static let shared: Environment = RealEnvironment()
    
    init() {
        // something has gone seriously wrong if this fails outside of development
        let keys = try! Keys.fetch(from: UserDefaults.standard)

        let iex = IEXCloudRequestFactory(keys: keys.iexcloud, enviornment: .sandbox)
        self.requestServicer = RequestServicer()
        self.symbolSearchStore = SymbolSearchStore(requestServicer: requestServicer, requestFactory: iex)
        self.priceInformationStore = PriceInformationStore(requestServicer: requestServicer, requestFactory: iex)
    }
    
    func symbolSearchInteractor() -> SymbolSearchInteractor {
        SymbolSearchInteractor(service: self.symbolSearchStore)
    }
}
