//
//  WatchlistInteractor.swift
//  Papier
//
//  Created by Eric Groom on 7/15/20.
//

import Foundation
import Combine

class WatchlistInteractor: Interactor {
    @Published var watched: [WatchedSymbol] = []
    @Published var quotes: [Symbol: Quote] = [:]
    
    private var priceInformationStore: PriceInformationStoring
    private var watchlistStore: WatchlistStoring
    
    var bag = Set<AnyCancellable>()
    
    init(priceInformationStore: PriceInformationStoring, watchlistStore: WatchlistStoring) {
        self.priceInformationStore = priceInformationStore
        self.watchlistStore = watchlistStore
        
        watchlistStore.watchedSymbols.sink { [weak self] watchedSymbols in
            self?.watched = watchedSymbols
        }.store(in: &bag)
        
        $watched
            .map { Set($0.map(\.symbol)) }
            .removeDuplicates()
            .flatMap { symbols in
                priceInformationStore.batchQuotes(for: symbols)
            }
            .assertNoFailure()
            .receive(on: RunLoop.main)
            .sink { [weak self] quotes in
                self?.quotes = quotes
            }
            .store(in: &bag)
    }
    
    func watch(symbol: Symbol) {
        watchlistStore.watch(symbol: symbol)
    }
    
    func reorder(from source: IndexSet, to destination: Int) {
        watchlistStore.reorder(from: source, to: destination)
    }
    
    func delete(_ indices: IndexSet) {
        watchlistStore.delete(indices)
    }
}
