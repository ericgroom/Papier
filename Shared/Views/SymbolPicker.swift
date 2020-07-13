//
//  SymbolPicker.swift
//  Papier
//
//  Created by Eric Groom on 6/27/20.
//

import SwiftUI

struct SymbolPicker: View {
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
                        VStack(alignment: .leading) {
                            Text(symbol.symbol)
                            Text(symbol.securityName)
                                .font(.footnote)
                        }
                    })
                }
            }
        }
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
