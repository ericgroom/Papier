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
    @State private var selectedSymbol: SearchResult? = nil
    @State private var showSearch = false
    private var iex: IEXCloudService
    private var symbolStore: SymbolStore
    private var requestServicer: RequestServicer
    
    init() {
        // something has gone seriously wrong if this fails outside of development
        let keys = try! Keys.fetch(from: UserDefaults.standard)

        self.iex = IEXCloudService(keys: keys.iexcloud, enviornment: .sandbox)
        self.requestServicer = RequestServicer()
        self.symbolStore = SymbolStore(iex: iex, requestServicer: requestServicer, debounceScheduler: DispatchQueue.global(qos: .userInitiated))
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Form {
                    NavigationLink(
                        "Select Symbol",
                        destination: SymbolPicker(selection: $selectedSymbol, showSelf: $showSearch),
                        isActive: $showSearch)
                    Text("Selected: \(selectedSymbol?.symbol ?? "none")")
                }
            }
            .environmentObject(symbolStore)
        }
    }
}
