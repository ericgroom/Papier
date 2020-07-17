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
}

class WatchlistStore: WatchlistStoring {
    private var watchlistSubject = CurrentValueSubject<[Symbol], Never>(["AMD", "GOOGL", "VOO"])
    var watchedSymbols: AnyPublisher<[Symbol], Never> {
        watchlistSubject.eraseToAnyPublisher()
    }
}
