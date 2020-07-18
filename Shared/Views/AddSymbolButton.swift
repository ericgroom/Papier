//
//  AddSymbolButton.swift
//  iOS
//
//  Created by Eric Groom on 7/17/20.
//

import SwiftUI

struct AddSymbolButton: View {
    @State private var displaySearch = false
    @State var onSelected: (SearchResult) -> Void
    
    var body: some View {
        Button(action: {
            displaySearch = true
        }, label: {
            Image(systemName: "plus")
        }).sheet(isPresented: $displaySearch) {
            NavigationView {
                SymbolPicker(onSelected: onSymbolSelected)
                    .navigationBarTitle("Search", displayMode: .inline)
                    .navigationBarItems(leading:
                        Button("Cancel", action: {
                            displaySearch = false
                        })
                    )
            }
        }
    }
    
    public func onSymbolSelected(_ symbol: SearchResult) {
        displaySearch = false
        onSelected(symbol)
    }
}

struct AddSymbolButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddSymbolButton(onSelected: {_ in})
        }
    }
}
