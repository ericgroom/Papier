//
//  SymbolPickerViewModel.swift
//  Papier
//
//  Created by Eric Groom on 7/12/20.
//

import Foundation
import SwiftUI
import Combine

class SymbolPickerViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [SearchResult] = []
    let symbolStore: SymbolStoring
    
    var searchTextBinding: Binding<String> {
        Binding(get: { self.searchText }, set: { self.searchText = $0 })
    }
    
    var bag = Set<AnyCancellable>()
        
    init(environment: Environment = RealEnvironment.shared) {
        self.symbolStore = environment.symbolStore
        
        $searchText
            .filter { $0.count >= 2 }
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink { [weak self] query in
                self?.symbolStore.performSearch(query)
            }
            .store(in: &bag)
        
        symbolStore.searchResults$
            .combineLatest($searchText)
            .map { (resultsCache, query) in resultsCache[query, default: []] }
            .receive(on: RunLoop.main)
            .assign(to: \.searchResults, on: self)
            .store(in: &bag)
    }
}
