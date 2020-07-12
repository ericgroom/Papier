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
    var symbolStore: SymbolStore!
    
    var searchTextBinding: Binding<String> {
        Binding(get: { self.searchText }, set: { self.searchText = $0 })
    }
    
    var bag = Set<AnyCancellable>()
    
    init() {
        $searchText.dropFirst().sink { [weak self] newValue in
            self?.symbolStore.searchText.value = newValue
        }.store(in: &bag)
        
        $searchText.dropFirst().sink { [weak self] newValue in
            guard let self = self else { return }
            self.searchResults = self.symbolStore.searchResults[newValue, default: []]
        }.store(in: &bag)
    }
}
