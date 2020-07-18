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
            ForEach(interactor.watched) { quote in
                HStack {
                    VStack(alignment: .leading) {
                        Text(quote.symbol)
                            .bold()
                        Text(quote.companyName)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(format(decimal: quote.latestPrice))
                        .bold()
                }
            }
        }.navigationBarItems(
            trailing: AddSymbolButton(onSelected: onSymbolSelected)
        )
    }
    
    func onSymbolSelected(_ symbol: SearchResult) {
        interactor.watch(symbol: symbol.symbol)
    }
    
    func format(decimal: Decimal) -> String {
        return Formatter.currency.string(for: decimal) ?? "<invalid>"
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}
