//
//  WatchlistStore.swift
//  iOS
//
//  Created by Eric Groom on 7/17/20.
//

import Foundation
import Combine

protocol WatchlistStoring {
    var watchedSymbols: AnyPublisher<[WatchedSymbol], Never> { get }
    
    func watch(symbol: Symbol)
    func reorder(from source: IndexSet, to destination: Int)
    func delete(_ indices: IndexSet)
}

class WatchlistStore: WatchlistStoring {
    
    let persistence: WatchlistPeristenceService
    
    init(persistence: WatchlistPeristenceService) {
        self.persistence = persistence
        self.watchlistSubject = CurrentValueSubject(try! persistence.getWatchedSymbols())
    }
    
    private var watchlistSubject: CurrentValueSubject<[WatchedSymbol], Never>
    var watchedSymbols: AnyPublisher<[WatchedSymbol], Never> {
        watchlistSubject.eraseToAnyPublisher()
    }
    
    func watch(symbol: Symbol) {
        let info = WatchedSymbol(symbol: symbol, order: watchlistSubject.value.count)
        watchlistSubject.value.append(info)
        try! persistence.new(info)
    }
    
    func reorder(from source: IndexSet, to destination: Int) {
        var reindexed = watchlistSubject.value
        reindexed.move(fromOffsets: source, toOffset: destination)
        let reordered = reindexed.enumerated().map { (i, symbol) in
            WatchedSymbol(symbol: symbol.symbol, order: i)
        }
        watchlistSubject.value = reordered
        try! persistence.upsert(reordered)
    }
    
    func delete(_ indices: IndexSet) {
        try! persistence.delete(indices.map { watchlistSubject.value[$0] })
        watchlistSubject.value.remove(atOffsets: indices)
    }
}

struct WatchedSymbol {
    let symbol: String
    let order: Int
}

extension WatchedSymbol: Identifiable {
    var id: Symbol { symbol }
}
