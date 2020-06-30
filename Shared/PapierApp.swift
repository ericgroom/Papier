//
//  PapierApp.swift
//  Shared
//
//  Created by Eric Groom on 6/27/20.
//

import SwiftUI
import Combine

@main
struct PapierApp: App {
    @State private var selectedSymbol: SymbolSummary? = nil
    @State private var showSearch = false
    private var finnhubService: FinnhubService
    private var symbolStore: SymbolStore
    private var requestServicer: RequestServicer
    
    init() {
        // something has gone seriously wrong if this fails outside of development
        let keys = try! Keys.fetch(from: UserDefaults.standard)

        self.finnhubService = FinnhubService(apiKey: keys.finnhub.key)
        self.requestServicer = RequestServicer()
        self.symbolStore = SymbolStore(finnhubService: finnhubService, requestServicer: requestServicer)
    }
    
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Form {
                    NavigationLink(
                        "Select Symbol",
                        destination: SymbolPicker(selection: $selectedSymbol, showSelf: $showSearch),
                        isActive: $showSearch)
                    Text("Selected: \(selectedSymbol?.displaySymbol ?? "none")")
                }
            }
            .environmentObject(symbolStore)
        }
    }
}
