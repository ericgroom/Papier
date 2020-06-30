//
//  SymbolStore.swift
//  iOS
//
//  Created by Eric Groom on 6/29/20.
//

import Foundation
import Combine

protocol SymbolStoring: ObservableObject {
    var allSymbols: [SymbolSummary] { get }
}

class SymbolStore: ObservableObject, SymbolStoring {
    @Published public private(set) var allSymbols: [SymbolSummary] = []
    private let finnhubService: FinnhubService
    private let requestServicer: RequestServicer
    
    private var bag = Set<AnyCancellable>()
    
    public init(finnhubService: FinnhubService, requestServicer: RequestServicer) {
        self.finnhubService = finnhubService
        self.requestServicer = requestServicer
        
        makeRequest()
    }
    
    private func makeRequest() {
        let request = finnhubService.getAvailableSymbols()
        
        RequestServicer()
            .fetch(request: request, as: [SymbolSummary].self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("done")
                case .failure(let error):
                    fatalError("\(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] (summaries: [SymbolSummary]) in
                self?.allSymbols = summaries
            })
            .store(in: &bag)
    }
}

class MockSymbolStore: ObservableObject, SymbolStoring {
    @Published var allSymbols: [SymbolSummary] = [
        SymbolSummary(description: "Advanced Micro Devices", displaySymbol: "AMD", symbol: "AMD")
    ]
}
