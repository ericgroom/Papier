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
    
    private let searchService: SymbolSearchServicing
    
    private var bag = Set<AnyCancellable>()
    
    public init(searchService: SymbolSearchServicing) {
        self.searchService = searchService
    }
    
    func performSearch(_ query: SearchQuery) {
        guard searchResults[query] == nil else { return }
        
        searchService.searchSymbols(matching: query)
            .assertNoFailure()
            .sink(receiveValue: { [weak self] (summaries: [SearchResult]) in
                self?.searchResults[query] = summaries
            })
            .store(in: &bag)
    }
}
