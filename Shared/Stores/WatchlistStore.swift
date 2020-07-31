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
    
    func watch(symbol: Symbol) -> AnyPublisher<Void, Never>
    func reorder(from source: IndexSet, to destination: Int)
    func delete(_ indices: IndexSet)
}

class WatchlistStore: WatchlistStoring {
    private var watchlistSubject = CurrentValueSubject<[WatchedSymbol], Never>(g("AMD", "AMZN", "GOOGL", "INTL", "VOO"))
    var watchedSymbols: AnyPublisher<[WatchedSymbol], Never> {
        watchlistSubject.eraseToAnyPublisher()
    }
    
    func watch(symbol: Symbol) -> AnyPublisher<Void, Never> {
        Future { [self] promise in
            let info = WatchedSymbol(symbol: symbol, order: watchlistSubject.value.count)
            watchlistSubject.value.append(info)
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func reorder(from source: IndexSet, to destination: Int) {
        watchlistSubject.value.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(_ indices: IndexSet) {
        watchlistSubject.value.remove(atOffsets: indices)
    }
    
    private static func g(_ symbols: String...) -> [WatchedSymbol] {
        symbols.enumerated().map { WatchedSymbol(symbol: $0.element, order: $0.offset) }
    }
}

struct WatchedSymbol {
    let symbol: String
    let order: Int
}

extension WatchedSymbol: Identifiable {
    var id: Symbol { symbol }
}
