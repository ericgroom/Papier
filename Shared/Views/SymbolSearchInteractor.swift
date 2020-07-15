//
//  SymbolPickerInteractor.swift
//  Papier
//
//  Created by Eric Groom on 7/12/20.
//

import Foundation
import SwiftUI
import Combine

class SymbolSearchInteractor: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [SearchResult] = []
    let service: SymbolSearchStoring
    
    func binding<T>(for keyPath: ReferenceWritableKeyPath<SymbolSearchInteractor, T>) -> Binding<T> {
        Binding(get: { self[keyPath: keyPath] }, set: { self[keyPath: keyPath] = $0 })
    }
    
    var bag = Set<AnyCancellable>()
        
    init(service: SymbolSearchStoring) {
        self.service = service
        
        $searchText
            .filter { $0.count >= 2 }
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.global(qos: .userInitiated))
            .setFailureType(to: ServiceError.self)
            .flatMap { query in
                service.searchSymbols(matching: query)
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("done")
                case .failure(let error):
                    fatalError("\(error)")
                }
            }, receiveValue: { [weak self] results in
                self?.searchResults = results
            })
            .store(in: &bag)
    }
}
