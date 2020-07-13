//
//  SymbolStore.swift
//  iOS
//
//  Created by Eric Groom on 6/29/20.
//

import Foundation
import Combine
import SwiftUI

protocol SymbolStoring: AnyObject {
    typealias SearchQuery = String
    typealias SearchResultsCache = [SearchQuery: [SearchResult]]

    var searchResults: SearchResultsCache { get }
    var searchResults$: Published<SearchResultsCache>.Publisher { get } // FIXME once protocols support wrappers
    func performSearch(_ query: SearchQuery)
}

class SymbolStore: ObservableObject, SymbolStoring {
    
    @Published public private(set) var searchResults: [SearchQuery: [SearchResult]] = [:] // NSCache?
    
    var searchResults$: Published<SearchResultsCache>.Publisher { $searchResults }
    
    private let iex: IEXCloudServicing
    private let requestServicer: RequestServicing
    
    private var bag = Set<AnyCancellable>()
    
    public init(iex: IEXCloudServicing, requestServicer: RequestServicing) {
        self.iex = iex
        self.requestServicer = requestServicer
    }
    
    func performSearch(_ query: SearchQuery) {
        guard searchResults[query] == nil else { return }
        
        let result = iex.searchSymbols(matching: query)
        guard let request = try? result.get() else {
            fatalError("\(result)")
        }
        
        RequestServicer()
            .fetch(request: request)
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
