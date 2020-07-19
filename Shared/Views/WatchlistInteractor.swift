//
//  WatchlistInteractor.swift
//  Papier
//
//  Created by Eric Groom on 7/15/20.
//

import Foundation
import Combine

class WatchlistInteractor: Interactor {
    @Published var watched: [Quote] = []
    
    private var priceInformationStore: PriceInformationStoring
    private var watchlistStore: WatchlistStoring
    
    var bag = Set<AnyCancellable>()
    
    init(priceInformationStore: PriceInformationStoring, watchlistStore: WatchlistStoring) {
        self.priceInformationStore = priceInformationStore
        self.watchlistStore = watchlistStore
        
        watchlistStore.watchedSymbols.flatMap { symbols in
            priceInformationStore.batchQuotes(for: symbols)
        }
        .print()
        .assertNoFailure()
        .print()
        .receive(on: RunLoop.main)
        .sink { [weak self] quotes in
            self?.watched = Array(quotes.values)
        }
        .store(in: &bag)
    }
    
    func watch(symbol: Symbol) {
        watchlistStore.watch(symbol: symbol)
            .sink(receiveValue: { _ in
                
            })
            .store(in: &bag)
    }
}
