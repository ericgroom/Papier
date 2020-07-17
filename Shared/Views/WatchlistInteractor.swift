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
            Publishers.MergeMany(
                symbols.map { priceInformationStore.quote(for: $0) }
            )
        }
        .assertNoFailure()
        .receive(on: RunLoop.main)
        .sink { quote in
            self.watched.append(quote)
        }
        .store(in: &bag)
    }
}
// https://cloud.iexapis.com/stable/stock/aapl/batch?types=quote,news,chart&range=1m&last=10
