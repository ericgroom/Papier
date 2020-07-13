//
//  SymbolStore.swift
//  iOS
//
//  Created by Eric Groom on 6/29/20.
//

import Foundation
import Combine
import SwiftUI

class SymbolStore: ObservableObject {
    
    typealias SearchQuery = String
    
    @Published public private(set) var searchResults: [SearchQuery: [SearchResult]] = [:] // NSCache?
    
    private let iex: IEXCloudService
    private let requestServicer: RequestServicer
    
    private var bag = Set<AnyCancellable>()
    
    public init(iex: IEXCloudService, requestServicer: RequestServicer) {
        self.iex = iex
        self.requestServicer = requestServicer
    }
    
    func performSearch(_ query: SearchQuery) {
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
