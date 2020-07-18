//
//  WatchlistStore.swift
//  iOS
//
//  Created by Eric Groom on 7/17/20.
//

import Foundation
import Combine

protocol WatchlistStoring {
    var watchedSymbols: AnyPublisher<[Symbol], Never> { get }
    func watch(symbol: Symbol) -> AnyPublisher<Void, Never>
}

class WatchlistStore: WatchlistStoring {
    private var watchlistSubject = CurrentValueSubject<[Symbol], Never>(["AMD"])
    var watchedSymbols: AnyPublisher<[Symbol], Never> {
        watchlistSubject.eraseToAnyPublisher()
    }
    
    func watch(symbol: Symbol) -> AnyPublisher<Void, Never> {
        Future { [self] promise in
            watchlistSubject.value.append(symbol)
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
}
