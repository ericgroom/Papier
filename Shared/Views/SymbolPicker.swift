//
//  SymbolPicker.swift
//  Papier
//
//  Created by Eric Groom on 6/27/20.
//

import SwiftUI

struct SymbolPicker: View {
    @EnvironmentObject var symbolStore: SymbolStore
    @Binding public var selection: SearchResult?
    @Binding public var showSelf: Bool
    @StateObject private var viewModel = SymbolPickerViewModel()
    
    var body: some View {
        return VStack {
            SearchBar(text: viewModel.searchTextBinding)
            List {
                ForEach(viewModel.searchResults) { symbol in
                    Button(action: {
                        onSelected(symbol)
                    }, label: {
                        Text(symbol.symbol)
                    })
                }
            }.onAppear {
                viewModel.symbolStore = symbolStore
            }
        }
    }
    
    init(selection: Binding<SearchResult?>, showSelf: Binding<Bool>) {
        self._selection = selection
        self._showSelf = showSelf
    }
    
    func onSelected(_ item: SearchResult) {
        selection = item
        showSelf = false
    }
}

struct SymbolPicker_Previews: PreviewProvider {
    @State private static var selection: SearchResult?
    @State private static var showDetail: Bool = true
    
    static var previews: some View {
        SymbolPicker(selection: $selection, showSelf: $showDetail)
    }
}
