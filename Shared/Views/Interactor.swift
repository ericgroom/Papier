//
//  Interactor.swift
//  Papier
//
//  Created by Eric Groom on 7/15/20.
//

import SwiftUI

protocol Interactor: ObservableObject {
    
}

extension Interactor {
    func binding<T>(for keyPath: ReferenceWritableKeyPath<Self, T>) -> Binding<T> {
        Binding(get: { self[keyPath: keyPath] }, set: { self[keyPath: keyPath] = $0 })
    }
}
