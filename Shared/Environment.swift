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
    
    static let shared: Environment = RealEnvironment()
    
    init() {
        // something has gone seriously wrong if this fails outside of development
        let keys = try! Keys.fetch(from: UserDefaults.standard)

        let iex = IEXCloudService(keys: keys.iexcloud, enviornment: .sandbox)
        self.requestServicer = RequestServicer()
        self.symbolStore = SymbolStore(iex: iex, requestServicer: requestServicer)
    }
}
