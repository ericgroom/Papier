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
    var coreDataService: CoreDataService { get }
    
    func symbolSearchInteractor() -> SymbolSearchInteractor
    func watchlistInteractor() -> WatchlistInteractor
}

class RealEnvironment: Environment {
    let requestServicer: RequestServicing
    let coreDataService: CoreDataService
    let symbolSearchStore: SymbolSearchStore
    let priceInformationStore: PriceInformationStoring
    let watchlistStore: WatchlistStoring
    
    private var bag = Set<AnyCancellable>()
    
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
        self.coreDataService = CoreDataService()
        self.symbolSearchStore = SymbolSearchStore(requestServicer: requestServicer, requestFactory: iex)
        self.priceInformationStore = PriceInformationStore(requestServicer: requestServicer, requestFactory: iex)
        
        let persistence = WatchlistPeristenceService(managedObjectContext: coreDataService.managedObjectContext)
        self.watchlistStore = WatchlistStore(persistence: persistence)
        
        if let concreteServicer = requestServicer as? RequestServicer {
            subscribeToHooks(on: concreteServicer)
        }
    }
    
    func symbolSearchInteractor() -> SymbolSearchInteractor {
        SymbolSearchInteractor(service: symbolSearchStore)
    }
    
    func watchlistInteractor() -> WatchlistInteractor {
        WatchlistInteractor(priceInformationStore: priceInformationStore, watchlistStore: watchlistStore)
    }
    
    private func subscribeToHooks(on requestServicer: RequestServicer) {
        
        requestServicer.hooks.receivedResponse
            .compactMap { $0 as? HTTPURLResponse }
            .sink { response in
                let intHeaders = response.allHeaderFields
                    .compactMapValues { $0 as? String }
                    .compactMapValues { Int($0) }
                let regularMessagesConsumed = intHeaders["iexcloud-messages-used"]
                let premiumMessagesConsumed = intHeaders["iexcloud-premium-messages-used"]
                let path = response.url?.path
                
                var message: String?
                if let regular = regularMessagesConsumed {
                    message = "Consumed \(regular) messages"
                }
                if let premium = premiumMessagesConsumed {
                    if message != nil {
                        message! += " and \(premium) premium messages"
                    } else {
                        message = "Comsumed \(premium) premium messages"
                    }
                }
                if let path = path, message != nil {
                    message! += " while calling \(path)"
                }
                
                if let message = message {
                    print(message)
                }
            }.store(in: &bag)
    }
}
