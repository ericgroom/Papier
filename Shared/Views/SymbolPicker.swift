//
//  SymbolPicker.swift
//  Papier
//
//  Created by Eric Groom on 6/27/20.
//

import SwiftUI

struct SymbolPicker: View {
    @StateObject private var interactor = RealEnvironment.shared.symbolSearchInteractor()
    @State var onSelected: (SearchResult) -> Void
    
    var body: some View {
        return VStack {
            SearchBar(text: interactor.binding(for: \.searchText))
            List {
                ForEach(interactor.searchResults) { symbol in
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
}

struct SymbolPicker_Previews: PreviewProvider {
    
    static var previews: some View {
        SymbolPicker(onSelected: {_ in })
    }
}
