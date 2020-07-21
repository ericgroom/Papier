//
//  WatchlistView.swift
//  Papier
//
//  Created by Eric Groom on 7/15/20.
//

import SwiftUI

struct WatchlistView: View {
    @StateObject var interactor = RealEnvironment.shared.watchlistInteractor()
    
    var body: some View {
        List {
            ForEach(interactor.watched) { symbol in
                HStack {
                    VStack(alignment: .leading) {
                        Text(symbol.symbol)
                            .bold()
                        Text(companyName(for: symbol))
                            .lineLimit(1)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(price(for: symbol))
                        .bold()
                }
            }.onDelete { deleted in
                interactor.delete(deleted)
            }.onMove { (source, destination) in
                interactor.reorder(from: source, to: destination)
            }
        }
        .navigationTitle("Watchlist")
        .navigationBarItems(
            leading: EditButton(),
            trailing: AddSymbolButton(onSelected: onSymbolSelected)
        )
    }
    
    func onSymbolSelected(_ symbol: SearchResult) {
        interactor.watch(symbol: symbol.symbol)
    }
    
    func price(for symbol: SymbolInfo) -> String {
        (interactor.quotes[symbol.symbol]?.latestPrice)
            .flatMap { Formatter.currency.string(for: $0) }
            ?? ""
    }
    
    func companyName(for symbol: SymbolInfo) -> String {
        interactor.quotes[symbol.symbol]?.companyName ?? ""
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}
