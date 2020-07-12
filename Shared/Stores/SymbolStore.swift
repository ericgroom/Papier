//
//  SymbolStore.swift
//  iOS
//
//  Created by Eric Groom on 6/29/20.
//

import Foundation
import Combine
import SwiftUI

protocol SymbolStoring: ObservableObject {
    typealias SearchQuery = String
    
    var searchResults: [SearchQuery: [SearchResult]] { get }
    var searchText: CurrentValueSubject<String, Never> { get }
}

class SymbolStore: ObservableObject, SymbolStoring {
    
    @Published public private(set) var searchResults: [SearchQuery: [SearchResult]] = [:]
    public var searchText: CurrentValueSubject<String, Never>
    
    private let iex: IEXCloudService
    private let requestServicer: RequestServicer
    
    private var bag = Set<AnyCancellable>()
    
    public init<S: Scheduler>(iex: IEXCloudService, requestServicer: RequestServicer, debounceScheduler: S) {
        self.iex = iex
        self.requestServicer = requestServicer
        self.searchText = CurrentValueSubject("")
        
        searchText
            .print()
            .filter { $0.count >= 2 }
            .debounce(for: .milliseconds(500), scheduler: debounceScheduler)
            .sink { [weak self] query in
                self?.performSearch(query)
            }
            .store(in: &bag)
    }
    
    func performSearch(_ query: SearchQuery) {
        let result = iex.searchSymbols(matching: query)
        guard let request = try? result.get() else {
            fatalError("\(result)")
        }
        
        RequestServicer()
            .fetch(request: request)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("done")
                case .failure(let error):
                    fatalError("\(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] (summaries: [SearchResult]) in
                self?.searchResults[query] = summaries
            })
            .store(in: &bag)
    }
}

class MockSymbolStore: ObservableObject, SymbolStoring {
    var searchText: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    
    @Published var searchResults: [SearchQuery : [SearchResult]] = [
        "test": [SearchResult(symbol: "test", securityName: "Testing corp", securityType: "idk", region: "US", exchange: "idk")]
    ]
    
    func performSearch(_ query: SearchQuery) {}
}

extension CurrentValueSubject {
    var binding: Binding<Output> {
        Binding(get: { self.value }, set: { self.value = $0 })
    }
}
