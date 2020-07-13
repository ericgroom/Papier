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
    
    init() {
        
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
        }
    }
}
