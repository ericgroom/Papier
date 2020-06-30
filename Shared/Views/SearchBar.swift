//
//  SearchBar.swift
//  Papier
//
//  Created by Eric Groom on 6/27/20.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeUIView(context: Context) -> UISearchBar {
        let view = UISearchBar()
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
}

struct SearchBar_Previews: PreviewProvider {
    @State static var text: String = "hi"
    
    static var previews: some View {
        SearchBar(text: $text)
    }
}
