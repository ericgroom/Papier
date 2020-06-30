//
//  SymbolPicker.swift
//  Papier
//
//  Created by Eric Groom on 6/27/20.
//

import SwiftUI

struct SymbolPicker: View {
    @EnvironmentObject var symbolStore: SymbolStore
    @Binding public var selection: SymbolSummary?
    @Binding public var showSelf: Bool
    @State private var searchText: String = ""

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
            List {
                ForEach(filteredSymbols) { symbol in
                    Button(action: {
                        onSelected(symbol)
                    }, label: {
                        Text(symbol.displaySymbol)
                    })
                }
            }
        }
    }
    
    var filteredSymbols: [SymbolSummary] {
        guard searchText.count >= 2 else { return [] }
        let query = searchText.lowercased()
        
        return symbolStore.allSymbols.filter { symbol in
            symbol.displaySymbol.lowercased().contains(query)
                || symbol.description.lowercased().contains(query)
        }
    }
    
    func onSelected(_ item: SymbolSummary) {
        selection = item
        showSelf = false
    }
}

struct SymbolPicker_Previews: PreviewProvider {
    @State private static var selection: SymbolSummary?
    @State private static var showDetail: Bool = true
    
    static var previews: some View {
        SymbolPicker(selection: $selection, showSelf: $showDetail)
    }
}
